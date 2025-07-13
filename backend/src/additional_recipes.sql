-- Additional Recipe Seed Data SQL Script
-- Inserts 8 additional recipes with nutritional information for the Foodi application

-- Recipe 1: Classic Pancakes (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Classic Pancakes',
    'Fluffy and delicious pancakes perfect for breakfast',
    '[
        {"name": "flour", "quantity": "2", "unit": "cups", "substitutions": ["whole wheat flour"]},
        {"name": "milk", "quantity": "1.5", "unit": "cups", "substitutions": ["almond milk", "oat milk"]},
        {"name": "eggs", "quantity": "2", "unit": "pieces", "substitutions": ["flax eggs"]},
        {"name": "sugar", "quantity": "2", "unit": "tbsp", "substitutions": ["honey", "maple syrup"]},
        {"name": "baking powder", "quantity": "2", "unit": "tsp", "substitutions": []},
        {"name": "salt", "quantity": "1", "unit": "tsp", "substitutions": []}
    ]'::json,
    'Mix dry ingredients in a bowl. In another bowl, whisk together milk, eggs. Combine wet and dry ingredients. Cook on griddle until golden brown.',
    'Whisk flour, sugar, baking powder, and salt in large bowl. In separate bowl, beat milk and eggs. Pour wet ingredients into dry and stir until just combined. Heat griddle over medium heat. Pour 1/4 cup batter per pancake. Cook until bubbles form and edges set, then flip. Cook until golden brown.',
    'Don''t overmix batter - lumps are fine for fluffy pancakes. Let batter rest 5 minutes before cooking. Adjust heat if browning too quickly.',
    '["large mixing bowls", "whisk", "griddle", "spatula", "measuring cups"]'::json,
    'American',
    'breakfast',
    10,
    15,
    '{"calories": 320, "protein": 12, "fat": 8, "carbs": 52, "fiber": 2, "sugar": 12, "sodium": 580, "calcium": 180, "iron": 3}'::json,
    300,
    'easy',
    'https://example.com/images/classic-pancakes.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 2: Chicken Stir Fry (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Chicken Stir Fry',
    'Quick and healthy chicken stir fry with vegetables',
    '[
        {"name": "chicken breast", "quantity": "1", "unit": "lb", "substitutions": ["chicken thighs", "tofu"]},
        {"name": "bell peppers", "quantity": "2", "unit": "pieces", "substitutions": ["snap peas"]},
        {"name": "onion", "quantity": "1", "unit": "pieces", "substitutions": ["shallots"]},
        {"name": "soy sauce", "quantity": "3", "unit": "tbsp", "substitutions": ["tamari"]},
        {"name": "garlic", "quantity": "3", "unit": "cloves", "substitutions": ["garlic powder"]},
        {"name": "vegetable oil", "quantity": "2", "unit": "tbsp", "substitutions": ["peanut oil"]}
    ]'::json,
    'Cut chicken into strips. Heat oil in wok. Cook chicken until done. Add vegetables and stir fry. Add soy sauce and garlic.',
    'Cut chicken into thin strips and season with salt and pepper. Heat oil in large wok or skillet over high heat. Add chicken and cook 4-5 minutes until golden. Add onion and bell peppers, stir fry 3-4 minutes. Add garlic and cook 30 seconds. Add soy sauce and toss to combine. Serve over rice.',
    'Use high heat for best stir fry results. Cut all ingredients before starting as cooking goes quickly. Don''t overcrowd the pan.',
    '["large wok or skillet", "cutting board", "sharp knife", "wooden spoon"]'::json,
    'Asian',
    'dinner',
    15,
    20,
    '{"calories": 285, "protein": 35, "fat": 10, "carbs": 12, "fiber": 3, "sugar": 8, "sodium": 920, "vitamin_c": 120, "iron": 2}'::json,
    800,
    'medium',
    'https://example.com/images/chicken-stir-fry.jpg',
    3,
    true,
    NOW(),
    NOW()
);

