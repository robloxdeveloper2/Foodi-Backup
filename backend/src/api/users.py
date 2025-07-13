"""
User API Endpoints
Handles user registration, authentication, and profile management
"""

import logging
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from pydantic import ValidationError as PydanticValidationError

from api.schemas.user_schemas import (
    UserRegistrationRequest, UserLoginRequest, SocialLoginRequest,
    UserProfileUpdateRequest, EmailVerificationRequest,
    AuthResponse, UserResponse, ProfileSetupRequest, ProfileDataResponse,
    EnhancedProfileUpdateRequest, ProfileSectionUpdateRequest, 
    DetailedProfileResponse, ProfileChangeHistoryResponse
)
from services.user_service import UserService
from core.exceptions import AppError

logger = logging.getLogger(__name__)

# Create Blueprint
users_bp = Blueprint('users', __name__)

# Initialize services
user_service = UserService()

# Rate limiting decorator
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@users_bp.route('/register', methods=['POST'])
@limiter.limit("5 per minute")
def register():
    """
    Register a new user
    
    Expected JSON body:
    {
        "username": "string",
        "email": "string",
        "password": "string",
        "first_name": "string (optional)",
        "last_name": "string (optional)"
    }
    """
    try:
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            registration_data = UserRegistrationRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Register user
        result = user_service.register_user(
            username=registration_data.username,
            email=registration_data.email,
            password=registration_data.password,
            first_name=registration_data.first_name,
            last_name=registration_data.last_name
        )
        
        # Create response
        response_data = AuthResponse(
            success=True,
            message=result['message'],
            user=UserResponse(**result['user']),
            access_token=result['access_token'],
            expires_in=3600
        )
        
        logger.info(f"User registration successful: {result['user']['id']}")
        
        return jsonify(response_data.dict()), 201
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in user registration: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/login', methods=['POST'])
@limiter.limit("10 per minute")
def login():
    """
    Authenticate user with email and password
    
    Expected JSON body:
    {
        "email": "string",
        "password": "string"
    }
    """
    try:
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            login_data = UserLoginRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Authenticate user
        result = user_service.authenticate_user(
            email=login_data.email,
            password=login_data.password
        )
        
        # Create response
        response_data = AuthResponse(
            success=True,
            message=result['message'],
            user=UserResponse(**result['user']),
            access_token=result['access_token'],
            expires_in=3600
        )
        
        logger.info(f"User login successful: {result['user']['id']}")
        
        return jsonify(response_data.dict()), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in user login: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/social-login', methods=['POST'])
@limiter.limit("10 per minute")
def social_login():
    """
    Social login with Google or Apple
    
    Expected JSON body:
    {
        "provider": "google|apple",
        "access_token": "string",
        "email": "string (optional)",
        "first_name": "string (optional)",
        "last_name": "string (optional)"
    }
    """
    try:
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            social_data = SocialLoginRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Perform social login
        result = user_service.social_login(
            provider=social_data.provider,
            access_token=social_data.access_token,
            email=social_data.email,
            first_name=social_data.first_name,
            last_name=social_data.last_name
        )
        
        # Create response
        response_data = AuthResponse(
            success=True,
            message=result['message'],
            user=UserResponse(**result['user']),
            access_token=result['access_token'],
            expires_in=3600
        )
        
        logger.info(f"Social login successful: {result['user']['id']}")
        
        return jsonify(response_data.dict()), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in social login: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/verify-email', methods=['POST'])
