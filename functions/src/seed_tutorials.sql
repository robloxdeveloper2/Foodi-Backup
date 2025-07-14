-- Tutorial Seed Data SQL Script
-- Inserts sample tutorials for the Foodi application

-- Clean up existing data (optional)
-- DELETE FROM tutorial_progress;
-- DELETE FROM tutorials;

-- Insert Tutorial 1: Basic Knife Skills
INSERT INTO tutorials (
    title, description, category, subcategory, difficulty_level, 
    estimated_duration_minutes, skill_level_required, is_beginner_friendly, 
    is_featured, is_active, thumbnail_url, video_url, learning_objectives, prerequisites, 
    equipment_needed, tags, keywords, steps, created_at, updated_at
) VALUES (
    'Basic Knife Skills: The Foundation of Cooking',
    'Learn the fundamental knife skills every cook needs to know. This tutorial covers proper knife grip, cutting techniques, and safety practices that will make your cooking more efficient and enjoyable.',
    'knife_skills',
    'basic_cuts',
    'beginner',
    25,
    'none',
    true,
    true,
    true,
    'https://example.com/thumbnails/knife-skills.jpg',
    'https://example.com/videos/knife-skills.mp4',
    '["Learn proper knife grip and posture", "Master basic cuts: dice, julienne, chop", "Understand knife safety fundamentals", "Practice efficient cutting techniques"]'::json,
    '[]'::json,
    '["Chef''s knife (8-10 inch)", "Cutting board", "Kitchen towel", "Practice vegetables (onions, carrots, celery)"]'::json,
    '["essential", "basics", "safety", "technique"]'::json,
    '["knife", "cutting", "dicing", "safety", "grip", "basic"]'::json,
    '[
        {
            "step": 1,
            "title": "Knife Selection and Setup",
            "description": "Choose the right knife and prepare your workspace for safe cutting practice.",
            "image_url": "https://example.com/steps/knife-setup.jpg",
            "duration_minutes": 3,
            "tips": "A sharp knife is safer than a dull one - it requires less pressure and is more predictable."
        },
        {
            "step": 2,
            "title": "Proper Knife Grip",
            "description": "Learn the pinch grip - the foundation of all knife work. Hold the blade between thumb and index finger.",
            "image_url": "https://example.com/steps/knife-grip.jpg",
            "duration_minutes": 5,
            "tips": "Your knuckles should guide the blade - curl your fingertips under and use knuckles as a fence."
        },
        {
            "step": 3,
            "title": "Basic Dicing Technique",
            "description": "Practice dicing an onion using proper knife technique and safety practices.",
            "image_url": "https://example.com/steps/dicing.jpg",
            "duration_minutes": 8,
            "tips": "Keep the tip of the knife on the cutting board and rock the blade for controlled cuts."
        },
        {
            "step": 4,
            "title": "Julienne and Chop Cuts",
            "description": "Learn to create uniform julienne strips and practice rough chopping techniques.",
            "image_url": "https://example.com/steps/julienne.jpg",
            "duration_minutes": 7,
            "tips": "Consistency in size ensures even cooking - take your time to develop muscle memory."
        },
        {
            "step": 5,
            "title": "Safety and Cleanup",
            "description": "Review safety practices and proper knife care and storage.",
            "image_url": "https://example.com/steps/cleanup.jpg",
            "duration_minutes": 2,
            "tips": "Always hand wash knives immediately and store them safely in a knife block or magnetic strip."
        }
    ]'::json,
    NOW(),
    NOW()
);