-- Recipe 3: Caesar Salad (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Caesar Salad',
    'Fresh and crispy Caesar salad with homemade dressing',
    '[
        {"name": "romaine lettuce", "quantity": "1", "unit": "head", "substitutions": ["mixed greens"]},
        {"name": "parmesan cheese", "quantity": "0.5", "unit": "cup", "substitutions": ["pecorino romano"]},
        {"name": "croutons", "quantity": "1", "unit": "cup", "substitutions": ["toasted bread cubes"]},
        {"name": "caesar dressing", "quantity": "0.25", "unit": "cup", "substitutions": ["homemade dressing"]},
        {"name": "lemon", "quantity": "1", "unit": "piece", "substitutions": ["lime"]}
    ]'::json,
    'Wash and chop lettuce. Add croutons and parmesan. Drizzle with dressing and toss.',
    'Wash romaine lettuce thoroughly and pat dry. Chop into bite-sized pieces and place in large bowl. Add croutons and grated parmesan cheese. Drizzle with Caesar dressing and squeeze fresh lemon juice over top. Toss well to coat all leaves. Serve immediately.',
    'Use fresh, crisp romaine lettuce for best texture. Make your own croutons by toasting cubed bread with olive oil and garlic. Freshly grated parmesan tastes much better than pre-grated.',
    '["large salad bowl", "cutting board", "sharp knife", "cheese grater"]'::json,
    'Italian',
    'lunch',
    10,
    0,
    '{"calories": 220, "protein": 8, "fat": 18, "carbs": 8, "fiber": 3, "sugar": 3, "sodium": 480, "calcium": 200, "vitamin_a": 2800}'::json,
    400,
    'easy',
    'https://example.com/images/caesar-salad.jpg',
    2,
    true,
    NOW(),
    NOW()
);

-- Recipe 4: Beef Tacos (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Beef Tacos',
    'Delicious ground beef tacos with fresh toppings',
    '[
        {"name": "ground beef", "quantity": "1", "unit": "lb", "substitutions": ["ground turkey", "ground chicken"]},
        {"name": "taco shells", "quantity": "8", "unit": "pieces", "substitutions": ["soft tortillas"]},
        {"name": "lettuce", "quantity": "1", "unit": "cup", "substitutions": ["cabbage"]},
        {"name": "tomatoes", "quantity": "2", "unit": "pieces", "substitutions": ["cherry tomatoes"]},
        {"name": "cheese", "quantity": "1", "unit": "cup", "substitutions": ["mexican cheese blend"]},
        {"name": "taco seasoning", "quantity": "1", "unit": "packet", "substitutions": ["homemade spice mix"]}
    ]'::json,
    'Brown ground beef. Add taco seasoning. Warm taco shells. Fill with beef and toppings.',
    'Brown ground beef in large skillet over medium-high heat, breaking up with spoon. Drain excess fat. Add taco seasoning and water according to package directions. Simmer until thickened. Warm taco shells in oven or microwave. Dice tomatoes and shred lettuce. Fill shells with beef mixture and top with lettuce, tomatoes, and cheese.',
    'Drain excess fat from beef for healthier tacos. Warm taco shells for better flavor and flexibility. Set up taco bar for fun family-style serving.',
    '["large skillet", "cutting board", "sharp knife", "baking sheet"]'::json,
    'Mexican',
    'dinner',
    10,
    15,
    '{"calories": 320, "protein": 22, "fat": 16, "carbs": 22, "fiber": 3, "sugar": 4, "sodium": 680, "iron": 3, "vitamin_c": 15}'::json,
    600,
    'easy',
    'https://example.com/images/beef-tacos.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 5: Greek Yogurt Parfait (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Greek Yogurt Parfait',
    'Healthy breakfast parfait with yogurt, berries, and granola',
    '[
        {"name": "greek yogurt", "quantity": "1", "unit": "cup", "substitutions": ["regular yogurt", "coconut yogurt"]},
        {"name": "mixed berries", "quantity": "0.5", "unit": "cup", "substitutions": ["strawberries", "blueberries"]},
        {"name": "granola", "quantity": "0.25", "unit": "cup", "substitutions": ["muesli", "chopped nuts"]},
        {"name": "honey", "quantity": "2", "unit": "tbsp", "substitutions": ["maple syrup", "agave"]}
    ]'::json,
    'Layer yogurt, berries, and granola in a glass. Drizzle with honey.',
    'Start with a layer of Greek yogurt in bottom of glass or bowl. Add a layer of mixed berries. Sprinkle granola over berries. Repeat layers if desired. Drizzle honey over top layer. Serve immediately for best texture.',
    'Use thick Greek yogurt for best consistency. Fresh berries work best but frozen (thawed) berries are fine too. Add granola just before serving to keep it crunchy.',
    '["tall glasses or bowls", "spoon", "measuring cups"]'::json,
    'Mediterranean',
    'breakfast',
    5,
    0,
    '{"calories": 280, "protein": 18, "fat": 6, "carbs": 42, "fiber": 5, "sugar": 32, "sodium": 85, "calcium": 250, "probiotics": "yes"}'::json,
    250,
    'easy',
    'https://example.com/images/greek-yogurt-parfait.jpg',
    1,
    true,
    NOW(),
    NOW()
);

