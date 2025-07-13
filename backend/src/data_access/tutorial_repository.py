"""
Tutorial Repository
Data access layer for Tutorial and TutorialProgress model operations
"""

import logging
from typing import Optional, List, Dict, Any, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc, func

from core.models.tutorial import Tutorial, TutorialProgress
from core.exceptions import ValidationError, NotFoundError
from data_access.database import db

logger = logging.getLogger(__name__)

class TutorialRepository:
    """Repository for Tutorial data access operations"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize repository with optional session"""
        self.session = session or db.session
    
    def create_tutorial(self, tutorial_data: Dict[str, Any]) -> Tutorial:
        """Create a new tutorial"""
        try:
            tutorial = Tutorial(
                title=tutorial_data['title'],
                description=tutorial_data['description'],
                steps=tutorial_data['steps'],
                category=tutorial_data['category'],
                difficulty_level=tutorial_data['difficulty_level'],
                estimated_duration_minutes=tutorial_data['estimated_duration_minutes'],
                subcategory=tutorial_data.get('subcategory'),
                skill_level_required=tutorial_data.get('skill_level_required'),
                thumbnail_url=tutorial_data.get('thumbnail_url'),
                video_url=tutorial_data.get('video_url'),
                learning_objectives=tutorial_data.get('learning_objectives', []),
                prerequisites=tutorial_data.get('prerequisites', []),
                equipment_needed=tutorial_data.get('equipment_needed', []),
                tags=tutorial_data.get('tags', []),
                keywords=tutorial_data.get('keywords', []),
                is_beginner_friendly=tutorial_data.get('is_beginner_friendly', False),
                is_featured=tutorial_data.get('is_featured', False)
            )
            
            self.session.add(tutorial)
            self.session.commit()
            
            logger.info(f"Tutorial created successfully: {tutorial.id}")
            return tutorial
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error creating tutorial: {str(e)}")
            raise ValidationError(f"Failed to create tutorial: {str(e)}")
    
    def get_tutorial_by_id(self, tutorial_id: int) -> Optional[Tutorial]:
        """Get tutorial by ID"""
        try:
            tutorial = self.session.query(Tutorial).filter_by(id=tutorial_id, is_active=True).first()
            if tutorial:
                logger.debug(f"Tutorial found: {tutorial_id}")
                # Increment view count
                tutorial.increment_view_count()
                self.session.commit()
            else:
                logger.debug(f"Tutorial not found: {tutorial_id}")
            return tutorial
            
        except Exception as e:
            logger.error(f"Error getting tutorial {tutorial_id}: {str(e)}")
            raise ValidationError(f"Failed to get tutorial: {str(e)}")
    
    def get_tutorials_by_category(self, category: str, limit: Optional[int] = None, 
                                offset: Optional[int] = None) -> List[Tutorial]:
        """Get tutorials by category"""
        try:
            query = self.session.query(Tutorial).filter(
                and_(Tutorial.category == category, Tutorial.is_active == True)
            ).order_by(desc(Tutorial.is_featured), Tutorial.title)
            
            if offset:
                query = query.offset(offset)
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            logger.debug(f"Found {len(tutorials)} tutorials for category: {category}")
            return tutorials
            
        except Exception as e:
            logger.error(f"Error getting tutorials by category {category}: {str(e)}")
            raise ValidationError(f"Failed to get tutorials: {str(e)}")
    
    def get_tutorials_by_difficulty(self, difficulty_level: str, limit: Optional[int] = None) -> List[Tutorial]:
        """Get tutorials by difficulty level"""
        try:
            query = self.session.query(Tutorial).filter(
                and_(Tutorial.difficulty_level == difficulty_level, Tutorial.is_active == True)
            ).order_by(desc(Tutorial.is_featured), Tutorial.title)
            
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            logger.debug(f"Found {len(tutorials)} tutorials for difficulty: {difficulty_level}")
            return tutorials
            
        except Exception as e:
            logger.error(f"Error getting tutorials by difficulty {difficulty_level}: {str(e)}")
            raise ValidationError(f"Failed to get tutorials: {str(e)}")
    
    def get_beginner_friendly_tutorials(self, limit: Optional[int] = None) -> List[Tutorial]:
        """Get beginner-friendly tutorials"""
        try:
            query = self.session.query(Tutorial).filter(
                and_(Tutorial.is_beginner_friendly == True, Tutorial.is_active == True)
            ).order_by(desc(Tutorial.is_featured), Tutorial.view_count.desc())
            
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            logger.debug(f"Found {len(tutorials)} beginner-friendly tutorials")
            return tutorials
            
        except Exception as e:
            logger.error(f"Error getting beginner-friendly tutorials: {str(e)}")
            raise ValidationError(f"Failed to get beginner-friendly tutorials: {str(e)}")
    
    def get_featured_tutorials(self, limit: Optional[int] = None) -> List[Tutorial]:
        """Get featured tutorials"""
        try:
            query = self.session.query(Tutorial).filter(
                and_(Tutorial.is_featured == True, Tutorial.is_active == True)
            ).order_by(Tutorial.view_count.desc())
            
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            logger.debug(f"Found {len(tutorials)} featured tutorials")
            return tutorials
            
        except Exception as e:
            self.session.rollback()  # Ensure transaction is rolled back on error
            logger.error(f"Error getting featured tutorials: {str(e)}")
            raise ValidationError(f"Failed to get featured tutorials: {str(e)}")
    
    def search_tutorials(self, search_term: str, filters: Optional[Dict[str, Any]] = None,
                        limit: Optional[int] = None, offset: Optional[int] = None) -> Tuple[List[Tutorial], int]:
        """Search tutorials by title, description, or keywords"""
        try:
            # Base query with search term
            query = self.session.query(Tutorial).filter(Tutorial.is_active == True)
            
            if search_term:
                # Text search in title, description, and tags
                search_filter = or_(
                    Tutorial.title.ilike(f"%{search_term}%"),
                    Tutorial.description.ilike(f"%{search_term}%"),
                    Tutorial.keywords.astext.ilike(f"%{search_term}%"),
                    Tutorial.tags.astext.ilike(f"%{search_term}%")
                )
                query = query.filter(search_filter)
            
            # Apply additional filters if provided
            if filters:
                if 'category' in filters and filters['category']:
                    query = query.filter(Tutorial.category == filters['category'])
                
                if 'difficulty' in filters and filters['difficulty']:
                    query = query.filter(Tutorial.difficulty_level == filters['difficulty'])
                
                if 'duration_max_minutes' in filters and filters['duration_max_minutes']:
                    query = query.filter(Tutorial.estimated_duration_minutes <= filters['duration_max_minutes'])
                
                if 'beginner_friendly' in filters and filters['beginner_friendly'] is not None:
                    query = query.filter(Tutorial.is_beginner_friendly == filters['beginner_friendly'])
            
            # Get total count before pagination
            total_count = query.count()
            
            # Apply pagination and ordering
            query = query.order_by(desc(Tutorial.is_featured), Tutorial.view_count.desc())
            
            if offset:
                query = query.offset(offset)
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            
            logger.debug(f"Found {len(tutorials)} tutorials matching search: {search_term}")
            return tutorials, total_count
            
        except Exception as e:
            logger.error(f"Error searching tutorials: {str(e)}")
            raise ValidationError(f"Failed to search tutorials: {str(e)}")
    
    def get_all_tutorials(self, limit: Optional[int] = None, offset: Optional[int] = None) -> Tuple[List[Tutorial], int]:
        """Get all active tutorials with pagination"""
        try:
            query = self.session.query(Tutorial).filter(Tutorial.is_active == True)
            
            # Get total count
            total_count = query.count()
            
            # Apply pagination and ordering
            query = query.order_by(desc(Tutorial.is_featured), Tutorial.created_at.desc())
            
            if offset:
                query = query.offset(offset)
            if limit:
                query = query.limit(limit)
            
            tutorials = query.all()
            logger.debug(f"Retrieved {len(tutorials)} tutorials (page)")
            return tutorials, total_count
            
        except Exception as e:
            logger.error(f"Error getting all tutorials: {str(e)}")
            raise ValidationError(f"Failed to get tutorials: {str(e)}")
    
    def get_tutorial_categories(self) -> List[Dict[str, Any]]:
        """Get all tutorial categories with counts"""
        try:
            categories = self.session.query(
                Tutorial.category,
                func.count(Tutorial.id).label('count')
            ).filter(Tutorial.is_active == True).group_by(Tutorial.category).all()
            
            result = [
                {'category': category, 'count': count}
                for category, count in categories
            ]
            
            logger.debug(f"Found {len(result)} tutorial categories")
            return result
            
        except Exception as e:
            logger.error(f"Error getting tutorial categories: {str(e)}")
            raise ValidationError(f"Failed to get tutorial categories: {str(e)}")
    
    def update_tutorial(self, tutorial_id: int, update_data: Dict[str, Any]) -> Tutorial:
        """Update tutorial"""
        try:
            tutorial = self.get_tutorial_by_id(tutorial_id)
            if not tutorial:
                raise NotFoundError(f"Tutorial not found: {tutorial_id}")
            
            # Update fields
            for field, value in update_data.items():
                if hasattr(tutorial, field):
                    setattr(tutorial, field, value)
            
            self.session.commit()
            logger.info(f"Tutorial updated successfully: {tutorial_id}")
            return tutorial
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error updating tutorial {tutorial_id}: {str(e)}")
            raise ValidationError(f"Failed to update tutorial: {str(e)}")
    
    def delete_tutorial(self, tutorial_id: int) -> bool:
        """Soft delete tutorial (mark as inactive)"""
        try:
            tutorial = self.get_tutorial_by_id(tutorial_id)
            if not tutorial:
                raise NotFoundError(f"Tutorial not found: {tutorial_id}")
            
            tutorial.is_active = False
            self.session.commit()
            
            logger.info(f"Tutorial deleted successfully: {tutorial_id}")
            return True
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error deleting tutorial {tutorial_id}: {str(e)}")
            raise ValidationError(f"Failed to delete tutorial: {str(e)}")


