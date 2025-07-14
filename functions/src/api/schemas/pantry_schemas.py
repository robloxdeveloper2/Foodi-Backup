"""
Pydantic schemas for pantry item API endpoints
"""

from datetime import date
from typing import Optional, List
from pydantic import BaseModel, Field, validator


class PantryItemCreateRequest(BaseModel):
    """Schema for creating a new pantry item"""
    name: str = Field(..., min_length=1, max_length=255, description="Name of the food item")
    quantity: float = Field(..., gt=0, description="Quantity of the item")
    unit: str = Field(default="units", max_length=50, description="Unit of measurement")
    expiry_date: Optional[date] = Field(None, description="Expiry date of the item (YYYY-MM-DD)")
    category: Optional[str] = Field(None, max_length=100, description="Category of the item")
    notes: Optional[str] = Field(None, max_length=1000, description="Additional notes")
    
    @validator('name')
    def validate_name(cls, v):
        if not v or not v.strip():
            raise ValueError('Item name cannot be empty')
        return v.strip()
    
    @validator('unit')
    def validate_unit(cls, v):
        valid_units = [
            'units', 'pieces', 'items',
            'grams', 'g', 'kg', 'kilograms', 'pounds', 'lbs', 'oz', 'ounces',
            'ml', 'milliliters', 'liters', 'l', 'cups', 'tablespoons', 'teaspoons',
            'cans', 'bottles', 'packages', 'bags'
        ]
        if v.lower() not in valid_units:
            raise ValueError(f'Unit must be one of: {", ".join(valid_units)}')
        return v.lower()
    
    @validator('expiry_date')
    def validate_expiry_date(cls, v):
        if v and v < date.today():
            raise ValueError('Expiry date cannot be in the past')
        return v
    
    @validator('category')
    def validate_category(cls, v):
        if not v:
            return None
        valid_categories = [
            'produce', 'dairy', 'meat', 'seafood', 'pantry', 'frozen', 
            'bakery', 'beverages', 'canned_goods', 'condiments', 'snacks'
        ]
        if v.lower() not in valid_categories:
            raise ValueError(f'Category must be one of: {", ".join(valid_categories)}')
        return v.lower()


class PantryItemUpdateRequest(BaseModel):
    """Schema for updating an existing pantry item"""
    name: Optional[str] = Field(None, min_length=1, max_length=255, description="Name of the food item")
    quantity: Optional[float] = Field(None, gt=0, description="Quantity of the item")
    unit: Optional[str] = Field(None, max_length=50, description="Unit of measurement")
    expiry_date: Optional[date] = Field(None, description="Expiry date of the item (YYYY-MM-DD)")
    category: Optional[str] = Field(None, max_length=100, description="Category of the item")
    notes: Optional[str] = Field(None, max_length=1000, description="Additional notes")
    
    @validator('name')
    def validate_name(cls, v):
        if v is not None and (not v or not v.strip()):
            raise ValueError('Item name cannot be empty')
        return v.strip() if v else None
    
    @validator('unit')
    def validate_unit(cls, v):
        if v is None:
            return None
        valid_units = [
            'units', 'pieces', 'items',
            'grams', 'g', 'kg', 'kilograms', 'pounds', 'lbs', 'oz', 'ounces',
            'ml', 'milliliters', 'liters', 'l', 'cups', 'tablespoons', 'teaspoons',
            'cans', 'bottles', 'packages', 'bags'
        ]
        if v.lower() not in valid_units:
            raise ValueError(f'Unit must be one of: {", ".join(valid_units)}')
        return v.lower()
    
    @validator('expiry_date')
    def validate_expiry_date(cls, v):
        if v and v < date.today():
            raise ValueError('Expiry date cannot be in the past')
        return v
    
    @validator('category')
    def validate_category(cls, v):
        if not v:
            return None
        valid_categories = [
            'produce', 'dairy', 'meat', 'seafood', 'pantry', 'frozen', 
            'bakery', 'beverages', 'canned_goods', 'condiments', 'snacks'
        ]
        if v.lower() not in valid_categories:
            raise ValueError(f'Category must be one of: {", ".join(valid_categories)}')
        return v.lower()


class PantryItemResponse(BaseModel):
    """Schema for pantry item API responses"""
    id: str
    user_id: str
    name: str
    quantity: float
    unit: str
    expiry_date: Optional[str] = None  # ISO date string
    category: Optional[str] = None
    notes: Optional[str] = None
    is_expired: bool
    days_until_expiry: Optional[int] = None
    is_expiring_soon: bool
    created_at: str
    updated_at: str
    
    class Config:
        from_attributes = True


class PantryItemListResponse(BaseModel):
    """Schema for paginated pantry item list responses"""
    items: List[PantryItemResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
    has_next: bool
    has_prev: bool


class PantryStatsResponse(BaseModel):
    """Schema for pantry statistics"""
    total_items: int
    expired_items: int
    expiring_soon_items: int
    categories: dict
    units: dict 