@limiter.limit("5 per minute")
def verify_email():
    """
    Verify user email with verification token
    
    Expected JSON body:
    {
        "token": "string"
    }
    """
    try:
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            verification_data = EmailVerificationRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Verify email
        success = user_service.verify_email(verification_data.token)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Email verified successfully'
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'InvalidTokenError',
                    'message': 'Invalid verification token'
                }
            }), 400
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in email verification: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """
    Get current user's profile
    Requires JWT token in Authorization header
    """
    try:
        user_id = get_jwt_identity()
        
        # Get user profile
        user_data = user_service.get_user_profile(user_id)
        
        # Create response
        response_data = UserResponse(**user_data)
        
        return jsonify({
            'success': True,
            'user': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error getting user profile: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile', methods=['PUT'])
@jwt_required()
@limiter.limit("20 per hour")
def update_profile():
    """
    Update current user's profile
    Requires JWT token in Authorization header
    
    Expected JSON body:
    {
        "first_name": "string (optional)",
        "last_name": "string (optional)",
        "dietary_restrictions": ["string"] (optional),
        "cooking_experience_level": "string (optional)",
        "nutritional_goals": {} (optional),
        "budget_info": {} (optional)
    }
    """
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            profile_data = UserProfileUpdateRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Update user profile
        updated_user = user_service.update_user_profile(
            user_id, 
            profile_data.dict(exclude_unset=True)
        )
        
        # Create response
        response_data = UserResponse(**updated_user)
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'user': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error updating user profile: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/test-user', methods=['POST'])
def create_test_user():
    """
    Create a test user for easy testing (as mentioned in story requirements)
    This endpoint should be disabled in production
    """
    try:
        # Generate test user credentials
        import uuid
        test_id = str(uuid.uuid4())[:8]
        
        test_username = f"testuser_{test_id}"
        test_email = f"test_{test_id}@foodi.test"
        test_password = "TestPass123"
        
        # Register test user
        result = user_service.register_user(
            username=test_username,
            email=test_email,
            password=test_password,
            first_name="Test",
            last_name="User"
        )
        
        # Auto-verify test user
        user_id = result['user']['id']
        from data_access.user_repository import UserRepository
        repo = UserRepository()
        user = repo.get_user_by_id(user_id)
        user.email_verified = True
        repo.update_user(user)
        
        return jsonify({
            'success': True,
            'message': 'Test user created successfully',
            'credentials': {
                'username': test_username,
                'email': test_email,
                'password': test_password
            },
            'access_token': result['access_token']
        }), 201
        
    except Exception as e:
        logger.error(f"Error creating test user: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'Failed to create test user'
            }
        }), 500

@users_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'success': True,
        'message': 'User service is healthy',
        'service': 'users'
    }), 200

@users_bp.route('/profile/setup-data', methods=['GET'])
def get_profile_setup_data():
    """
    Get predefined data for profile setup (dietary restrictions, experience levels, etc.)
    Public endpoint - no authentication required for setup options
    """
    try:
        # Get predefined setup data
        setup_data = user_service.get_profile_setup_data()
        
        # Create response
        response_data = ProfileDataResponse(**setup_data)
        
        return jsonify({
            'success': True,
            'data': response_data.dict()
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting profile setup data: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'Failed to get profile setup data'
            }
        }), 500

