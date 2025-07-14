"""
Social API Schemas
Marshmallow schemas for social endpoints validation and serialization
"""

from marshmallow import Schema, fields, validate, post_load
from typing import List

class UserProfileUpdateSchema(Schema):
    """Schema for updating user social profile"""
    display_name = fields.String(allow_none=True, validate=validate.Length(max=100))
    bio = fields.String(allow_none=True, validate=validate.Length(max=1000))
    cooking_level = fields.String(
        allow_none=True, 
        validate=validate.OneOf(['beginner', 'intermediate', 'advanced', 'expert'])
    )
    favorite_cuisines = fields.List(fields.String(), allow_none=True)
    cooking_goals = fields.List(fields.String(), allow_none=True)
    dietary_preferences = fields.List(fields.String(), allow_none=True)
    location = fields.String(allow_none=True, validate=validate.Length(max=100))
    website_url = fields.URL(allow_none=True)
    profile_picture_url = fields.URL(allow_none=True)
    cover_photo_url = fields.URL(allow_none=True)
    is_public = fields.Boolean(allow_none=True)
    allow_friend_requests = fields.Boolean(allow_none=True)


class UserProfileResponseSchema(Schema):
    """Schema for user social profile response"""
    id = fields.String(required=True)
    user_id = fields.String(required=True)
    display_name = fields.String(allow_none=True)
    bio = fields.String(allow_none=True)
    profile_picture_url = fields.String(allow_none=True)
    cover_photo_url = fields.String(allow_none=True)
    cooking_level = fields.String(allow_none=True)
    favorite_cuisines = fields.List(fields.String())
    cooking_goals = fields.List(fields.String())
    dietary_preferences = fields.List(fields.String())
    location = fields.String(allow_none=True)
    website_url = fields.String(allow_none=True)
    is_public = fields.Boolean()
    allow_friend_requests = fields.Boolean()
    created_at = fields.String(allow_none=True)
    updated_at = fields.String(allow_none=True)
    
    # Optional user information
    user = fields.Dict(allow_none=True)
    
    # Connection status
    is_current_user = fields.Boolean(allow_none=True)
    is_connected = fields.Boolean(allow_none=True)
    has_request_pending = fields.Boolean(allow_none=True)


class ConnectionRequestResponseSchema(Schema):
    """Schema for connection request response"""
    id = fields.String(required=True)
    sender_id = fields.String(required=True)
    receiver_id = fields.String(required=True)
    status = fields.String(required=True)
    message = fields.String(allow_none=True)
    created_at = fields.String(allow_none=True)
    responded_at = fields.String(allow_none=True)
    
    # Optional profile information
    sender_profile = fields.Nested(UserProfileResponseSchema, allow_none=True)
    receiver_profile = fields.Nested(UserProfileResponseSchema, allow_none=True)


class SearchUsersResponseSchema(Schema):
    """Schema for user search response"""
    users = fields.List(fields.Nested(UserProfileResponseSchema))
    total_count = fields.Integer()
    page = fields.Integer()
    total_pages = fields.Integer()


class ConnectionsResponseSchema(Schema):
    """Schema for user connections response"""
    connections = fields.List(fields.Nested(UserProfileResponseSchema))
    total_count = fields.Integer()
    page = fields.Integer()
    total_pages = fields.Integer()


class ActivityItemSchema(Schema):
    """Schema for activity feed item"""
    id = fields.String(required=True)
    user_id = fields.String(required=True)
    activity_type = fields.String(required=True)
    activity_data = fields.Dict(required=True)
    privacy_level = fields.String(required=True)
    created_at = fields.String(allow_none=True)
    
    # User profile information
    user_profile = fields.Dict(allow_none=True)


class ActivityFeedResponseSchema(Schema):
    """Schema for activity feed response"""
    activities = fields.List(fields.Nested(ActivityItemSchema))
    total_count = fields.Integer()
    page = fields.Integer()
    total_pages = fields.Integer()


class ConnectionRequestCreateSchema(Schema):
    """Schema for creating a connection request"""
    message = fields.String(allow_none=True, validate=validate.Length(max=500))


class ConnectionRequestRespondSchema(Schema):
    """Schema for responding to a connection request"""
    action = fields.String(required=True, validate=validate.OneOf(['accept', 'decline'])) 