-- Insert Tutorial 2: Food Safety Fundamentals
INSERT INTO tutorials (
    title, description, category, subcategory, difficulty_level, 
    estimated_duration_minutes, skill_level_required, is_beginner_friendly, 
    is_featured, thumbnail_url, learning_objectives, prerequisites, 
    equipment_needed, tags, keywords, steps, created_at, updated_at
) VALUES (
    'Food Safety Fundamentals',
    'Essential food safety practices every home cook must know to prevent foodborne illness and ensure safe meal preparation.',
    'food_safety',
    'basics',
    'beginner',
    20,
    'none',
    true,
    true,
    'https://example.com/thumbnails/food-safety.jpg',
    '["Understand temperature danger zones", "Learn proper hand washing techniques", "Practice safe food storage methods", "Recognize signs of food spoilage"]'::json,
    '[]'::json,
    '["Food thermometer", "Soap and water", "Clean towels", "Storage containers"]'::json,
    '["essential", "safety", "health", "basics"]'::json,
    '["safety", "temperature", "hygiene", "storage", "contamination"]'::json,
    '[
        {
            "step": 1,
            "title": "Hand Washing Mastery",
            "description": "Learn the proper 20-second hand washing technique that eliminates harmful bacteria.",
            "duration_minutes": 4,
            "tips": "Sing ''Happy Birthday'' twice to time your hand washing correctly."
        },
        {
            "step": 2,
            "title": "Temperature Control",
            "description": "Understand safe cooking temperatures and the danger zone (40-140°F).",
            "duration_minutes": 6,
            "tips": "Use a food thermometer - visual cues alone aren''t reliable for safety."
        },
        {
            "step": 3,
            "title": "Cross-Contamination Prevention",
            "description": "Learn to separate raw and cooked foods and use different cutting boards.",
            "duration_minutes": 5,
            "tips": "Use separate cutting boards for raw meat and vegetables to prevent cross-contamination."
        },
        {
            "step": 4,
            "title": "Proper Food Storage",
            "description": "Practice safe refrigerator organization and storage techniques.",
            "duration_minutes": 5,
            "tips": "Store raw meat on the bottom shelf to prevent drips onto other foods."
        }
    ]'::json,
    NOW(),
    NOW()
);

-- Insert Tutorial 3: Sautéing Techniques
INSERT INTO tutorials (
    title, description, category, subcategory, difficulty_level, 
    estimated_duration_minutes, skill_level_required, is_beginner_friendly, 
    is_featured, thumbnail_url, learning_objectives, prerequisites, 
    equipment_needed, tags, keywords, steps, created_at, updated_at
) VALUES (
    'Sautéing Techniques: Building Flavor',
    'Master the art of sautéing to build complex flavors in your dishes. Learn heat control, timing, and ingredient sequencing.',
    'cooking_methods',
    'sauteing',
    'intermediate',
    30,
    'basic',
    false,
    true,
    'https://example.com/thumbnails/sauteing.jpg',
    '["Understand heat control for sautéing", "Learn proper pan selection and preparation", "Master ingredient timing and sequencing", "Develop flavor through proper technique"]'::json,
    '["Basic knife skills", "Understanding of cooking basics"]'::json,
    '["Large sauté pan or skillet", "Wooden spoon or spatula", "Various oils and fats", "Practice ingredients (onions, garlic, vegetables)"]'::json,
    '["technique", "flavor", "intermediate", "heat"]'::json,
    '["sauté", "pan", "heat", "flavor", "technique", "timing"]'::json,
    '[
        {
            "step": 1,
            "title": "Pan Selection and Heating",
            "description": "Choose the right pan and heat it properly for effective sautéing.",
            "duration_minutes": 5,
            "tips": "A properly heated pan will make water droplets dance and evaporate quickly."
        },
        {
            "step": 2,
            "title": "Oil and Fat Management",
            "description": "Learn when and how much fat to use for different ingredients.",
            "duration_minutes": 7,
            "tips": "The oil should shimmer but not smoke - this indicates the right temperature."
        },
        {
            "step": 3,
            "title": "Ingredient Sequencing",
            "description": "Practice adding ingredients in the correct order for optimal flavor development.",
            "duration_minutes": 10,
            "tips": "Start with aromatics like onions and garlic, then add harder vegetables before softer ones."
        },
        {
            "step": 4,
            "title": "Movement and Timing",
            "description": "Learn the sautéing motion and how to time your cooking for perfect results.",
            "duration_minutes": 8,
            "tips": "Keep ingredients moving to prevent burning, but don''t over-stir which can reduce browning."
        }
    ]'::json,
    NOW(),
    NOW()
);

