"""
Grocery List API Schemas
Pydantic models for request and response validation
"""

from typing import Optional
from pydantic import BaseModel, Field, validator


class GroceryListGenerationRequest(BaseModel):
    """Schema for grocery list generation request"""
    list_name: Optional[str] = Field(None, max_length=255, description="Optional name for the grocery list")
    
    @validator('list_name')
    def validate_list_name(cls, v):
        if v is not None and len(v.strip()) == 0:
            raise ValueError('List name cannot be empty')
        return v.strip() if v else None


class GroceryListUpdateRequest(BaseModel):
    """Schema for grocery list update request"""
    name: Optional[str] = Field(None, max_length=255, description="New name for the grocery list")
    
    @validator('name')
    def validate_name(cls, v):
        if v is not None and len(v.strip()) == 0:
            raise ValueError('Name cannot be empty')
        return v.strip() if v else None


class CustomItemRequest(BaseModel):
    """Schema for adding a custom item to grocery list"""
    ingredient_name: str = Field(..., max_length=255, description="Name of the ingredient")
    quantity: str = Field(..., max_length=100, description="Quantity of the ingredient")
    unit: Optional[str] = Field(None, max_length=50, description="Unit of measurement")
    
    @validator('ingredient_name')
    def validate_ingredient_name(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('Ingredient name is required')
        return v.strip()
    
    @validator('quantity')
    def validate_quantity(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('Quantity is required')
        return v.strip()
    
    @validator('unit')
    def validate_unit(cls, v):
        return v.strip() if v else None


class ItemQuantityUpdateRequest(BaseModel):
    """Schema for updating item quantity"""
    quantity: str = Field(..., max_length=100, description="New quantity for the item")
    unit: Optional[str] = Field(None, max_length=50, description="New unit of measurement")
    
    @validator('quantity')
    def validate_quantity(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError('Quantity is required')
        return v.strip()
    
    @validator('unit')
    def validate_unit(cls, v):
        return v.strip() if v else None


class GroceryListResponse(BaseModel):
    """Schema for grocery list response"""
    id: str
    user_id: str
    meal_plan_id: Optional[str]
    name: str
    total_estimated_cost: Optional[int]
    total_cost_usd: Optional[float]
    is_active: bool
    created_at: str
    updated_at: str


class GroceryListItemResponse(BaseModel):
    """Schema for grocery list item response"""
    id: str
    grocery_list_id: str
    ingredient_name: str
    quantity: str
    unit: Optional[str]
    category: Optional[str]
    estimated_cost: Optional[int]
    cost_usd: Optional[float]
    is_checked: bool
    is_custom: bool
    created_at: str


class GroceryListWithItemsResponse(BaseModel):
    """Schema for grocery list with items response"""
    grocery_list: GroceryListResponse
    items_by_category: dict
    total_items: int


class GroceryListStatisticsResponse(BaseModel):
    """Schema for grocery list statistics response"""
    total_items: int
    checked_items: int
    unchecked_items: int
    custom_items: int
    recipe_items: int
    completion_percentage: float
    categories: dict
    total_estimated_cost_cents: int
    total_estimated_cost_usd: float 