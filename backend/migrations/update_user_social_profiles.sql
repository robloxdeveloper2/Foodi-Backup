-- Migration: Update user_social_profiles table to match the UserSocialProfile model
-- This migration transforms the table from a simple social links table to a comprehensive user profile table

-- First, let's backup the existing data if needed
-- CREATE TABLE user_social_profiles_backup AS SELECT * FROM user_social_profiles;

-- Drop the existing table and recreate with the new schema
DROP TABLE IF EXISTS user_social_profiles CASCADE;

-- Create the new user_social_profiles table matching the UserSocialProfile model
CREATE TABLE user_social_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Social Profile Information
    display_name VARCHAR(100),
    bio TEXT,
    profile_picture_url VARCHAR(500),
    cover_photo_url VARCHAR(500),
    
    -- Cooking Information
    cooking_level VARCHAR(50), -- beginner, intermediate, advanced, expert
    favorite_cuisines TEXT DEFAULT '[]', -- JSON array as text
    cooking_goals TEXT DEFAULT '[]', -- JSON array as text
    dietary_preferences TEXT DEFAULT '[]', -- JSON array as text
    
    -- Location and Contact
    location VARCHAR(100),
    website_url VARCHAR(500),
    
    -- Privacy Settings
    is_public BOOLEAN DEFAULT TRUE,
    allow_friend_requests BOOLEAN DEFAULT TRUE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(user_id)
);

-- Create indexes
CREATE INDEX idx_user_social_profiles_user_id ON user_social_profiles(user_id);
CREATE INDEX idx_user_social_profiles_is_public ON user_social_profiles(is_public);
CREATE INDEX idx_user_social_profiles_cooking_level ON user_social_profiles(cooking_level);

-- Create trigger for updated_at
CREATE TRIGGER update_user_social_profiles_updated_at
    BEFORE UPDATE ON user_social_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default profiles for existing users (optional)
INSERT INTO user_social_profiles (user_id, display_name, is_public, allow_friend_requests)
SELECT 
    id as user_id,
    COALESCE(first_name || ' ' || last_name, username) as display_name,
    TRUE as is_public,
    TRUE as allow_friend_requests
FROM users
WHERE NOT EXISTS (
    SELECT 1 FROM user_social_profiles WHERE user_social_profiles.user_id = users.id
);

-- Migration complete
SELECT 'user_social_profiles table updated successfully' as status; 