-- Recipe 6: Vegetable Pasta (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Vegetable Pasta',
    'Fresh pasta with seasonal vegetables',
    '[
        {"name": "pasta", "quantity": "12", "unit": "oz", "substitutions": ["whole wheat pasta", "gluten-free pasta"]},
        {"name": "zucchini", "quantity": "1", "unit": "piece", "substitutions": ["yellow squash"]},
        {"name": "bell pepper", "quantity": "1", "unit": "piece", "substitutions": ["cherry tomatoes"]},
        {"name": "olive oil", "quantity": "3", "unit": "tbsp", "substitutions": ["avocado oil"]},
        {"name": "garlic", "quantity": "4", "unit": "cloves", "substitutions": ["garlic powder"]},
        {"name": "parmesan", "quantity": "0.5", "unit": "cup", "substitutions": ["nutritional yeast"]}
    ]'::json,
    'Cook pasta according to package directions. Sauté vegetables with garlic and olive oil. Toss with pasta and parmesan.',
    'Bring large pot of salted water to boil. Cook pasta according to package directions until al dente. Meanwhile, dice zucchini and bell pepper. Heat olive oil in large skillet over medium heat. Add garlic and cook 30 seconds until fragrant. Add vegetables and sauté 5-7 minutes until tender-crisp. Drain pasta, reserving 1/2 cup pasta water. Add pasta to skillet with vegetables. Toss with parmesan and pasta water as needed. Season with salt and pepper.',
    'Don''t overcook vegetables - they should be tender-crisp. Save some pasta water to help bind the sauce. Use freshly grated parmesan for best flavor.',
    '["large pot", "large skillet", "colander", "cutting board", "sharp knife"]'::json,
    'Italian',
    'dinner',
    15,
    25,
    '{"calories": 380, "protein": 14, "fat": 12, "carbs": 58, "fiber": 4, "sugar": 6, "sodium": 320, "vitamin_c": 45, "folate": 120}'::json,
    500,
    'medium',
    'https://example.com/images/vegetable-pasta.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 7: Avocado Toast (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Avocado Toast',
    'Simple and nutritious avocado toast',
    '[
        {"name": "bread", "quantity": "2", "unit": "slices", "substitutions": ["whole grain bread", "sourdough"]},
        {"name": "avocado", "quantity": "1", "unit": "piece", "substitutions": []},
        {"name": "lime", "quantity": "0.5", "unit": "piece", "substitutions": ["lemon"]},
        {"name": "salt", "quantity": "1", "unit": "pinch", "substitutions": ["sea salt"]},
        {"name": "red pepper flakes", "quantity": "1", "unit": "pinch", "substitutions": ["black pepper"]}
    ]'::json,
    'Toast bread. Mash avocado with lime juice and salt. Spread on toast and sprinkle with red pepper flakes.',
    'Toast bread slices until golden brown and crispy. Cut avocado in half, remove pit, and scoop flesh into bowl. Mash avocado with fork until mostly smooth but still chunky. Add lime juice and salt, mix well. Spread avocado mixture evenly on toast. Sprinkle with red pepper flakes and additional salt if desired. Serve immediately.',
    'Use ripe but firm avocados for best texture. Add lime juice immediately to prevent browning. Toast should be crispy enough to support the avocado without getting soggy.',
    '["toaster", "small bowl", "fork", "knife"]'::json,
    'American',
    'breakfast',
    5,
    2,
    '{"calories": 240, "protein": 6, "fat": 16, "carbs": 22, "fiber": 10, "sugar": 2, "sodium": 320, "potassium": 485, "folate": 60}'::json,
    200,
    'easy',
    'https://example.com/images/avocado-toast.jpg',
    1,
    true,
    NOW(),
    NOW()
);

