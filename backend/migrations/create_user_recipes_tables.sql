-- Migration: Create User Recipe Tables
-- Description: Creates tables for user recipe collection management
-- Version: 1.0
-- Date: 2024-01-XX

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create user_recipes table
CREATE TABLE IF NOT EXISTS user_recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    original_recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL, -- NULL for custom recipes
    
    -- Recipe Content
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Recipe Data (stored as JSON for flexibility)
    ingredients JSONB NOT NULL, -- [{"name": "flour", "quantity": "1 cup", "unit": "cup", "substitutions": []}]
    instructions TEXT NOT NULL, -- Step-by-step instructions as text
    detailed_instructions JSONB, -- [{"step": 1, "instruction": "...", "duration_minutes": 5, "tips": "..."}]
    
    -- Enhanced Recipe Information
    cooking_tips JSONB, -- [{"tip": "For best results...", "category": "technique"}]
    equipment_needed JSONB, -- ["large pot", "whisk", "measuring cups"]
    
    -- Classification
    cuisine_type VARCHAR(50), -- Italian, Mexican, etc.
    meal_type VARCHAR(50), -- breakfast, lunch, dinner, snack
    
    -- Timing Information
    prep_time_minutes INTEGER CHECK (prep_time_minutes >= 0),
    cook_time_minutes INTEGER CHECK (cook_time_minutes >= 0),
    
    -- Recipe Details
    difficulty_level VARCHAR(20), -- easy, medium, hard
    servings INTEGER DEFAULT 4 CHECK (servings > 0),
    
    -- Nutritional Information (stored as JSON)
    nutritional_info JSONB, -- {"calories": 300, "protein": 20, "fat": 10, "carbs": 40}
    
    -- User Recipe Specific Fields
    image_url VARCHAR(500),
    is_custom BOOLEAN DEFAULT FALSE, -- True for user-created recipes, False for favorited catalog recipes
    is_public BOOLEAN DEFAULT FALSE, -- Whether user wants to share this recipe publicly
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for user_recipes table
CREATE INDEX IF NOT EXISTS idx_user_recipes_user_id ON user_recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_recipes_original_recipe_id ON user_recipes(original_recipe_id);
CREATE INDEX IF NOT EXISTS idx_user_recipes_is_custom ON user_recipes(is_custom);
CREATE INDEX IF NOT EXISTS idx_user_recipes_cuisine_type ON user_recipes(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_user_recipes_meal_type ON user_recipes(meal_type);
CREATE INDEX IF NOT EXISTS idx_user_recipes_created_at ON user_recipes(created_at);
CREATE INDEX IF NOT EXISTS idx_user_recipes_name_search ON user_recipes USING gin(to_tsvector('english', name));
CREATE INDEX IF NOT EXISTS idx_user_recipes_ingredients_search ON user_recipes USING gin(ingredients);

-- Create unique index to prevent duplicate favorites
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_recipes_unique_favorite 
ON user_recipes(user_id, original_recipe_id) 
WHERE original_recipe_id IS NOT NULL;

-- Create user_recipe_categories table
CREATE TABLE IF NOT EXISTS user_recipe_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Category Information
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7), -- Hex color code (e.g., "#FF5733")
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT unique_user_category_name UNIQUE(user_id, name),
    CONSTRAINT valid_hex_color CHECK (color IS NULL OR color ~ '^#[0-9A-Fa-f]{6}$')
);

-- Create indexes for user_recipe_categories table
CREATE INDEX IF NOT EXISTS idx_user_recipe_categories_user_id ON user_recipe_categories(user_id);
CREATE INDEX IF NOT EXISTS idx_user_recipe_categories_name ON user_recipe_categories(name);

-- Create user_recipe_category_assignments table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS user_recipe_category_assignments (
    user_recipe_id UUID NOT NULL REFERENCES user_recipes(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES user_recipe_categories(id) ON DELETE CASCADE,
    
    -- Composite Primary Key
    PRIMARY KEY (user_recipe_id, category_id)
);

-- Create indexes for user_recipe_category_assignments table
CREATE INDEX IF NOT EXISTS idx_user_recipe_category_assignments_user_recipe_id 
ON user_recipe_category_assignments(user_recipe_id);
CREATE INDEX IF NOT EXISTS idx_user_recipe_category_assignments_category_id 
ON user_recipe_category_assignments(category_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_recipe_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on user_recipes
DROP TRIGGER IF EXISTS trigger_update_user_recipe_updated_at ON user_recipes;
CREATE TRIGGER trigger_update_user_recipe_updated_at
    BEFORE UPDATE ON user_recipes
    FOR EACH ROW
    EXECUTE FUNCTION update_user_recipe_updated_at();

-- Insert default categories for existing users (optional - can be run separately)
-- This would typically be handled by the application when a user first accesses the feature

-- Add helpful comments
COMMENT ON TABLE user_recipes IS 'Stores user''s personal recipe collection including favorited catalog recipes and custom recipes';
COMMENT ON TABLE user_recipe_categories IS 'Custom categories for organizing user recipes';
COMMENT ON TABLE user_recipe_category_assignments IS 'Many-to-many relationship between user recipes and categories';

COMMENT ON COLUMN user_recipes.original_recipe_id IS 'References the original catalog recipe for favorited recipes, NULL for custom recipes';
COMMENT ON COLUMN user_recipes.is_custom IS 'TRUE for user-created recipes, FALSE for favorited catalog recipes';
COMMENT ON COLUMN user_recipes.is_public IS 'Whether the recipe can be shared publicly (only applies to custom recipes)';
COMMENT ON COLUMN user_recipes.ingredients IS 'JSON array of ingredient objects with name, quantity, unit, and substitutions';
COMMENT ON COLUMN user_recipes.detailed_instructions IS 'JSON array of detailed instruction steps with timing and tips';
COMMENT ON COLUMN user_recipes.cooking_tips IS 'JSON array of cooking tips and techniques';
COMMENT ON COLUMN user_recipes.equipment_needed IS 'JSON array of required cooking equipment';
COMMENT ON COLUMN user_recipes.nutritional_info IS 'JSON object with nutritional information per recipe';

COMMENT ON COLUMN user_recipe_categories.color IS 'Hex color code for visual categorization (e.g., #FF5733)';

-- Sample data for testing (optional - remove for production)
/*
-- Insert sample default categories for testing
INSERT INTO user_recipe_categories (user_id, name, description, color) VALUES
    -- These would be inserted for a specific test user
    ('your-test-user-id-here', 'Favorites', 'My favorite recipes', '#FF6B6B'),
    ('your-test-user-id-here', 'Quick & Easy', 'Fast meals under 30 minutes', '#4ECDC4'),
    ('your-test-user-id-here', 'Healthy', 'Nutritious and wholesome meals', '#45B7D1'),
    ('your-test-user-id-here', 'Comfort Food', 'Hearty and satisfying dishes', '#FFA07A'),
    ('your-test-user-id-here', 'Desserts', 'Sweet treats and desserts', '#DDA0DD')
ON CONFLICT (user_id, name) DO NOTHING;
*/

-- Verification queries (can be run to verify the migration)
/*
-- Check table structures
\d user_recipes
\d user_recipe_categories
\d user_recipe_category_assignments

-- Check indexes
\di *user_recipe*

-- Check constraints
SELECT conname, contype, conkey, confkey 
FROM pg_constraint 
WHERE conrelid IN (
    'user_recipes'::regclass, 
    'user_recipe_categories'::regclass, 
    'user_recipe_category_assignments'::regclass
);
*/ 