@users_bp.route('/profile/setup', methods=['POST'])
@jwt_required()
@limiter.limit("10 per hour")
def setup_profile():
    """
    Complete comprehensive profile setup during onboarding
    Requires JWT token in Authorization header
    
    Expected JSON body:
    {
        "dietary_restrictions": ["string"] (optional),
        "custom_dietary_restrictions": ["string"] (optional),
        "allergies": ["string"] (optional),
        "budget_period": "weekly|monthly" (optional),
        "budget_amount": float (optional),
        "currency": "USD|EUR|GBP|CAD" (optional),
        "price_per_meal_min": float (optional),
        "price_per_meal_max": float (optional),
        "cooking_experience_level": "beginner|intermediate|advanced" (optional),
        "cooking_frequency": "string" (optional),
        "kitchen_equipment": ["string"] (optional),
        "weight_goal": "lose|maintain|gain" (optional),
        "daily_calorie_target": int (optional),
        "protein_target_pct": float (optional),
        "carb_target_pct": float (optional),
        "fat_target_pct": float (optional),
        "dietary_program": "string" (optional)
    }
    """
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            profile_setup = ProfileSetupRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Setup user profile
        result = user_service.setup_user_profile(
            user_id, 
            profile_setup.dict(exclude_unset=True)
        )
        
        # Create response
        response_data = UserResponse(**result['user'])
        
        logger.info(f"Profile setup completed for user: {user_id}")
        
        return jsonify({
            'success': True,
            'message': result['message'],
            'user': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in profile setup: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/onboarding/status', methods=['GET'])
@jwt_required()
def get_onboarding_status():
    """
    Get user's onboarding/profile setup status
    Requires JWT token in Authorization header
    """
    try:
        user_id = get_jwt_identity()
        
        # Get onboarding status
        status_data = user_service.get_user_onboarding_status(user_id)
        
        return jsonify({
            'success': True,
            'status': status_data
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Error getting onboarding status: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'Failed to get onboarding status'
            }
        }), 500

@users_bp.route('/onboarding/step', methods=['PUT'])
@jwt_required()
@limiter.limit("30 per hour")
def update_onboarding_step():
    """
    Update user's current onboarding step
    Requires JWT token in Authorization header
    
    Expected JSON body:
    {
        "step": int
    }
    """
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data or 'step' not in data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Step number is required'
                }
            }), 400
        
        step = data['step']
        if not isinstance(step, int) or step < 0:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Step must be a non-negative integer'
                }
            }), 400
        
        # Update onboarding step
        success = user_service.update_onboarding_step(user_id, step)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Onboarding step updated successfully'
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'UpdateFailedError',
                    'message': 'Failed to update onboarding step'
                }
            }), 500
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Error updating onboarding step: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile/detailed', methods=['GET'])
@jwt_required()
def get_detailed_profile():
    """
    Get detailed user profile with completion status and preferences
    Requires JWT token in Authorization header
    
    Returns enhanced profile information including:
    - Basic user information
    - Profile completion percentage
    - All dietary, cooking, budget, and nutritional data
    - MongoDB preferences
    """
    try:
        user_id = get_jwt_identity()
        
        # Get detailed user profile
        profile_data = user_service.get_detailed_user_profile(user_id)
        
        # Create response
        response_data = DetailedProfileResponse(**profile_data)
        
        return jsonify({
            'success': True,
            'profile': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error getting detailed user profile: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile/enhanced', methods=['PUT'])
@jwt_required()
@limiter.limit("20 per hour")
def update_profile_enhanced():
    """
    Enhanced profile update with granular control and change tracking
    Requires JWT token in Authorization header
    
    Supports:
    - Add/remove items from lists (dietary restrictions, kitchen equipment)
    - Section-specific updates
    - Change history tracking
    - Real-time validation
    
    Expected JSON body: EnhancedProfileUpdateRequest schema
    """
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            profile_data = EnhancedProfileUpdateRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Update user profile with enhanced capabilities
        updated_profile = user_service.update_user_profile_enhanced(
            user_id, 
            profile_data.dict(exclude_unset=True)
        )
        
        # Create response
        response_data = DetailedProfileResponse(**updated_profile)
        
        return jsonify({
            'success': True,
            'message': 'Profile updated successfully',
            'profile': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error in enhanced profile update: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile/section', methods=['PUT'])
@jwt_required()
@limiter.limit("30 per hour")
def update_profile_section():
    """
    Update a specific profile section
    Requires JWT token in Authorization header
    
    Useful for updating individual sections like dietary preferences,
    budget information, etc. without affecting other sections.
    
    Expected JSON body: ProfileSectionUpdateRequest schema
    """
    try:
        user_id = get_jwt_identity()
        
        # Get JSON data
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Request body must be valid JSON'
                }
            }), 400
        
        # Validate request data
        try:
            section_update = ProfileSectionUpdateRequest(**data)
        except PydanticValidationError as e:
            return jsonify({
                'success': False,
                'error': {
                    'code': 'ValidationError',
                    'message': 'Validation failed',
                    'details': e.errors()
                }
            }), 400
        
        # Update profile section
        updated_profile = user_service.update_profile_section(
            user_id=user_id,
            section=section_update.section,
            section_data=section_update.data,
            update_source=section_update.update_source
        )
        
        # Create response
        response_data = DetailedProfileResponse(**updated_profile)
        
        return jsonify({
            'success': True,
            'message': f'Profile section "{section_update.section}" updated successfully',
            'profile': response_data.dict()
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error updating profile section: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500

@users_bp.route('/profile/history', methods=['GET'])
@jwt_required()
def get_profile_change_history():
    """
    Get profile change history for the current user
    Requires JWT token in Authorization header
    
    Query parameters:
    - limit: Maximum number of changes to return (default: 50, max: 100)
    """
    try:
        user_id = get_jwt_identity()
        
        # Get limit from query parameters
        limit = request.args.get('limit', 50, type=int)
        limit = min(limit, 100)  # Cap at 100
        
        # Get change history
        change_history = user_service.get_profile_change_history(user_id, limit)
        
        # Create response
        history_responses = [
            ProfileChangeHistoryResponse(**change) for change in change_history
        ]
        
        return jsonify({
            'success': True,
            'changes': [change.dict() for change in history_responses],
            'total_returned': len(history_responses)
        }), 200
        
    except AppError as e:
        # Custom application errors are handled by error handlers
        raise
    except Exception as e:
        logger.error(f"Unexpected error getting profile change history: {str(e)}")
        return jsonify({
            'success': False,
            'error': {
                'code': 'InternalServerError',
                'message': 'An unexpected error occurred'
            }
        }), 500 