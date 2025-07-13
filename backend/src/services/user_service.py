"""
User Service Layer
Contains business logic for user operations
"""

import logging
import re
from typing import Optional, Dict, Any, List
from datetime import datetime
from flask_jwt_extended import create_access_token
from sqlalchemy.exc import IntegrityError

from core.models.user import User
from core.models.user_preferences import UserPreferences, ProfileDataProvider
from core.exceptions import (
    UserAlreadyExistsError, UserNotFoundError, AuthenticationError,
    ValidationError, EmailNotVerifiedError, InvalidTokenError
)
from data_access.user_repository import UserRepository
from services.email_service import EmailService
from services.social_auth_service import SocialAuthService

logger = logging.getLogger(__name__)

class UserService:
    """Service class for user operations"""
    
    def __init__(self):
        self.user_repository = UserRepository()
        self.email_service = EmailService()
        self.social_auth_service = SocialAuthService()
        self.user_preferences = UserPreferences()
        # In-memory change history for now (should be database in production)
        self._change_history = []
    
    def register_user(self, username: str, email: str, password: str, 
                     first_name: Optional[str] = None, last_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Register a new user with email and password
        
        Args:
            username: Unique username
            email: User email address
            password: User password
            first_name: Optional first name
            last_name: Optional last name
            
        Returns:
            Dictionary containing user info and access token
            
        Raises:
            UserAlreadyExistsError: If user already exists
            ValidationError: If validation fails
        """
        logger.info(f"Attempting to register user: {username} with email: {email}")
        
        # Validate input
        self._validate_registration_input(username, email, password)
        
        # Check if user already exists
        if self.user_repository.get_user_by_email(email):
            logger.warning(f"Registration failed: Email already exists: {email}")
            raise UserAlreadyExistsError("Email address is already registered")
        
        if self.user_repository.get_user_by_username(username):
            logger.warning(f"Registration failed: Username already exists: {username}")
            raise UserAlreadyExistsError("Username is already taken")
        
        try:
            # Create new user
            user = User(
                username=username,
                email=email,
                password=password,
                first_name=first_name,
                last_name=last_name
            )
            
            # Generate email verification token
            verification_token = user.generate_verification_token()
            
            # Save user to database
            created_user = self.user_repository.create_user(user)
            
            # Create default preferences in MongoDB
            try:
                self.user_preferences.create_default_preferences(str(created_user.id))
                logger.info(f"Default preferences created for user: {created_user.id}")
            except Exception as e:
                logger.error(f"Failed to create default preferences: {str(e)}")
                # Continue with registration even if MongoDB fails
            
            # Send verification email
            try:
                self.email_service.send_verification_email(created_user.email, verification_token)
                logger.info(f"Verification email sent to: {created_user.email}")
            except Exception as e:
                logger.error(f"Failed to send verification email: {str(e)}")
                # Continue with registration even if email fails
            
            # Generate access token
            access_token = create_access_token(identity=str(created_user.id))
            
            logger.info(f"User registered successfully: {created_user.id}")
            
            return {
                'user': created_user.to_dict(),
                'access_token': access_token,
                'message': 'Registration successful. Please check your email for verification.'
            }
            
        except IntegrityError as e:
            logger.error(f"Database integrity error during registration: {str(e)}")
            if 'email' in str(e).lower():
                raise UserAlreadyExistsError("Email address is already registered")
            elif 'username' in str(e).lower():
                raise UserAlreadyExistsError("Username is already taken")
            else:
                raise UserAlreadyExistsError("User registration failed due to duplicate data")
    
    def authenticate_user(self, email: str, password: str) -> Dict[str, Any]:
        """
        Authenticate user with email and password
        
        Args:
            email: User email
            password: User password
            
        Returns:
            Dictionary containing user info and access token
            
        Raises:
            AuthenticationError: If authentication fails
            UserNotFoundError: If user not found
        """
        logger.info(f"Attempting to authenticate user: {email}")
        
        # Get user by email
        user = self.user_repository.get_user_by_email(email)
        if not user:
            logger.warning(f"Authentication failed: User not found: {email}")
            raise AuthenticationError("Invalid email or password")
        
        # Check if user is active
        if not user.is_active:
            logger.warning(f"Authentication failed: User inactive: {email}")
            raise AuthenticationError("Account is disabled")
        
        # Verify password
        if not user.check_password(password):
            logger.warning(f"Authentication failed: Invalid password for: {email}")
            raise AuthenticationError("Invalid email or password")
        
        # Update last login
        user.update_last_login()
        self.user_repository.update_user(user)
        
        # Generate access token
        access_token = create_access_token(identity=str(user.id))
        
        logger.info(f"User authenticated successfully: {user.id}")
        
        return {
            'user': user.to_dict(),
            'access_token': access_token,
            'message': 'Login successful'
        }
    
    def social_login(self, provider: str, access_token: str, 
                    email: Optional[str] = None, first_name: Optional[str] = None, 
                    last_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Handle social login (Google, Apple)
        
        Args:
            provider: Social provider (google, apple)
            access_token: Provider access token
            email: User email from provider
            first_name: User first name from provider
            last_name: User last name from provider
            
        Returns:
            Dictionary containing user info and access token
        """
        logger.info(f"Attempting social login with provider: {provider}")
        
        # Verify token with social provider
        social_user_info = self.social_auth_service.verify_token(provider, access_token)
        
        # Use email from token verification if not provided
        email = email or social_user_info.get('email')
        first_name = first_name or social_user_info.get('first_name')
        last_name = last_name or social_user_info.get('last_name')
        
        if not email:
            raise ValidationError("Email is required for social login")
        
        # Check if user exists by social ID
        social_id_field = f"{provider}_id"
        social_id = social_user_info.get('id')
        
        user = None
        if social_id:
            user = self.user_repository.get_user_by_social_id(provider, social_id)
        
        # If not found by social ID, check by email
        if not user:
            user = self.user_repository.get_user_by_email(email)
            
            if user:
                # Update user with social ID
                setattr(user, social_id_field, social_id)
                self.user_repository.update_user(user)
        
        # Create new user if doesn't exist
        if not user:
            # Generate username from email
            username = self._generate_username_from_email(email)
            
            user = User(
                username=username,
                email=email,
                first_name=first_name,
                last_name=last_name,
                **{social_id_field: social_id}
            )
            
            # Social login users are auto-verified
            user.email_verified = True
            
            user = self.user_repository.create_user(user)
            logger.info(f"New user created via social login: {user.id}")
        
        # Update last login
        user.update_last_login()
        self.user_repository.update_user(user)
        
        # Generate access token
        jwt_token = create_access_token(identity=str(user.id))
        
        logger.info(f"Social login successful: {user.id}")
        
        return {
            'user': user.to_dict(),
            'access_token': jwt_token,
            'message': 'Social login successful'
        }
    
    def verify_email(self, token: str) -> bool:
        """
        Verify user email with token
        
        Args:
            token: Email verification token
            
        Returns:
            True if verification successful
            
        Raises:
            InvalidTokenError: If token is invalid
        """
        logger.info("Attempting email verification")
        
        user = self.user_repository.get_user_by_verification_token(token)
        if not user:
            logger.warning("Email verification failed: Invalid token")
            raise InvalidTokenError("Invalid verification token")
        
        if user.verify_email(token):
            self.user_repository.update_user(user)
            logger.info(f"Email verified successfully for user: {user.id}")
            return True
        
        logger.warning("Email verification failed: Token verification failed")
        raise InvalidTokenError("Invalid verification token")
    
    def get_user_profile(self, user_id: str) -> Dict[str, Any]:
        """
        Get user profile by ID
        
        Args:
            user_id: User ID
            
        Returns:
            User profile dictionary
            
        Raises:
            UserNotFoundError: If user not found
        """
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        return user.to_dict()
    
    def update_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Update user profile
        
        Args:
            user_id: User ID
            profile_data: Profile data to update
            
        Returns:
            Updated user profile
            
        Raises:
            UserNotFoundError: If user not found
        """
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        # Update allowed fields
        allowed_fields = [
            'first_name', 'last_name', 'dietary_restrictions',
            'cooking_experience_level', 'nutritional_goals', 'budget_info'
        ]
        
        for field, value in profile_data.items():
            if field in allowed_fields and value is not None:
                setattr(user, field, value)
        
        updated_user = self.user_repository.update_user(user)
        logger.info(f"User profile updated: {user_id}")
        
        return updated_user.to_dict()
    
    def _validate_registration_input(self, username: str, email: str, password: str) -> None:
        """Validate registration input"""
        if not username or len(username) < 3:
            raise ValidationError("Username must be at least 3 characters long")
        
        if not re.match(r'^[a-zA-Z0-9_-]+$', username):
            raise ValidationError("Username can only contain letters, numbers, underscores, and hyphens")
        
        if not email or '@' not in email:
            raise ValidationError("Valid email address is required")
        
        if not password or len(password) < 8:
            raise ValidationError("Password must be at least 8 characters long")
        
        if not re.search(r'[A-Z]', password):
            raise ValidationError("Password must contain at least one uppercase letter")
        
        if not re.search(r'[0-9]', password):
            raise ValidationError("Password must contain at least one number")
    
    def _generate_username_from_email(self, email: str) -> str:
        """Generate a unique username from email"""
        base_username = email.split('@')[0].lower()
        base_username = re.sub(r'[^a-zA-Z0-9_-]', '', base_username)
        
        # Ensure minimum length
        if len(base_username) < 3:
            base_username = f"user_{base_username}"
        
        # Check if username exists and append number if needed
        username = base_username
        counter = 1
        
        while self.user_repository.get_user_by_username(username):
            username = f"{base_username}_{counter}"
            counter += 1
        
        return username
    
    def setup_user_profile(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Set up comprehensive user profile during onboarding
        
        Args:
            user_id: User ID
            profile_data: Comprehensive profile data from onboarding
            
        Returns:
            Dictionary containing updated user profile
            
        Raises:
            UserNotFoundError: If user not found
            ValidationError: If validation fails
        """
        logger.info(f"Setting up profile for user: {user_id}")
        
        # Get user
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        # Update PostgreSQL user fields if present
        postgresql_updates = {}
        if 'cooking_experience_level' in profile_data:
            postgresql_updates['cooking_experience_level'] = profile_data['cooking_experience_level']
        
        # Build nutritional_goals for PostgreSQL
        nutritional_goals = {}
        for field in ['weight_goal', 'daily_calorie_target', 'protein_target_pct', 'carb_target_pct', 'fat_target_pct', 'dietary_program']:
            if field in profile_data:
                nutritional_goals[field] = profile_data[field]
        
        if nutritional_goals:
            postgresql_updates['nutritional_goals'] = nutritional_goals
        
        # Build budget_info for PostgreSQL
        budget_info = {}
        for field in ['budget_period', 'budget_amount', 'currency', 'price_per_meal_min', 'price_per_meal_max']:
            if field in profile_data:
                budget_info[field.replace('budget_', '')] = profile_data[field]
        
        if budget_info:
            postgresql_updates['budget_info'] = budget_info
        
        # Update dietary restrictions in PostgreSQL
        if 'dietary_restrictions' in profile_data:
            postgresql_updates['dietary_restrictions_list'] = profile_data['dietary_restrictions']
        
        # Update PostgreSQL user data
        if postgresql_updates:
            for field, value in postgresql_updates.items():
                setattr(user, field, value)
            
            updated_user = self.user_repository.update_user(user)
        else:
            updated_user = user
        
        # Update MongoDB preferences
        try:
            success = self.user_preferences.update_profile_setup(user_id, profile_data)
            if success:
                logger.info(f"Profile setup completed successfully for user: {user_id}")
            else:
                logger.warning(f"Failed to update MongoDB preferences for user: {user_id}")
        except Exception as e:
            logger.error(f"Error updating MongoDB preferences: {str(e)}")
            # Don't fail the whole operation if MongoDB update fails
        
        return {
            'user': updated_user.to_dict(),
            'message': 'Profile setup completed successfully'
        }
    
    def get_profile_setup_data(self) -> Dict[str, Any]:
        """
        Get predefined data for profile setup options
        
        Returns:
            Dictionary containing all available options for profile setup
        """
        logger.info("Fetching profile setup data")
        
        return {
            'dietary_restrictions': ProfileDataProvider.get_dietary_restrictions(),
            'allergies': ProfileDataProvider.get_allergies(),
            'cooking_experience_levels': ProfileDataProvider.get_cooking_experience_levels(),
            'kitchen_equipment': ProfileDataProvider.get_kitchen_equipment(),
            'dietary_programs': ProfileDataProvider.get_dietary_programs(),
            'currencies': ProfileDataProvider.get_currencies()
        }
    
    def get_user_onboarding_status(self, user_id: str) -> Dict[str, Any]:
        """
        Get user's onboarding/profile setup status
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary containing onboarding status
        """
        logger.info(f"Getting onboarding status for user: {user_id}")
        
        # Get user basic info
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        # Get MongoDB preferences to check completion status
        preferences = self.user_preferences.get_preferences(user_id)
        
        onboarding_data = {
            'user_id': user_id,
            'email_verified': user.email_verified,
            'profile_setup_completed': False,
            'current_step': 0
        }
        
        if preferences:
            onboarding_data.update({
                'profile_setup_completed': preferences.get('profile_setup_completed', False),
                'current_step': preferences.get('onboarding_step', 0)
            })
        
        return onboarding_data
    
    def update_onboarding_step(self, user_id: str, step: int) -> bool:
        """
        Update user's current onboarding step
        
        Args:
            user_id: User ID
            step: Current onboarding step
            
        Returns:
            Success status
        """
        logger.info(f"Updating onboarding step for user {user_id} to step {step}")
        
        try:
            return self.user_preferences.update_onboarding_step(user_id, step)
        except Exception as e:
            logger.error(f"Error updating onboarding step: {str(e)}")
            return False
    
    def get_detailed_user_profile(self, user_id: str) -> Dict[str, Any]:
        """
        Get detailed user profile with completion status and preferences
        
        Args:
            user_id: User ID
            
        Returns:
            Detailed user profile dictionary
            
        Raises:
            UserNotFoundError: If user not found
        """
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        # Get MongoDB preferences
        try:
            preferences = self.user_preferences.get_user_preferences(user_id)
        except Exception as e:
            logger.warning(f"Failed to get MongoDB preferences for user {user_id}: {str(e)}")
            preferences = {}
        
        # Calculate profile completion
        completion_percentage = self._calculate_profile_completion(user, preferences)
        
        # Build detailed response
        profile_data = user.to_dict()
        profile_data.update({
            'profile_completion_percentage': completion_percentage,
            'onboarding_completed': completion_percentage >= 80,
            'last_profile_update': user.updated_at.isoformat() if user.updated_at else None,
            'custom_dietary_restrictions': preferences.get('custom_dietary_restrictions', []),
            'allergies': preferences.get('allergies', []),
            'cooking_frequency': preferences.get('cooking_frequency'),
            'kitchen_equipment': preferences.get('kitchen_equipment', [])
        })
        
        return profile_data
    
    def update_user_profile_enhanced(self, user_id: str, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Enhanced profile update with change tracking and granular control
        
        Args:
            user_id: User ID
            profile_data: Profile data to update
            
        Returns:
            Updated user profile
            
        Raises:
            UserNotFoundError: If user not found
            ValidationError: If validation fails
        """
        logger.info(f"Enhanced profile update for user: {user_id}")
        
        user = self.user_repository.get_user_by_id(user_id)
        if not user:
            raise UserNotFoundError("User not found")
        
        # Track changes for history
        changes_made = []
        update_source = profile_data.get('update_source', 'manual')
        
        # Update basic information
        basic_fields = ['first_name', 'last_name']
        postgresql_updates = {}
        
        for field in basic_fields:
            if field in profile_data and profile_data[field] is not None:
                old_value = getattr(user, field, None)
                new_value = profile_data[field]
                
                if old_value != new_value:
                    postgresql_updates[field] = new_value
                    changes_made.append({
                        'field': field,
                        'old_value': old_value,
                        'new_value': new_value,
                        'change_type': 'update'
                    })
        
        # Handle dietary restrictions with granular control
        if any(key in profile_data for key in ['dietary_restrictions', 'add_dietary_restrictions', 'remove_dietary_restrictions']):
            current_restrictions = user.dietary_restrictions_list or []
            new_restrictions = current_restrictions.copy()
            
            # Full replacement
            if 'dietary_restrictions' in profile_data:
                new_restrictions = profile_data['dietary_restrictions'] or []
            
            # Add restrictions
            if 'add_dietary_restrictions' in profile_data:
                for restriction in profile_data['add_dietary_restrictions'] or []:
                    if restriction not in new_restrictions:
                        new_restrictions.append(restriction)
            
            # Remove restrictions
            if 'remove_dietary_restrictions' in profile_data:
                for restriction in profile_data['remove_dietary_restrictions'] or []:
                    if restriction in new_restrictions:
                        new_restrictions.remove(restriction)
            
            if set(current_restrictions) != set(new_restrictions):
                postgresql_updates['dietary_restrictions_list'] = new_restrictions
                changes_made.append({
                    'field': 'dietary_restrictions',
                    'old_value': str(current_restrictions),
                    'new_value': str(new_restrictions),
                    'change_type': 'update'
                })
        
        # Handle cooking experience
        if 'cooking_experience_level' in profile_data:
            old_value = user.cooking_experience_level
            new_value = profile_data['cooking_experience_level']
            
            if old_value != new_value:
                postgresql_updates['cooking_experience_level'] = new_value
                changes_made.append({
                    'field': 'cooking_experience_level',
                    'old_value': old_value,
                    'new_value': new_value,
                    'change_type': 'update'
                })
        
        # Handle nutritional goals
        nutritional_fields = ['weight_goal', 'daily_calorie_target', 'protein_target_pct', 'carb_target_pct', 'fat_target_pct', 'dietary_program']
        current_goals = user.nutritional_goals or {}
        new_goals = current_goals.copy()
        
        goals_updated = False
        for field in nutritional_fields:
            if field in profile_data and profile_data[field] is not None:
                old_value = current_goals.get(field)
                new_value = profile_data[field]
                
                if old_value != new_value:
                    new_goals[field] = new_value
                    goals_updated = True
                    changes_made.append({
                        'field': f'nutritional_goals.{field}',
                        'old_value': str(old_value),
                        'new_value': str(new_value),
                        'change_type': 'update'
                    })
        
        if goals_updated:
            postgresql_updates['nutritional_goals'] = new_goals
        
        # Handle budget information
        budget_fields = ['budget_period', 'budget_amount', 'currency', 'price_per_meal_min', 'price_per_meal_max']
        current_budget = user.budget_info or {}
        new_budget = current_budget.copy()
        
        budget_updated = False
        for field in budget_fields:
            if field in profile_data and profile_data[field] is not None:
                budget_key = field.replace('budget_', '') if field.startswith('budget_') else field
                old_value = current_budget.get(budget_key)
                new_value = profile_data[field]
                
                if old_value != new_value:
                    new_budget[budget_key] = new_value
                    budget_updated = True
                    changes_made.append({
                        'field': f'budget_info.{budget_key}',
                        'old_value': str(old_value),
                        'new_value': str(new_value),
                        'change_type': 'update'
                    })
        
        if budget_updated:
            postgresql_updates['budget_info'] = new_budget
        
        # Update PostgreSQL user data
        if postgresql_updates:
            for field, value in postgresql_updates.items():
                setattr(user, field, value)
            
            updated_user = self.user_repository.update_user(user)
            logger.info(f"PostgreSQL user data updated for user: {user_id}")
        else:
            updated_user = user
        
        # Handle MongoDB preferences updates
        mongodb_updates = {}
        mongodb_fields = ['custom_dietary_restrictions', 'allergies', 'cooking_frequency', 'kitchen_equipment']
        
        for field in mongodb_fields:
            if field in profile_data:
                mongodb_updates[field] = profile_data[field]
        
        # Handle kitchen equipment granular updates
        if any(key in profile_data for key in ['add_kitchen_equipment', 'remove_kitchen_equipment']):
            try:
                current_prefs = self.user_preferences.get_user_preferences(user_id)
                current_equipment = current_prefs.get('kitchen_equipment', [])
                new_equipment = current_equipment.copy()
                
                # Add equipment
                if 'add_kitchen_equipment' in profile_data:
                    for equipment in profile_data['add_kitchen_equipment'] or []:
                        if equipment not in new_equipment:
                            new_equipment.append(equipment)
                
                # Remove equipment
                if 'remove_kitchen_equipment' in profile_data:
                    for equipment in profile_data['remove_kitchen_equipment'] or []:
                        if equipment in new_equipment:
                            new_equipment.remove(equipment)
                
                if set(current_equipment) != set(new_equipment):
                    mongodb_updates['kitchen_equipment'] = new_equipment
                    changes_made.append({
                        'field': 'kitchen_equipment',
                        'old_value': str(current_equipment),
                        'new_value': str(new_equipment),
                        'change_type': 'update'
                    })
            except Exception as e:
                logger.warning(f"Failed to get current kitchen equipment: {str(e)}")
        
        # Update MongoDB preferences
        if mongodb_updates:
            try:
                success = self.user_preferences.update_user_preferences(user_id, mongodb_updates)
                if success:
                    logger.info(f"MongoDB preferences updated for user: {user_id}")
                else:
                    logger.warning(f"Failed to update MongoDB preferences for user: {user_id}")
            except Exception as e:
                logger.error(f"Error updating MongoDB preferences: {str(e)}")
        
        # Record changes in history
        for change in changes_made:
            self._record_profile_change(
                user_id=user_id,
                field_changed=change['field'],
                old_value=change['old_value'],
                new_value=change['new_value'],
                change_type=change['change_type'],
                source=update_source
            )
        
        logger.info(f"Profile update completed for user: {user_id}, {len(changes_made)} changes made")
        
        # Return updated profile
        return self.get_detailed_user_profile(user_id)
    
    def update_profile_section(self, user_id: str, section: str, section_data: Dict[str, Any], update_source: str = 'manual') -> Dict[str, Any]:
        """
        Update a specific profile section
        
        Args:
            user_id: User ID
            section: Profile section (dietary, budget, cooking, nutritional, personal)
            section_data: Section-specific data
            update_source: Source of the update
            
        Returns:
            Updated user profile
        """
        logger.info(f"Updating profile section '{section}' for user: {user_id}")
        
        # Map section to appropriate fields
        if section == 'dietary':
            mapped_data = {
                'dietary_restrictions': section_data.get('dietary_restrictions'),
                'custom_dietary_restrictions': section_data.get('custom_dietary_restrictions'),
                'allergies': section_data.get('allergies'),
                'update_source': update_source
            }
        elif section == 'budget':
            mapped_data = {
                'budget_period': section_data.get('budget_period'),
                'budget_amount': section_data.get('budget_amount'),
                'currency': section_data.get('currency'),
                'price_per_meal_min': section_data.get('price_per_meal_min'),
                'price_per_meal_max': section_data.get('price_per_meal_max'),
                'update_source': update_source
            }
        elif section == 'cooking':
            mapped_data = {
                'cooking_experience_level': section_data.get('cooking_experience_level'),
                'cooking_frequency': section_data.get('cooking_frequency'),
                'kitchen_equipment': section_data.get('kitchen_equipment'),
                'update_source': update_source
            }
        elif section == 'nutritional':
            mapped_data = {
                'weight_goal': section_data.get('weight_goal'),
                'daily_calorie_target': section_data.get('daily_calorie_target'),
                'protein_target_pct': section_data.get('protein_target_pct'),
                'carb_target_pct': section_data.get('carb_target_pct'),
                'fat_target_pct': section_data.get('fat_target_pct'),
                'dietary_program': section_data.get('dietary_program'),
                'update_source': update_source
            }
        elif section == 'personal':
            mapped_data = {
                'first_name': section_data.get('first_name'),
                'last_name': section_data.get('last_name'),
                'update_source': update_source
            }
        else:
            raise ValidationError(f"Unknown profile section: {section}")
        
        # Remove None values
        mapped_data = {k: v for k, v in mapped_data.items() if v is not None}
        
        return self.update_user_profile_enhanced(user_id, mapped_data)
    
    def get_profile_change_history(self, user_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get profile change history for a user
        
        Args:
            user_id: User ID
            limit: Maximum number of changes to return
            
        Returns:
            List of profile changes
        """
        user_changes = [
            change for change in self._change_history 
            if change['user_id'] == user_id
        ]
        
        # Sort by timestamp descending
        user_changes.sort(key=lambda x: x['timestamp'], reverse=True)
        
        return user_changes[:limit]
    
    def _calculate_profile_completion(self, user: User, preferences: Dict[str, Any]) -> int:
        """Calculate profile completion percentage"""
        total_fields = 0
        completed_fields = 0
        
        # Basic information (20% weight)
        basic_fields = ['first_name', 'last_name', 'email']
        for field in basic_fields:
            total_fields += 1
            if hasattr(user, field) and getattr(user, field):
                completed_fields += 1
        
        # Dietary information (30% weight)
        dietary_weight = 3
        total_fields += dietary_weight
        if user.dietary_restrictions_list:
            completed_fields += dietary_weight
        
        # Cooking information (25% weight)
        cooking_weight = 2.5
        total_fields += cooking_weight
        if user.cooking_experience_level:
            completed_fields += cooking_weight
        
        # Budget information (15% weight)
        budget_weight = 1.5
        total_fields += budget_weight
        if user.budget_info and user.budget_info.get('amount'):
            completed_fields += budget_weight
        
        # Nutritional goals (10% weight)
        nutritional_weight = 1
        total_fields += nutritional_weight
        if user.nutritional_goals and user.nutritional_goals.get('weight_goal'):
            completed_fields += nutritional_weight
        
        return int((completed_fields / total_fields) * 100) if total_fields > 0 else 0
    
    def _record_profile_change(self, user_id: str, field_changed: str, old_value: str, 
                             new_value: str, change_type: str, source: str) -> None:
        """Record a profile change in history"""
        import uuid
        
        change_record = {
            'id': str(uuid.uuid4()),
            'user_id': user_id,
            'field_changed': field_changed,
            'old_value': old_value,
            'new_value': new_value,
            'change_type': change_type,
            'timestamp': datetime.utcnow().isoformat(),
            'source': source
        }
        
        self._change_history.append(change_record)
        
        # Keep only last 1000 changes per user (memory management)
        user_changes = [c for c in self._change_history if c['user_id'] == user_id]
        if len(user_changes) > 1000:
            # Remove oldest changes for this user
            user_changes.sort(key=lambda x: x['timestamp'])
            changes_to_remove = user_changes[:-1000]
            for change in changes_to_remove:
                self._change_history.remove(change)
        
        logger.debug(f"Recorded profile change for user {user_id}: {field_changed} changed from '{old_value}' to '{new_value}'") 