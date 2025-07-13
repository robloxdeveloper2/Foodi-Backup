-- Migration: Create pantry_items table
-- Description: Add table for storing user pantry inventory items

-- Create pantry_items table
CREATE TABLE IF NOT EXISTS pantry_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity FLOAT NOT NULL DEFAULT 1.0 CHECK (quantity > 0),
    unit VARCHAR(50) NOT NULL DEFAULT 'units',
    expiry_date DATE NULL,
    category VARCHAR(100) NULL,
    notes TEXT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_pantry_items_user_id ON pantry_items(user_id);
CREATE INDEX IF NOT EXISTS idx_pantry_items_name ON pantry_items(name);
CREATE INDEX IF NOT EXISTS idx_pantry_items_category ON pantry_items(category);
CREATE INDEX IF NOT EXISTS idx_pantry_items_expiry_date ON pantry_items(expiry_date);
CREATE INDEX IF NOT EXISTS idx_pantry_items_created_at ON pantry_items(created_at);

-- Create composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_pantry_items_user_category ON pantry_items(user_id, category);
CREATE INDEX IF NOT EXISTS idx_pantry_items_user_expiry ON pantry_items(user_id, expiry_date);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_pantry_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER trigger_update_pantry_items_updated_at
    BEFORE UPDATE ON pantry_items
    FOR EACH ROW
    EXECUTE FUNCTION update_pantry_items_updated_at();

-- Add some sample data for testing (optional)
-- INSERT INTO pantry_items (user_id, name, quantity, unit, expiry_date, category, notes) VALUES
-- ((SELECT id FROM users LIMIT 1), 'Milk', 1, 'liters', CURRENT_DATE + INTERVAL '5 days', 'dairy', 'Fresh whole milk'),
-- ((SELECT id FROM users LIMIT 1), 'Bread', 1, 'loaves', CURRENT_DATE + INTERVAL '3 days', 'bakery', 'Whole wheat bread'),
-- ((SELECT id FROM users LIMIT 1), 'Apples', 5, 'pieces', CURRENT_DATE + INTERVAL '7 days', 'produce', 'Red delicious apples');

-- Grant permissions (if needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON pantry_items TO your_app_user; 