class TutorialProgressRepository:
    """Repository for TutorialProgress data access operations"""
    
    def __init__(self, session: Optional[Session] = None):
        """Initialize repository with optional session"""
        self.session = session or db.session
    
    def get_or_create_progress(self, user_id: str, tutorial_id: int) -> TutorialProgress:
        """Get existing progress or create new one"""
        try:
            progress = self.session.query(TutorialProgress).filter_by(
                user_id=user_id, tutorial_id=tutorial_id
            ).first()
            
            if not progress:
                progress = TutorialProgress(user_id=user_id, tutorial_id=tutorial_id)
                self.session.add(progress)
                self.session.commit()
                logger.info(f"Created tutorial progress: user {user_id}, tutorial {tutorial_id}")
            
            return progress
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error getting/creating tutorial progress: {str(e)}")
            raise ValidationError(f"Failed to get tutorial progress: {str(e)}")
    
    def get_user_progress(self, user_id: str, tutorial_id: Optional[int] = None) -> List[TutorialProgress]:
        """Get user's tutorial progress"""
        try:
            query = self.session.query(TutorialProgress).filter_by(user_id=user_id)
            
            if tutorial_id:
                query = query.filter_by(tutorial_id=tutorial_id)
            
            progress_list = query.all()
            logger.debug(f"Found {len(progress_list)} progress records for user {user_id}")
            return progress_list
            
        except Exception as e:
            logger.error(f"Error getting user progress: {str(e)}")
            raise ValidationError(f"Failed to get user progress: {str(e)}")
    
    def mark_step_completed(self, user_id: str, tutorial_id: int, step_number: int) -> TutorialProgress:
        """Mark a tutorial step as completed"""
        try:
            progress = self.get_or_create_progress(user_id, tutorial_id)
            
            # Get tutorial to know total step count
            tutorial = self.session.query(Tutorial).filter_by(id=tutorial_id).first()
            if not tutorial:
                raise NotFoundError(f"Tutorial not found: {tutorial_id}")
            
            progress.mark_step_completed(step_number, tutorial.step_count)
            
            # If tutorial is completed, increment tutorial completion count
            if progress.is_completed and progress.completed_at:
                tutorial.increment_completion_count()
            
            self.session.commit()
            logger.info(f"Step {step_number} marked completed for user {user_id}, tutorial {tutorial_id}")
            return progress
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error marking step completed: {str(e)}")
            raise ValidationError(f"Failed to mark step completed: {str(e)}")
    
    def update_time_spent(self, user_id: str, tutorial_id: int, minutes: int) -> TutorialProgress:
        """Update time spent on tutorial"""
        try:
            progress = self.get_or_create_progress(user_id, tutorial_id)
            progress.add_time_spent(minutes)
            
            self.session.commit()
            logger.debug(f"Updated time spent for user {user_id}, tutorial {tutorial_id}: +{minutes} min")
            return progress
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error updating time spent: {str(e)}")
            raise ValidationError(f"Failed to update time spent: {str(e)}")
    
    def set_tutorial_rating(self, user_id: str, tutorial_id: int, rating: int,
                           notes: Optional[str] = None) -> TutorialProgress:
        """Set user rating for tutorial"""
        try:
            progress = self.get_or_create_progress(user_id, tutorial_id)
            progress.set_rating(rating, notes)
            
            # Update tutorial's average rating
            tutorial = self.session.query(Tutorial).filter_by(id=tutorial_id).first()
            if tutorial:
                tutorial.update_rating(rating)
            
            self.session.commit()
            logger.info(f"Rating set for user {user_id}, tutorial {tutorial_id}: {rating} stars")
            return progress
            
        except Exception as e:
            self.session.rollback()
            logger.error(f"Error setting tutorial rating: {str(e)}")
            raise ValidationError(f"Failed to set rating: {str(e)}")
    
    def get_user_completed_tutorials(self, user_id: str) -> List[TutorialProgress]:
        """Get user's completed tutorials"""
        try:
            completed = self.session.query(TutorialProgress).filter_by(
                user_id=user_id, is_completed=True
            ).order_by(TutorialProgress.completed_at.desc()).all()
            
            logger.debug(f"Found {len(completed)} completed tutorials for user {user_id}")
            return completed
            
        except Exception as e:
            logger.error(f"Error getting completed tutorials: {str(e)}")
            raise ValidationError(f"Failed to get completed tutorials: {str(e)}")
    
    def get_user_in_progress_tutorials(self, user_id: str) -> List[TutorialProgress]:
        """Get user's in-progress tutorials"""
        try:
            in_progress = self.session.query(TutorialProgress).filter(
                and_(
                    TutorialProgress.user_id == user_id,
                    TutorialProgress.is_completed == False,
                    TutorialProgress.completion_percentage > 0
                )
            ).order_by(TutorialProgress.last_accessed_at.desc()).all()
            
            logger.debug(f"Found {len(in_progress)} in-progress tutorials for user {user_id}")
            return in_progress
            
        except Exception as e:
            logger.error(f"Error getting in-progress tutorials: {str(e)}")
            raise ValidationError(f"Failed to get in-progress tutorials: {str(e)}") 