"""
Tutorial Domain Model
Represents cooking tutorials and skill-building content
"""

import uuid
from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import Column, String, DateTime, Integer, Text, Boolean
from sqlalchemy.types import JSON

from data_access.database import db

class Tutorial(db.Model):
    """Tutorial model for storing cooking tutorial data"""
    
    __tablename__ = 'tutorials'
    
    # Primary Fields
    id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    
    # Tutorial Content
    steps = Column(JSON, nullable=False)  # [{"step": 1, "title": "...", "description": "...", "image_url": "...", "video_url": "...", "duration_minutes": 5}]
    
    # Classification
    category = Column(String(100), nullable=False)  # knife_skills, cooking_methods, food_safety, baking_basics, etc.
    subcategory = Column(String(100), nullable=True)  # specific technique within category
    
    # Learning Information
    difficulty_level = Column(String(20), nullable=False)  # beginner, intermediate, advanced
    estimated_duration_minutes = Column(Integer, nullable=False)
    skill_level_required = Column(String(50), nullable=True)  # none, basic, intermediate
    
    # Content URLs
    thumbnail_url = Column(String(500), nullable=True)
    video_url = Column(String(500), nullable=True)  # Main tutorial video
    
    # Learning Objectives
    learning_objectives = Column(JSON, nullable=True)  # ["Learn proper knife grip", "Master basic cuts"]
    prerequisites = Column(JSON, nullable=True)  # ["Basic kitchen safety", "Using kitchen tools"]
    equipment_needed = Column(JSON, nullable=True)  # ["chef's knife", "cutting board", "towel"]
    
    # Tags and Keywords
    tags = Column(JSON, nullable=True)  # ["essential", "basics", "safety", "technique"]
    keywords = Column(JSON, nullable=True)  # For search functionality
    
    # Tutorial Metadata
    is_beginner_friendly = Column(Boolean, default=False)
    is_featured = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    
    # Engagement Metrics
    view_count = Column(Integer, default=0)
    completion_count = Column(Integer, default=0)
    average_rating = Column(db.Float, nullable=True)
    rating_count = Column(Integer, default=0)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __init__(self, title: str, description: str, steps: List[Dict[str, Any]], 
                 category: str, difficulty_level: str, estimated_duration_minutes: int,
                 subcategory: Optional[str] = None, skill_level_required: Optional[str] = None,
                 thumbnail_url: Optional[str] = None, video_url: Optional[str] = None,
                 learning_objectives: Optional[List[str]] = None, 
                 prerequisites: Optional[List[str]] = None,
                 equipment_needed: Optional[List[str]] = None,
                 tags: Optional[List[str]] = None, keywords: Optional[List[str]] = None,
                 is_beginner_friendly: bool = False, is_featured: bool = False):
        """Initialize a new tutorial"""
        self.title = title
        self.description = description
        self.steps = steps
        self.category = category
        self.subcategory = subcategory
        self.difficulty_level = difficulty_level
        self.estimated_duration_minutes = estimated_duration_minutes
        self.skill_level_required = skill_level_required
        self.thumbnail_url = thumbnail_url
        self.video_url = video_url
        self.learning_objectives = learning_objectives or []
        self.prerequisites = prerequisites or []
        self.equipment_needed = equipment_needed or []
        self.tags = tags or []
        self.keywords = keywords or []
        self.is_beginner_friendly = is_beginner_friendly
        self.is_featured = is_featured
    
    @property
    def completion_rate(self) -> float:
        """Calculate completion rate as percentage"""
        if not self.view_count or self.view_count == 0:
            return 0.0
        completion_count = self.completion_count or 0
        return (completion_count / self.view_count) * 100
    
    @property
    def step_count(self) -> int:
        """Get number of tutorial steps"""
        return len(self.steps) if self.steps else 0
    
    def get_step_by_number(self, step_number: int) -> Optional[Dict[str, Any]]:
        """Get a specific step by number"""
        if not self.steps or step_number < 1 or step_number > len(self.steps):
            return None
        return self.steps[step_number - 1]
    
    def matches_search_query(self, query: str) -> bool:
        """Check if tutorial matches search query"""
        if not query:
            return True
        
        query_lower = query.lower()
        searchable_text = f"{self.title} {self.description} {self.category} {self.subcategory or ''}".lower()
        
        # Check in keywords
        if self.keywords:
            searchable_text += " " + " ".join(self.keywords).lower()
        
        # Check in tags
        if self.tags:
            searchable_text += " " + " ".join(self.tags).lower()
        
        # Check in learning objectives
        if self.learning_objectives:
            searchable_text += " " + " ".join(self.learning_objectives).lower()
        
        return query_lower in searchable_text
    
    def matches_filters(self, category: Optional[str] = None, 
                       difficulty: Optional[str] = None,
                       duration_max_minutes: Optional[int] = None,
                       beginner_friendly: Optional[bool] = None) -> bool:
        """Check if tutorial matches filter criteria"""
        if category and self.category != category:
            return False
        
        if difficulty and self.difficulty_level != difficulty:
            return False
        
        if duration_max_minutes and self.estimated_duration_minutes > duration_max_minutes:
            return False
        
        if beginner_friendly is not None and self.is_beginner_friendly != beginner_friendly:
            return False
        
        return True
    
    def increment_view_count(self):
        """Increment view count"""
        self.view_count += 1
    
    def increment_completion_count(self):
        """Increment completion count"""
        self.completion_count += 1
    
    def update_rating(self, new_rating: float):
        """Update average rating with new rating"""
        rating_count = self.rating_count or 0
        average_rating = self.average_rating or 0.0
        
        if rating_count == 0:
            self.average_rating = new_rating
        else:
            total_rating = (average_rating * rating_count) + new_rating
            self.average_rating = total_rating / (rating_count + 1)
        
        self.rating_count = rating_count + 1
    
    def to_dict(self, include_steps: bool = True) -> Dict[str, Any]:
        """Convert tutorial to dictionary"""
        data = {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'category': self.category,
            'subcategory': self.subcategory,
            'difficulty_level': self.difficulty_level,
            'estimated_duration_minutes': self.estimated_duration_minutes,
            'skill_level_required': self.skill_level_required,
            'thumbnail_url': self.thumbnail_url,
            'video_url': self.video_url,
            'learning_objectives': self.learning_objectives,
            'prerequisites': self.prerequisites,
            'equipment_needed': self.equipment_needed,
            'tags': self.tags,
            'keywords': self.keywords,
            'is_beginner_friendly': self.is_beginner_friendly,
            'is_featured': self.is_featured,
            'is_active': self.is_active,
            'step_count': self.step_count,
            'view_count': self.view_count,
            'completion_count': self.completion_count,
            'completion_rate': self.completion_rate,
            'average_rating': self.average_rating,
            'rating_count': self.rating_count,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        
        if include_steps:
            data['steps'] = self.steps
        
        return data
    
    def __repr__(self) -> str:
        return f"<Tutorial(id={self.id}, title='{self.title}', category='{self.category}', difficulty='{self.difficulty_level}')>"


class TutorialProgress(db.Model):
    """Model to track user progress through tutorials"""
    
    __tablename__ = 'tutorial_progress'
    
    # Primary Fields
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String(36), nullable=False)  # Foreign key to users table (UUID)
    tutorial_id = Column(Integer, nullable=False)  # Foreign key to tutorials table
    
    # Progress Information
    current_step = Column(Integer, default=1)  # Current step user is on
    completed_steps = Column(JSON, default=list)  # List of completed step numbers
    is_completed = Column(Boolean, default=False)
    completion_percentage = Column(Integer, default=0)  # 0-100
    
    # Time Tracking
    time_spent_minutes = Column(Integer, default=0)
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    last_accessed_at = Column(DateTime, default=datetime.utcnow)
    
    # User Feedback
    user_rating = Column(Integer, nullable=True)  # 1-5 stars
    user_notes = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __init__(self, user_id: str, tutorial_id: int):
        """Initialize tutorial progress for a user"""
        self.user_id = user_id
        self.tutorial_id = tutorial_id
        self.completed_steps = []
    
    def mark_step_completed(self, step_number: int, tutorial_step_count: int):
        """Mark a specific step as completed"""
        if step_number not in self.completed_steps:
            self.completed_steps.append(step_number)
            self.completed_steps.sort()
        
        # Update current step to next uncompleted step
        self.current_step = self._find_next_uncompleted_step(tutorial_step_count)
        
        # Update completion percentage
        if tutorial_step_count > 0:
            self.completion_percentage = int((len(self.completed_steps) / tutorial_step_count) * 100)
        else:
            self.completion_percentage = 0
        
        # Check if tutorial is completed
        if len(self.completed_steps) >= tutorial_step_count:
            self.is_completed = True
            self.completed_at = datetime.utcnow()
        
        self.last_accessed_at = datetime.utcnow()
    
    def _find_next_uncompleted_step(self, tutorial_step_count: int) -> int:
        """Find the next uncompleted step number"""
        for step_num in range(1, tutorial_step_count + 1):
            if step_num not in self.completed_steps:
                return step_num
        return tutorial_step_count  # All steps completed
    
    def add_time_spent(self, minutes: int):
        """Add time spent on tutorial"""
        self.time_spent_minutes += minutes
        self.last_accessed_at = datetime.utcnow()
    
    def set_rating(self, rating: int, notes: Optional[str] = None):
        """Set user rating and notes for tutorial"""
        if not 1 <= rating <= 5:
            raise ValueError("Rating must be between 1 and 5")
        
        self.user_rating = rating
        if notes:
            self.user_notes = notes
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert progress to dictionary"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'tutorial_id': self.tutorial_id,
            'current_step': self.current_step,
            'completed_steps': self.completed_steps,
            'is_completed': self.is_completed,
            'completion_percentage': self.completion_percentage,
            'time_spent_minutes': self.time_spent_minutes,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'last_accessed_at': self.last_accessed_at.isoformat() if self.last_accessed_at else None,
            'user_rating': self.user_rating,
            'user_notes': self.user_notes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self) -> str:
        return f"<TutorialProgress(id={self.id}, user_id={self.user_id}, tutorial_id={self.tutorial_id}, completed={self.is_completed})>" 