-- Insert Tutorial 4: Bread Baking Basics
INSERT INTO tutorials (
    title, description, category, subcategory, difficulty_level, 
    estimated_duration_minutes, skill_level_required, is_beginner_friendly, 
    is_featured, thumbnail_url, learning_objectives, prerequisites, 
    equipment_needed, tags, keywords, steps, created_at, updated_at
) VALUES (
    'Bread Baking Basics: Your First Loaf',
    'Discover the joy of bread baking with this comprehensive guide to making your first homemade loaf. Learn about yeast, kneading, and the magic of fermentation.',
    'baking_basics',
    'bread',
    'intermediate',
    45,
    'basic',
    false,
    false,
    'https://example.com/thumbnails/bread-baking.jpg',
    '["Understand how yeast works", "Learn proper kneading techniques", "Master proofing and fermentation", "Recognize properly baked bread"]'::json,
    '["Basic kitchen skills", "Understanding of measurements"]'::json,
    '["Large mixing bowl", "Kitchen scale", "Clean kitchen towel", "Loaf pan", "Bread ingredients"]'::json,
    '["baking", "bread", "yeast", "technique"]'::json,
    '["bread", "yeast", "kneading", "proofing", "baking", "fermentation"]'::json,
    '[
        {
            "step": 1,
            "title": "Understanding Ingredients",
            "description": "Learn about flour, yeast, salt, and water - the four essential bread ingredients.",
            "duration_minutes": 8,
            "tips": "Use bread flour for better gluten development and structure."
        },
        {
            "step": 2,
            "title": "Mixing and Initial Kneading",
            "description": "Combine ingredients and begin developing gluten through kneading.",
            "duration_minutes": 12,
            "tips": "The dough should become smooth and elastic - this takes about 8-10 minutes of kneading."
        },
        {
            "step": 3,
            "title": "First Rise (Bulk Fermentation)",
            "description": "Allow the dough to rise and develop flavor through fermentation.",
            "duration_minutes": 8,
            "tips": "The dough should double in size - this usually takes 1-2 hours depending on temperature."
        },
        {
            "step": 4,
            "title": "Shaping and Second Rise",
            "description": "Shape your loaf and allow for final proofing before baking.",
            "duration_minutes": 10,
            "tips": "Shape gently to maintain air bubbles created during fermentation."
        },
        {
            "step": 5,
            "title": "Baking and Cooling",
            "description": "Bake your bread and learn how to tell when it''s perfectly done.",
            "duration_minutes": 7,
            "tips": "The bread is done when it sounds hollow when tapped on the bottom."
        }
    ]'::json,
    NOW(),
    NOW()
);

-- Insert Tutorial 5: Kitchen Tool Mastery
INSERT INTO tutorials (
    title, description, category, subcategory, difficulty_level, 
    estimated_duration_minutes, skill_level_required, is_beginner_friendly, 
    is_featured, thumbnail_url, learning_objectives, prerequisites, 
    equipment_needed, tags, keywords, steps, created_at, updated_at
) VALUES (
    'Kitchen Tool Mastery: Essential Equipment',
    'Get familiar with essential kitchen tools and learn how to use them effectively. From measuring cups to thermometers, master your kitchen arsenal.',
    'kitchen_basics',
    'equipment',
    'beginner',
    15,
    'none',
    true,
    false,
    'https://example.com/thumbnails/kitchen-tools.jpg',
    '["Identify essential kitchen tools", "Learn proper tool usage and care", "Understand when to use specific tools", "Practice tool maintenance"]'::json,
    '[]'::json,
    '["Various kitchen tools", "Measuring cups and spoons", "Kitchen scale", "Thermometer"]'::json,
    '["basics", "tools", "equipment", "maintenance"]'::json,
    '["tools", "equipment", "measuring", "thermometer", "maintenance"]'::json,
    '[
        {
            "step": 1,
            "title": "Measuring Tools",
            "description": "Learn the difference between liquid and dry measuring tools and how to measure accurately.",
            "duration_minutes": 5,
            "tips": "Level dry ingredients with a knife for accurate measurements."
        },
        {
            "step": 2,
            "title": "Cutting and Prep Tools",
            "description": "Familiarize yourself with various knives, peelers, and cutting implements.",
            "duration_minutes": 5,
            "tips": "Different knives have specific purposes - use the right tool for each job."
        },
        {
            "step": 3,
            "title": "Heat and Temperature Tools",
            "description": "Learn to use thermometers, timers, and heat-resistant tools safely.",
            "duration_minutes": 5,
            "tips": "A good thermometer is essential for food safety and consistent results."
        }
    ]'::json,
    NOW(),
    NOW()
);

-- Verify the insert (optional)
SELECT 
    id,
    title,
    category,
    difficulty_level,
    estimated_duration_minutes,
    is_beginner_friendly,
    is_featured,
    json_array_length(steps) as step_count
FROM tutorials
ORDER BY id; 