-- Recipe 8: Chicken Caesar Wrap (Updated with nutritional info)
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Chicken Caesar Wrap',
    'Protein-packed Caesar salad in a wrap',
    '[
        {"name": "tortilla", "quantity": "1", "unit": "large", "substitutions": ["whole wheat tortilla", "spinach tortilla"]},
        {"name": "grilled chicken", "quantity": "4", "unit": "oz", "substitutions": ["rotisserie chicken", "chicken breast"]},
        {"name": "romaine lettuce", "quantity": "1", "unit": "cup", "substitutions": ["mixed greens"]},
        {"name": "caesar dressing", "quantity": "2", "unit": "tbsp", "substitutions": ["ranch dressing"]},
        {"name": "parmesan cheese", "quantity": "2", "unit": "tbsp", "substitutions": ["romano cheese"]}
    ]'::json,
    'Warm tortilla. Mix chicken with lettuce, dressing, and cheese. Wrap and serve.',
    'Warm tortilla in microwave for 15-20 seconds or in dry skillet for 30 seconds per side. Slice grilled chicken into strips. Chop romaine lettuce into bite-sized pieces. In bowl, combine chicken, lettuce, Caesar dressing, and parmesan cheese. Mix well. Place mixture in center of tortilla. Fold bottom edge up, fold in sides, then roll tightly. Cut in half diagonally and serve.',
    'Warm tortilla makes it more pliable and easier to wrap. Don''t overfill or wrap will be difficult to close. Use leftover grilled chicken or rotisserie chicken for convenience.',
    '["microwave or skillet", "cutting board", "sharp knife", "mixing bowl"]'::json,
    'American',
    'lunch',
    5,
    0,
    '{"calories": 420, "protein": 32, "fat": 18, "carbs": 32, "fiber": 3, "sugar": 3, "sodium": 890, "calcium": 180, "vitamin_a": 1200}'::json,
    350,
    'easy',
    'https://example.com/images/chicken-caesar-wrap.jpg',
    1,
    true,
    NOW(),
    NOW()
);

-- Verify the inserts
SELECT 
    id,
    name,
    cuisine_type,
    meal_type,
    difficulty_level,
    prep_time_minutes + cook_time_minutes as total_time,
    servings,
    (nutritional_info->>'calories')::int as calories
FROM recipes
WHERE name IN (
    'Classic Pancakes', 'Chicken Stir Fry', 'Caesar Salad', 'Beef Tacos',
    'Greek Yogurt Parfait', 'Vegetable Pasta', 'Avocado Toast', 'Chicken Caesar Wrap'
)
ORDER BY id; 