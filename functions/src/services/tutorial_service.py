"""
Tutorial Service
Business logic for tutorial management, search, and progress tracking
"""

import logging
from typing import List, Dict, Any, Optional, NamedTuple
from dataclasses import dataclass
from sqlalchemy.orm import Session
import math

from core.models.tutorial import Tutorial, TutorialProgress
from core.models.user import User
from data_access.tutorial_repository import TutorialRepository, TutorialProgressRepository
from data_access.user_repository import UserRepository
from core.exceptions import ValidationError, NotFoundError
from data_access.database import db

logger = logging.getLogger(__name__)

@dataclass
class TutorialSearchResult:
    """Container for tutorial search results with pagination info"""
    tutorials: List[Tutorial]
    page: int
    limit: int
    total_count: int
    total_pages: int
    has_next: bool
    has_previous: bool
    filters_applied: Dict[str, Any]

@dataclass
class UserProgressSummary:
    """Container for user's tutorial progress summary"""
    completed_count: int
    in_progress_count: int
    total_time_minutes: int
    average_rating: Optional[float]
    completed_tutorials: List[TutorialProgress]
    in_progress_tutorials: List[TutorialProgress]

class TutorialService:
    """Service for tutorial management, search, and progress tracking"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize service with optional database session"""
        self.session = session or db.session
        self.tutorial_repository = TutorialRepository(self.session)
        self.progress_repository = TutorialProgressRepository(self.session)
        self.user_repository = UserRepository()
    
    def search_tutorials(self, search_query: str = "", filters: Optional[Dict[str, Any]] = None,
                        page: int = 1, limit: int = 20, user_id: Optional[str] = None) -> TutorialSearchResult:
        """
        Search tutorials with comprehensive filtering and pagination
        
        Args:
            search_query: Text to search for in tutorial titles, descriptions, keywords
            filters: Dictionary of filter criteria
            page: Page number (1-based)
            limit: Number of results per page
            user_id: User ID for progress information
            
        Returns:
            TutorialSearchResult with tutorials and pagination info
        """
        try:
            filters = filters or {}
            
            # Calculate pagination
            offset = (page - 1) * limit
            
            # Search tutorials
            tutorials, total_count = self.tutorial_repository.search_tutorials(
                search_term=search_query,
                filters=filters,
                limit=limit,
                offset=offset
            )
            
            # Calculate pagination info
            total_pages = math.ceil(total_count / limit) if total_count > 0 and limit > 0 else 1
            has_next = page < total_pages
            has_previous = page > 1
            
            # Enrich with user progress if user provided
            if user_id and tutorials:
                tutorials = self._enrich_with_user_progress(tutorials, user_id)
            
            logger.info(f"Tutorial search completed: {len(tutorials)} tutorials found (page {page}/{total_pages})")
            
            return TutorialSearchResult(
                tutorials=tutorials,
                page=page,
                limit=limit,
                total_count=total_count,
                total_pages=total_pages,
                has_next=has_next,
                has_previous=has_previous,
                filters_applied=filters
            )
            
        except Exception as e:
            logger.error(f"Error in tutorial search: {str(e)}")
            raise ValidationError(f"Tutorial search failed: {str(e)}")
    
    def get_tutorial_details(self, tutorial_id: int, user_id: Optional[str] = None) -> Optional[Tutorial]:
        """Get detailed information for a specific tutorial"""
        try:
            tutorial = self.tutorial_repository.get_tutorial_by_id(tutorial_id)
            
            if not tutorial:
                logger.warning(f"Tutorial not found: {tutorial_id}")
                return None
            
            # Add user progress information if user provided
            if user_id:
                progress_list = self.progress_repository.get_user_progress(user_id, tutorial_id)
                if progress_list:
                    # Add progress info to tutorial dict when converted
                    setattr(tutorial, '_user_progress', progress_list[0])
            
            logger.info(f"Tutorial details retrieved: {tutorial_id}")
            return tutorial
            
        except Exception as e:
            logger.error(f"Error getting tutorial details {tutorial_id}: {str(e)}")
            raise ValidationError(f"Failed to get tutorial details: {str(e)}")
    
    def get_tutorials_by_category(self, category: str, page: int = 1, limit: int = 20,
                                 user_id: Optional[str] = None) -> TutorialSearchResult:
        """Get tutorials filtered by category"""
        try:
            offset = (page - 1) * limit
            tutorials = self.tutorial_repository.get_tutorials_by_category(category, limit, offset)
            
            # Get total count for this category
            total_tutorials, _ = self.tutorial_repository.search_tutorials(
                search_term="",
                filters={'category': category}
            )
            total_count = len(total_tutorials)
            
            # Calculate pagination info
            total_pages = math.ceil(total_count / limit) if total_count > 0 and limit > 0 else 1
            has_next = page < total_pages
            has_previous = page > 1
            
            # Enrich with user progress if user provided
            if user_id and tutorials:
                tutorials = self._enrich_with_user_progress(tutorials, user_id)
            
            logger.info(f"Retrieved {len(tutorials)} tutorials for category: {category}")
            
            return TutorialSearchResult(
                tutorials=tutorials,
                page=page,
                limit=limit,
                total_count=total_count,
                total_pages=total_pages,
                has_next=has_next,
                has_previous=has_previous,
                filters_applied={'category': category}
            )
            
        except Exception as e:
            logger.error(f"Error getting tutorials by category {category}: {str(e)}")
            raise ValidationError(f"Failed to get tutorials by category: {str(e)}")
    
    def get_tutorial_categories(self) -> List[Dict[str, Any]]:
        """Get all available tutorial categories with counts"""
        try:
            categories = self.tutorial_repository.get_tutorial_categories()
            logger.info(f"Retrieved {len(categories)} tutorial categories")
            return categories
            
        except Exception as e:
            logger.error(f"Error getting tutorial categories: {str(e)}")
            raise ValidationError(f"Failed to get tutorial categories: {str(e)}")
    
    def get_beginner_friendly_tutorials(self, limit: int = 10, user_id: Optional[str] = None) -> List[Tutorial]:
        """Get beginner-friendly tutorials"""
        try:
            tutorials = self.tutorial_repository.get_beginner_friendly_tutorials(limit)
            
            # Enrich with user progress if user provided
            if user_id and tutorials:
                tutorials = self._enrich_with_user_progress(tutorials, user_id)
            
            logger.info(f"Retrieved {len(tutorials)} beginner-friendly tutorials")
            return tutorials
            
        except Exception as e:
            logger.error(f"Error getting beginner-friendly tutorials: {str(e)}")
            raise ValidationError(f"Failed to get beginner-friendly tutorials: {str(e)}")
    
    def get_featured_tutorials(self, limit: int = 10, user_id: Optional[str] = None) -> List[Tutorial]:
        """Get featured tutorials"""
        try:
            # First check if any tutorials exist at all
            from data_access.database import db
            tutorial_count = db.session.query(Tutorial).count()
            if tutorial_count == 0:
                logger.warning("No tutorials found in database - returning empty list")
                return []
                
            tutorials = self.tutorial_repository.get_featured_tutorials(limit)
            
            # Enrich with user progress if user provided
            if user_id and tutorials:
                tutorials = self._enrich_with_user_progress(tutorials, user_id)
            
            logger.info(f"Retrieved {len(tutorials)} featured tutorials")
            return tutorials
            
        except Exception as e:
            logger.error(f"Error getting featured tutorials: {str(e)}")
            # Return empty list instead of raising exception to prevent crash
            return []
    
    def start_tutorial(self, user_id: str, tutorial_id: int) -> TutorialProgress:
        """Start a tutorial for a user (create progress record)"""
        try:
            # Verify tutorial exists
            tutorial = self.tutorial_repository.get_tutorial_by_id(tutorial_id)
            if not tutorial:
                raise NotFoundError(f"Tutorial not found: {tutorial_id}")
            
            # Create or get existing progress
            progress = self.progress_repository.get_or_create_progress(user_id, tutorial_id)
            
            logger.info(f"Tutorial started: user {user_id}, tutorial {tutorial_id}")
            return progress
            
        except Exception as e:
            logger.error(f"Error starting tutorial: {str(e)}")
            raise ValidationError(f"Failed to start tutorial: {str(e)}")
    
    def mark_step_completed(self, user_id: str, tutorial_id: int, step_number: int) -> TutorialProgress:
        """Mark a tutorial step as completed"""
        try:
            progress = self.progress_repository.mark_step_completed(user_id, tutorial_id, step_number)
            
            logger.info(f"Step {step_number} completed: user {user_id}, tutorial {tutorial_id}")
            return progress
            
        except Exception as e:
            logger.error(f"Error marking step completed: {str(e)}")
            raise ValidationError(f"Failed to mark step completed: {str(e)}")
    
    def update_tutorial_time(self, user_id: str, tutorial_id: int, minutes: int) -> TutorialProgress:
        """Update time spent on tutorial"""
        try:
            progress = self.progress_repository.update_time_spent(user_id, tutorial_id, minutes)
            
            logger.debug(f"Updated tutorial time: user {user_id}, tutorial {tutorial_id}, +{minutes} min")
            return progress
            
        except Exception as e:
            logger.error(f"Error updating tutorial time: {str(e)}")
            raise ValidationError(f"Failed to update tutorial time: {str(e)}")
    
    def rate_tutorial(self, user_id: str, tutorial_id: int, rating: int, 
                     notes: Optional[str] = None) -> TutorialProgress:
        """Rate a tutorial"""
        try:
            if not 1 <= rating <= 5:
                raise ValidationError("Rating must be between 1 and 5")
            
            progress = self.progress_repository.set_tutorial_rating(user_id, tutorial_id, rating, notes)
            
            logger.info(f"Tutorial rated: user {user_id}, tutorial {tutorial_id}, rating {rating}")
            return progress
            
        except Exception as e:
            logger.error(f"Error rating tutorial: {str(e)}")
            raise ValidationError(f"Failed to rate tutorial: {str(e)}")
    
    def get_user_progress_summary(self, user_id: str) -> UserProgressSummary:
        """Get user's overall tutorial progress summary"""
        try:
            # Get completed tutorials
            completed = self.progress_repository.get_user_completed_tutorials(user_id)
            
            # Get in-progress tutorials
            in_progress = self.progress_repository.get_user_in_progress_tutorials(user_id)
            
            # Calculate statistics
            completed_count = len(completed)
            in_progress_count = len(in_progress)
            
            total_time_minutes = sum(p.time_spent_minutes for p in completed + in_progress)
            
            # Calculate average rating from completed tutorials with ratings
            ratings = [p.user_rating for p in completed if p.user_rating is not None]
            average_rating = sum(ratings) / len(ratings) if ratings else None
            
            logger.info(f"Progress summary for user {user_id}: {completed_count} completed, {in_progress_count} in progress")
            
            return UserProgressSummary(
                completed_count=completed_count,
                in_progress_count=in_progress_count,
                total_time_minutes=total_time_minutes,
                average_rating=average_rating,
                completed_tutorials=completed,
                in_progress_tutorials=in_progress
            )
            
        except Exception as e:
            logger.error(f"Error getting user progress summary: {str(e)}")
            raise ValidationError(f"Failed to get progress summary: {str(e)}")
    
    def get_user_tutorial_progress(self, user_id: str, tutorial_id: int) -> Optional[TutorialProgress]:
        """Get user's progress for a specific tutorial"""
        try:
            progress_list = self.progress_repository.get_user_progress(user_id, tutorial_id)
            return progress_list[0] if progress_list else None
            
        except Exception as e:
            logger.error(f"Error getting user tutorial progress: {str(e)}")
            raise ValidationError(f"Failed to get tutorial progress: {str(e)}")
    
    def create_tutorial(self, tutorial_data: Dict[str, Any]) -> Tutorial:
        """Create a new tutorial (admin function)"""
        try:
            # Validate required fields
            required_fields = ['title', 'description', 'steps', 'category', 'difficulty_level', 'estimated_duration_minutes']
            for field in required_fields:
                if field not in tutorial_data:
                    raise ValidationError(f"Missing required field: {field}")
            
            # Validate steps structure
            if not isinstance(tutorial_data['steps'], list) or not tutorial_data['steps']:
                raise ValidationError("Steps must be a non-empty list")
            
            tutorial = self.tutorial_repository.create_tutorial(tutorial_data)
            
            logger.info(f"Tutorial created: {tutorial.id} - {tutorial.title}")
            return tutorial
            
        except Exception as e:
            logger.error(f"Error creating tutorial: {str(e)}")
            raise ValidationError(f"Failed to create tutorial: {str(e)}")
    
    def get_recommended_tutorials_for_user(self, user_id: str, limit: int = 10) -> List[Tutorial]:
        """Get personalized tutorial recommendations for user"""
        try:
            # Basic recommendation logic - can be enhanced with ML later
            user_progress = self.get_user_progress_summary(user_id)
            
            # If user is new, recommend beginner-friendly tutorials
            if user_progress.completed_count == 0:
                return self.get_beginner_friendly_tutorials(limit, user_id)
            
            # If user has some experience, recommend featured tutorials
            return self.get_featured_tutorials(limit, user_id)
            
        except Exception as e:
            logger.error(f"Error getting recommendations for user {user_id}: {str(e)}")
            # Fallback to featured tutorials
            return self.get_featured_tutorials(limit, user_id)
    
    def _enrich_with_user_progress(self, tutorials: List[Tutorial], user_id: str) -> List[Tutorial]:
        """Enrich tutorials with user progress information"""
        try:
            # Get all user progress in one query
            all_progress = self.progress_repository.get_user_progress(user_id)
            
            # Create a mapping of tutorial_id to progress
            progress_map = {p.tutorial_id: p for p in all_progress}
            
            # Add progress info to tutorials
            for tutorial in tutorials:
                if tutorial.id in progress_map:
                    setattr(tutorial, '_user_progress', progress_map[tutorial.id])
            
            return tutorials
            
        except Exception as e:
            logger.warning(f"Failed to enrich tutorials with user progress: {str(e)}")
            return tutorials
    
    def get_filter_options(self) -> Dict[str, List[str]]:
        """Get available filter options for tutorial search"""
        try:
            # Get categories
            categories = [cat['category'] for cat in self.get_tutorial_categories()]
            
            # Define available difficulty levels
            difficulty_levels = ['beginner', 'intermediate', 'advanced']
            
            # Define duration options (in minutes)
            duration_options = [15, 30, 60, 120]  # Up to 15min, 30min, 1hr, 2hr
            
            return {
                'categories': categories,
                'difficulty_levels': difficulty_levels,
                'duration_options': duration_options
            }
            
        except Exception as e:
            logger.error(f"Error getting filter options: {str(e)}")
            raise ValidationError(f"Failed to get filter options: {str(e)}") 