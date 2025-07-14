-- Recipe Seed Data SQL Script
-- Inserts sample recipes for the Foodi application

-- Clean up existing data (optional)
-- DELETE FROM recipes;

-- Recipe 1: Chicken Stir Fry
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Quick Chicken Stir Fry',
    'Colorful and healthy chicken stir fry with fresh vegetables in a savory sauce. Ready in under 20 minutes!',
    '[
        {"name": "chicken breast", "quantity": "1 lb", "unit": "pound", "substitutions": ["chicken thighs", "tofu"]},
        {"name": "broccoli florets", "quantity": "2 cups", "unit": "cups", "substitutions": ["cauliflower"]},
        {"name": "bell peppers", "quantity": "2", "unit": "whole", "substitutions": ["snap peas"]},
        {"name": "carrots", "quantity": "2 medium", "unit": "whole", "substitutions": ["baby corn"]},
        {"name": "garlic", "quantity": "3 cloves", "unit": "cloves", "substitutions": ["garlic powder"]},
        {"name": "fresh ginger", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["ground ginger"]},
        {"name": "soy sauce", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["tamari"]},
        {"name": "oyster sauce", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["hoisin sauce"]},
        {"name": "cornstarch", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["arrowroot powder"]},
        {"name": "vegetable oil", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["peanut oil"]},
        {"name": "green onions", "quantity": "3", "unit": "whole", "substitutions": ["chives"]}
    ]'::json,
    'Cut chicken and vegetables. Make sauce. Stir fry chicken first, then vegetables. Combine with sauce and serve over rice.',
    '1. Cut chicken into bite-sized pieces and slice all vegetables uniformly for even cooking. 2. Mix soy sauce, oyster sauce, and cornstarch in a small bowl to make the sauce. 3. Heat oil in a large wok or skillet over high heat until smoking. 4. Add chicken and stir fry for 3-4 minutes until golden and cooked through. 5. Add garlic and ginger, stir for 30 seconds until fragrant. 6. Add vegetables starting with hardest ones first, stir fry for 3-4 minutes until crisp-tender. 7. Pour sauce over everything and toss until well coated and sauce thickens. 8. Garnish with green onions and serve immediately over steamed rice.',
    'Use high heat and keep ingredients moving for best stir fry texture. Cut all ingredients before you start cooking as it moves very quickly. Don''t overcrowd the pan - cook in batches if needed. Vegetables should be crisp-tender, not mushy.',
    '["large wok or skillet", "cutting board", "sharp knife", "small mixing bowl", "wooden spoon or spatula"]'::json,
    'Asian',
    'dinner',
    15,
    10,
    '{"calories": 280, "protein": 28, "fat": 8, "carbs": 18, "fiber": 4, "sugar": 8, "sodium": 890}'::json,
    1200,
    'easy',
    'https://example.com/images/chicken-stir-fry.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 2: Caprese Salad
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Fresh Caprese Salad',
    'Classic Italian salad with ripe tomatoes, fresh mozzarella, and basil drizzled with balsamic glaze.',
    '[
        {"name": "large tomatoes", "quantity": "3", "unit": "whole", "substitutions": ["cherry tomatoes"]},
        {"name": "fresh mozzarella", "quantity": "8 oz", "unit": "ounces", "substitutions": ["burrata cheese"]},
        {"name": "fresh basil leaves", "quantity": "1/4 cup", "unit": "cup", "substitutions": ["arugula"]},
        {"name": "extra virgin olive oil", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "balsamic vinegar", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["balsamic glaze"]},
        {"name": "sea salt", "quantity": "to taste", "unit": "", "substitutions": []},
        {"name": "black pepper", "quantity": "to taste", "unit": "", "substitutions": []},
        {"name": "honey", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": ["sugar"]}
    ]'::json,
    'Slice tomatoes and mozzarella. Arrange with basil leaves. Drizzle with olive oil and balsamic reduction. Season with salt and pepper.',
    '1. Slice tomatoes into 1/4 inch thick rounds and arrange on a large platter. 2. Slice mozzarella into similar thickness and alternate with tomato slices. 3. Tuck fresh basil leaves between tomato and mozzarella slices. 4. In a small saucepan, simmer balsamic vinegar with honey until reduced by half and syrupy. 5. Drizzle olive oil over the salad, then the balsamic reduction. 6. Season with sea salt and freshly cracked black pepper. 7. Let sit for 10 minutes before serving to allow flavors to meld.',
    'Use the ripest tomatoes you can find for best flavor. Fresh mozzarella should be soft and creamy, not the firm kind. Make balsamic reduction ahead of time as it needs to cool. Serve at room temperature for optimal taste.',
    '["large platter", "sharp knife", "cutting board", "small saucepan", "spoon"]'::json,
    'Italian',
    'lunch',
    15,
    5,
    '{"calories": 220, "protein": 12, "fat": 16, "carbs": 8, "fiber": 2, "sugar": 6, "sodium": 320}'::json,
    1000,
    'easy',
    'https://example.com/images/caprese-salad.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 3: Avocado Toast with Poached Egg
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Avocado Toast with Poached Egg',
    'Creamy avocado on toasted sourdough topped with a perfectly poached egg. A nutritious and Instagram-worthy breakfast.',
    '[
        {"name": "sourdough bread", "quantity": "2 slices", "unit": "slices", "substitutions": ["whole grain bread", "multigrain bread"]},
        {"name": "ripe avocado", "quantity": "1 large", "unit": "whole", "substitutions": []},
        {"name": "fresh eggs", "quantity": "2", "unit": "whole", "substitutions": []},
        {"name": "lemon juice", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": ["lime juice"]},
        {"name": "red pepper flakes", "quantity": "pinch", "unit": "", "substitutions": ["black pepper"]},
        {"name": "sea salt", "quantity": "to taste", "unit": "", "substitutions": []},
        {"name": "white vinegar", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "cherry tomatoes", "quantity": "4", "unit": "whole", "substitutions": []}
    ]'::json,
    'Toast bread. Mash avocado with lemon and seasonings. Poach eggs. Assemble toast with avocado and top with egg.',
    '[
        {"step": 1, "instruction": "Toast sourdough slices until golden brown and crispy.", "duration_minutes": 3, "tips": "Toast should be crispy enough to support toppings"},
        {"step": 2, "instruction": "Mash avocado with lemon juice, salt, and pepper until smooth but still chunky.", "duration_minutes": 2, "tips": "Add lemon juice immediately to prevent browning"},
        {"step": 3, "instruction": "Bring water to gentle simmer, add vinegar, create whirlpool and drop in cracked egg.", "duration_minutes": 4, "tips": "Fresh eggs hold together better when poaching"},
        {"step": 4, "instruction": "Poach eggs for 3-4 minutes until whites are set but yolks remain runny.", "duration_minutes": 4, "tips": "Use a slotted spoon to test firmness gently"},
        {"step": 5, "instruction": "Spread avocado on toast, top with poached egg, halved cherry tomatoes, and seasonings.", "duration_minutes": 2, "tips": "Serve immediately while egg is warm"}
    ]'::json,
    '[
        {"tip": "Use the freshest eggs possible for best poaching results", "category": "ingredient"},
        {"tip": "Create a gentle whirlpool in the water before adding egg", "category": "technique"},
        {"tip": "Trim any wispy egg whites with kitchen shears for presentation", "category": "presentation"}
    ]'::json,
    '["toaster", "medium saucepan", "slotted spoon", "small bowl", "fork"]'::json,
    'Modern',
    'breakfast',
    10,
    8,
    '{"calories": 320, "protein": 16, "fat": 22, "carbs": 18, "fiber": 8, "sugar": 3, "sodium": 380}'::json,
    800,
    'easy',
    'https://example.com/images/avocado-toast.jpg',
    2,
    true,
    NOW(),
    NOW()
);


-- Recipe 5: Chocolate Chip Cookies
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Classic Chocolate Chip Cookies',
    'Soft, chewy chocolate chip cookies with crispy edges. The perfect homemade treat that everyone loves.',
    '[
        {"name": "all-purpose flour", "quantity": "2 1/4 cups", "unit": "cups", "substitutions": ["bread flour"]},
        {"name": "baking soda", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "salt", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "butter", "quantity": "1 cup", "unit": "cup", "substitutions": ["margarine"]},
        {"name": "granulated sugar", "quantity": "3/4 cup", "unit": "cup", "substitutions": []},
        {"name": "brown sugar", "quantity": "3/4 cup", "unit": "cup", "substitutions": []},
        {"name": "vanilla extract", "quantity": "2 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "large eggs", "quantity": "2", "unit": "whole", "substitutions": []},
        {"name": "chocolate chips", "quantity": "2 cups", "unit": "cups", "substitutions": ["chocolate chunks", "chopped chocolate"]}
    ]'::json,
    'Cream butter and sugars. Add eggs and vanilla. Mix in dry ingredients. Fold in chocolate chips. Bake.',
    '[
        {"step": 1, "instruction": "Preheat oven to 375°F and line baking sheets with parchment paper.", "duration_minutes": 5, "tips": "Room temperature ingredients mix better"},
        {"step": 2, "instruction": "Cream softened butter with both sugars until light and fluffy, about 3 minutes.", "duration_minutes": 4, "tips": "Proper creaming creates the perfect texture"},
        {"step": 3, "instruction": "Beat in eggs one at a time, then vanilla extract until well combined.", "duration_minutes": 2, "tips": "Scrape bowl sides to ensure even mixing"},
        {"step": 4, "instruction": "In separate bowl, whisk flour, baking soda, and salt. Gradually mix into butter mixture.", "duration_minutes": 3, "tips": "Don''t overmix once flour is added"},
        {"step": 5, "instruction": "Fold in chocolate chips. Drop rounded tablespoons onto baking sheets, bake 9-11 minutes.", "duration_minutes": 11, "tips": "Cookies are done when edges are golden but centers look slightly underbaked"}
    ]'::json,
    '[
        {"tip": "Chill dough for 30 minutes for thicker cookies", "category": "technique"},
        {"tip": "Use a mix of chocolate chips and chunks for texture variety", "category": "ingredient"},
        {"tip": "Slightly underbake for chewy cookies, bake longer for crispy", "category": "technique"}
    ]'::json,
    '["electric mixer", "large mixing bowls", "baking sheets", "parchment paper", "cookie scoop"]'::json,
    'American',
    'snack',
    15,
    12,
    '{"calories": 180, "protein": 2, "fat": 8, "carbs": 26, "fiber": 1, "sugar": 18, "sodium": 140}'::json,
    600,
    'easy',
    'https://example.com/images/chocolate-chip-cookies.jpg',
    24,
    true,
    NOW(),
    NOW()
);

-- Recipe 6: Greek Salad
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Traditional Greek Salad',
    'Fresh and vibrant Greek salad with tomatoes, cucumbers, olives, and feta cheese in a simple olive oil dressing.',
    '[
        {"name": "tomatoes", "quantity": "4 large", "unit": "whole", "substitutions": ["cherry tomatoes"]},
        {"name": "cucumber", "quantity": "1 large", "unit": "whole", "substitutions": []},
        {"name": "red onion", "quantity": "1/2 medium", "unit": "whole", "substitutions": ["white onion"]},
        {"name": "green bell pepper", "quantity": "1", "unit": "whole", "substitutions": []},
        {"name": "Kalamata olives", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["black olives"]},
        {"name": "feta cheese", "quantity": "6 oz", "unit": "ounces", "substitutions": ["goat cheese"]},
        {"name": "extra virgin olive oil", "quantity": "1/4 cup", "unit": "cup", "substitutions": []},
        {"name": "red wine vinegar", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["lemon juice"]},
        {"name": "dried oregano", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": ["fresh oregano"]},
        {"name": "salt", "quantity": "to taste", "unit": "", "substitutions": []},
        {"name": "black pepper", "quantity": "to taste", "unit": "", "substitutions": []}
    ]'::json,
    'Chop vegetables. Make dressing. Combine vegetables with olives and feta. Dress and serve.',
    '[
        {"step": 1, "instruction": "Cut tomatoes into wedges, cucumber into thick slices, and bell pepper into strips.", "duration_minutes": 8, "tips": "Use ripe, in-season tomatoes for best flavor"},
        {"step": 2, "instruction": "Slice red onion thinly and soak in cold water for 10 minutes to reduce sharpness.", "duration_minutes": 2, "tips": "Soaking onions makes them milder and crispier"},
        {"step": 3, "instruction": "Whisk together olive oil, vinegar, oregano, salt, and pepper for dressing.", "duration_minutes": 2, "tips": "Let dressing sit to allow oregano to bloom"},
        {"step": 4, "instruction": "Combine vegetables and olives in large bowl, add crumbled feta on top.", "duration_minutes": 3, "tips": "Add feta last to prevent it from breaking up too much"},
        {"step": 5, "instruction": "Drizzle with dressing and toss gently. Let sit 10 minutes before serving.", "duration_minutes": 2, "tips": "Letting it sit allows flavors to meld together"}
    ]'::json,
    '[
        {"tip": "Use the best quality olive oil you can afford", "category": "ingredient"},
        {"tip": "Don''t overdress - the vegetables should shine", "category": "technique"},
        {"tip": "Serve at room temperature for best flavor", "category": "serving"}
    ]'::json,
    '["large mixing bowl", "sharp knife", "cutting board", "whisk", "small bowl"]'::json,
    'Greek',
    'lunch',
    15,
    0,
    '{"calories": 220, "protein": 8, "fat": 18, "carbs": 10, "fiber": 4, "sugar": 7, "sodium": 580}'::json,
    900,
    'easy',
    'https://example.com/images/greek-salad.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 7: Banana Pancakes
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Fluffy Banana Pancakes',
    'Light, fluffy pancakes with mashed banana for natural sweetness. Perfect weekend breakfast treat.',
    '[
        {"name": "all-purpose flour", "quantity": "1 1/2 cups", "unit": "cups", "substitutions": ["whole wheat flour"]},
        {"name": "baking powder", "quantity": "2 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "salt", "quantity": "1/2 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "sugar", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["honey", "maple syrup"]},
        {"name": "ripe bananas", "quantity": "2 large", "unit": "whole", "substitutions": []},
        {"name": "milk", "quantity": "1 cup", "unit": "cup", "substitutions": ["almond milk", "oat milk"]},
        {"name": "large egg", "quantity": "1", "unit": "whole", "substitutions": ["flax egg"]},
        {"name": "melted butter", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["vegetable oil"]},
        {"name": "vanilla extract", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []}
    ]'::json,
    'Mix dry ingredients. Mash bananas with wet ingredients. Combine wet and dry. Cook pancakes on griddle.',
    '[
        {"step": 1, "instruction": "Whisk together flour, baking powder, salt, and sugar in a large bowl.", "duration_minutes": 2, "tips": "Sifting dry ingredients creates lighter pancakes"},
        {"step": 2, "instruction": "In separate bowl, mash bananas until mostly smooth, then whisk in milk, egg, butter, and vanilla.", "duration_minutes": 4, "tips": "Leave some small banana chunks for texture"},
        {"step": 3, "instruction": "Pour wet ingredients into dry ingredients and stir just until combined - lumps are okay.", "duration_minutes": 1, "tips": "Overmixing creates tough pancakes"},
        {"step": 4, "instruction": "Heat griddle or large skillet over medium heat and lightly grease with butter.", "duration_minutes": 2, "tips": "Test heat with a drop of water - it should sizzle"},
        {"step": 5, "instruction": "Pour 1/4 cup batter per pancake, cook until bubbles form and edges look set, then flip.", "duration_minutes": 6, "tips": "First side takes 2-3 minutes, second side 1-2 minutes"}
    ]'::json,
    '[
        {"tip": "Use very ripe bananas for maximum sweetness and flavor", "category": "ingredient"},
        {"tip": "Don''t overmix the batter - lumps are perfectly fine", "category": "technique"},
        {"tip": "Keep finished pancakes warm in 200°F oven", "category": "serving"}
    ]'::json,
    '["large mixing bowls", "whisk", "griddle or large skillet", "spatula", "measuring cups"]'::json,
    'American',
    'breakfast',
    10,
    15,
    '{"calories": 195, "protein": 5, "fat": 4, "carbs": 37, "fiber": 2, "sugar": 12, "sodium": 280}'::json,
    500,
    'easy',
    'https://example.com/images/banana-pancakes.jpg',
    6,
    true,
    NOW(),
    NOW()
);

-- Recipe 8: Thai Green Curry
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Thai Green Curry with Chicken',
    'Aromatic and spicy Thai green curry with tender chicken, vegetables, and fragrant herbs in coconut milk.',
    '[
        {"name": "chicken thighs", "quantity": "1.5 lbs", "unit": "pounds", "substitutions": ["chicken breast", "tofu"]},
        {"name": "green curry paste", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "coconut milk", "quantity": "14 oz", "unit": "can", "substitutions": []},
        {"name": "fish sauce", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["soy sauce"]},
        {"name": "brown sugar", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["palm sugar"]},
        {"name": "Thai eggplant", "quantity": "1 cup", "unit": "cup", "substitutions": ["regular eggplant"]},
        {"name": "bell peppers", "quantity": "2", "unit": "whole", "substitutions": []},
        {"name": "Thai basil", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["regular basil"]},
        {"name": "lime", "quantity": "2", "unit": "whole", "substitutions": []},
        {"name": "jasmine rice", "quantity": "2 cups", "unit": "cups", "substitutions": ["brown rice"]}
    ]'::json,
    'Cook curry paste in coconut milk. Add chicken and vegetables. Simmer until tender. Serve over rice.',
    '[
        {"step": 1, "instruction": "Cut chicken into bite-sized pieces and season with salt and pepper.", "duration_minutes": 5, "tips": "Thighs stay more tender than breast meat"},
        {"step": 2, "instruction": "Heat 1/4 cup coconut milk in large pan, add curry paste and cook until fragrant.", "duration_minutes": 3, "tips": "Frying the paste releases its full flavor"},
        {"step": 3, "instruction": "Add chicken and cook until no longer pink, then add remaining coconut milk.", "duration_minutes": 8, "tips": "Don''t worry if coconut milk looks separated"},
        {"step": 4, "instruction": "Add fish sauce, sugar, eggplant, and peppers. Simmer 15 minutes until vegetables are tender.", "duration_minutes": 15, "tips": "Taste and adjust seasoning as needed"},
        {"step": 5, "instruction": "Stir in Thai basil and lime juice. Serve immediately over jasmine rice.", "duration_minutes": 2, "tips": "Add basil at the end to preserve its fresh flavor"}
    ]'::json,
    '[
        {"tip": "Use full-fat coconut milk for richest flavor", "category": "ingredient"},
        {"tip": "Adjust spice level by varying curry paste amount", "category": "customization"},
        {"tip": "Thai eggplant doesn''t need peeling", "category": "preparation"}
    ]'::json,
    '["large skillet or wok", "rice cooker or pot", "cutting board", "sharp knife"]'::json,
    'Thai',
    'dinner',
    20,
    25,
    '{"calories": 420, "protein": 28, "fat": 24, "carbs": 28, "fiber": 3, "sugar": 8, "sodium": 890}'::json,
    1600,
    'medium',
    'https://example.com/images/green-curry.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 9: Classic Pancakes
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Classic Pancakes',
    'Fluffy and delicious pancakes perfect for breakfast. A timeless family favorite that''s simple to make.',
    '[
        {"name": "all-purpose flour", "quantity": "2", "unit": "cups", "substitutions": ["self-rising flour"]},
        {"name": "milk", "quantity": "1.5", "unit": "cups", "substitutions": ["buttermilk", "almond milk"]},
        {"name": "large eggs", "quantity": "2", "unit": "pieces", "substitutions": ["flax eggs"]},
        {"name": "granulated sugar", "quantity": "2", "unit": "tbsp", "substitutions": ["honey", "maple syrup"]},
        {"name": "baking powder", "quantity": "2", "unit": "tsp", "substitutions": []},
        {"name": "salt", "quantity": "1", "unit": "tsp", "substitutions": []},
        {"name": "melted butter", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["vegetable oil"]},
        {"name": "vanilla extract", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []}
    ]'::json,
    'Mix dry ingredients in a bowl. In another bowl, whisk together milk, eggs, melted butter, and vanilla. Combine wet and dry ingredients until just mixed. Cook on griddle until bubbles form and edges are set, then flip. Cook until golden brown.',
    '1. In a large bowl, whisk together flour, sugar, baking powder, and salt. Sift dry ingredients for extra fluffy pancakes. 2. In separate bowl, whisk together milk, eggs, melted butter, and vanilla until well combined. Let melted butter cool slightly to prevent cooking the eggs. 3. Pour wet ingredients into dry ingredients and stir just until combined - don''t overmix. Lumpy batter is perfectly fine and creates fluffier pancakes. 4. Heat griddle or large skillet over medium heat and lightly grease with butter or oil. Test temperature with a few drops of water - they should sizzle. 5. Pour 1/4 cup batter per pancake. Cook until bubbles form on surface and edges look set, then flip. First side takes 2-3 minutes, second side 1-2 minutes until golden brown. 6. Serve immediately with butter, maple syrup, or your favorite toppings. Keep warm in 200°F oven if making large batches.',
    'Don''t overmix the batter - lumps are your friend for fluffy pancakes. Let batter rest for 5 minutes before cooking for even fluffier results. Use a ladle or measuring cup for evenly sized pancakes. Adjust heat if pancakes brown too quickly or cook too slowly.',
    '["large mixing bowls", "whisk", "griddle or large skillet", "spatula", "measuring cups", "ladle"]'::json,
    'American',
    'breakfast',
    10,
    15,
    '{"calories": 300, "protein": 8, "fat": 8, "carbs": 48, "fiber": 2, "sugar": 8, "sodium": 520}'::json,
    400,
    'easy',
    'https://example.com/images/classic-pancakes.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 1: Korean Bibimbap
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Korean Bibimbap',
    'Colorful Korean rice bowl with marinated vegetables, beef, and fried egg topped with spicy gochujang sauce.',
    '[
        {"name": "short grain rice", "quantity": "2 cups", "unit": "cups", "substitutions": ["jasmine rice"]},
        {"name": "beef sirloin", "quantity": "8 oz", "unit": "ounces", "substitutions": ["tofu", "chicken"]},
        {"name": "spinach", "quantity": "4 cups", "unit": "cups", "substitutions": ["bok choy"]},
        {"name": "carrots", "quantity": "2", "unit": "whole", "substitutions": ["daikon radish"]},
        {"name": "shiitake mushrooms", "quantity": "6", "unit": "whole", "substitutions": ["button mushrooms"]},
        {"name": "bean sprouts", "quantity": "2 cups", "unit": "cups", "substitutions": ["mung beans"]},
        {"name": "eggs", "quantity": "4", "unit": "whole", "substitutions": []},
        {"name": "gochujang", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["sriracha"]},
        {"name": "sesame oil", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["vegetable oil"]},
        {"name": "soy sauce", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["tamari"]}
    ]'::json,
    'Cook rice. Marinate and cook beef. Prepare vegetables separately. Fry eggs. Assemble in bowls with gochujang.',
    'Cook rice and keep warm. Slice beef thin, marinate in soy sauce and sesame oil. Blanch spinach and season. Julienne carrots and sauté. Cook mushrooms and bean sprouts separately. Pan-fry beef until caramelized. Fry eggs sunny-side up. Divide rice among bowls, arrange vegetables and beef in sections. Top with fried egg and serve with gochujang sauce.',
    'Each vegetable should be seasoned separately for authentic flavor. Use stone bowl for traditional sizzling effect.',
    '["rice cooker", "large skillet", "multiple small bowls", "knife", "cutting board"]'::json,
    'Korean',
    'dinner',
    30,
    25,
    '{"calories": 520, "protein": 28, "fat": 16, "carbs": 68, "fiber": 6, "sugar": 8, "sodium": 1200}'::json,
    1200,
    'medium',
    'https://example.com/images/korean-bibimbap.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 2: Moroccan Chicken Tagine
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Moroccan Chicken Tagine',
    'Aromatic slow-cooked chicken with apricots, almonds, and warm spices in a traditional tagine.',
    '[
        {"name": "chicken thighs", "quantity": "2 lbs", "unit": "pounds", "substitutions": ["chicken breast"]},
        {"name": "dried apricots", "quantity": "1 cup", "unit": "cup", "substitutions": ["dates", "prunes"]},
        {"name": "almonds", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["pistachios"]},
        {"name": "onions", "quantity": "2", "unit": "whole", "substitutions": ["shallots"]},
        {"name": "ginger", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["ground ginger"]},
        {"name": "cinnamon", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "turmeric", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "chicken broth", "quantity": "2 cups", "unit": "cups", "substitutions": ["vegetable broth"]},
        {"name": "preserved lemons", "quantity": "2", "unit": "whole", "substitutions": ["lemon zest"]},
        {"name": "cilantro", "quantity": "1/4 cup", "unit": "cup", "substitutions": ["parsley"]}
    ]'::json,
    'Brown chicken. Sauté onions and spices. Add broth and apricots. Simmer 45 minutes. Garnish with almonds.',
    'Season chicken with salt and pepper. Brown in tagine or heavy pot. Remove chicken, sauté onions until soft. Add ginger, cinnamon, turmeric. Return chicken, add broth, apricots, preserved lemons. Cover and simmer 45 minutes until tender. Toast almonds and garnish with cilantro.',
    'Low and slow cooking develops deep flavors. Tagine pot gives authentic taste but heavy Dutch oven works too.',
    '["tagine or Dutch oven", "large spoon", "cutting board", "knife"]'::json,
    'Moroccan',
    'dinner',
    20,
    60,
    '{"calories": 380, "protein": 32, "fat": 18, "carbs": 22, "fiber": 4, "sugar": 16, "sodium": 680}'::json,
    1400,
    'medium',
    'https://example.com/images/moroccan-tagine.jpg',
    6,
    true,
    NOW(),
    NOW()
);

-- Recipe 3: Indian Butter Chicken
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Indian Butter Chicken',
    'Creamy tomato-based curry with tender marinated chicken in rich, aromatic sauce.',
    '[
        {"name": "chicken breast", "quantity": "2 lbs", "unit": "pounds", "substitutions": ["chicken thighs"]},
        {"name": "yogurt", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["coconut yogurt"]},
        {"name": "tomato sauce", "quantity": "1 can", "unit": "can", "substitutions": ["fresh tomatoes"]},
        {"name": "heavy cream", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["coconut milk"]},
        {"name": "butter", "quantity": "4 tbsp", "unit": "tablespoon", "substitutions": ["ghee"]},
        {"name": "garam masala", "quantity": "2 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "garlic", "quantity": "4 cloves", "unit": "cloves", "substitutions": ["garlic powder"]},
        {"name": "ginger", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["ground ginger"]},
        {"name": "onion", "quantity": "1", "unit": "whole", "substitutions": ["shallots"]},
        {"name": "basmati rice", "quantity": "2 cups", "unit": "cups", "substitutions": ["jasmine rice"]}
    ]'::json,
    'Marinate chicken in yogurt and spices. Cook chicken. Make tomato sauce with cream and butter. Combine and simmer.',
    'Marinate cubed chicken in yogurt, garlic, ginger, and spices for 2 hours. Cook chicken until golden. In same pan, sauté onions, add tomato sauce, cream, butter, and garam masala. Simmer until thick. Return chicken to sauce, cook 10 minutes. Serve over basmati rice with naan.',
    'Marinating chicken makes it incredibly tender. Adjust cream for desired richness. Taste and balance sweet, sour, spicy.',
    '["large skillet", "mixing bowl", "rice cooker", "wooden spoon"]'::json,
    'Indian',
    'dinner',
    25,
    30,
    '{"calories": 450, "protein": 35, "fat": 22, "carbs": 28, "fiber": 2, "sugar": 8, "sodium": 890}'::json,
    1000,
    'medium',
    'https://example.com/images/butter-chicken.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 4: Japanese Ramen
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Japanese Tonkotsu Ramen',
    'Rich, creamy pork bone broth ramen with tender chashu pork, soft-boiled eggs, and fresh toppings.',
    '[
        {"name": "ramen noodles", "quantity": "4 portions", "unit": "portions", "substitutions": ["fresh ramen noodles"]},
        {"name": "pork belly", "quantity": "1 lb", "unit": "pound", "substitutions": ["pork shoulder"]},
        {"name": "chicken broth", "quantity": "8 cups", "unit": "cups", "substitutions": ["pork broth"]},
        {"name": "miso paste", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["soy sauce"]},
        {"name": "eggs", "quantity": "4", "unit": "whole", "substitutions": []},
        {"name": "green onions", "quantity": "4", "unit": "whole", "substitutions": ["chives"]},
        {"name": "nori", "quantity": "4 sheets", "unit": "sheets", "substitutions": []},
        {"name": "bamboo shoots", "quantity": "1 cup", "unit": "cup", "substitutions": ["corn"]},
        {"name": "garlic", "quantity": "4 cloves", "unit": "cloves", "substitutions": []},
        {"name": "sesame oil", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": ["vegetable oil"]}
    ]'::json,
    'Prepare chashu pork. Make soft-boiled eggs. Heat broth with miso. Cook noodles. Assemble bowls with toppings.',
    'Braise pork belly in soy sauce until tender, slice. Soft-boil eggs for 6 minutes, marinate in soy sauce. Heat broth, whisk in miso paste. Cook ramen noodles according to package. Divide noodles among bowls, ladle hot broth over. Top with sliced pork, halved eggs, green onions, nori, and bamboo shoots.',
    'Timing is crucial - have all toppings ready before cooking noodles. Serve immediately while hot.',
    '["large pot", "small pot", "strainer", "ladle", "sharp knife"]'::json,
    'Japanese',
    'dinner',
    40,
    20,
    '{"calories": 520, "protein": 28, "fat": 26, "carbs": 45, "fiber": 3, "sugar": 4, "sodium": 1400}'::json,
    1600,
    'hard',
    'https://example.com/images/tonkotsu-ramen.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 5: French Croque Monsieur
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'French Croque Monsieur',
    'Classic French grilled ham and cheese sandwich topped with creamy béchamel sauce and more cheese.',
    '[
        {"name": "brioche bread", "quantity": "4 slices", "unit": "slices", "substitutions": ["white bread"]},
        {"name": "ham", "quantity": "6 oz", "unit": "ounces", "substitutions": ["turkey"]},
        {"name": "gruyere cheese", "quantity": "4 oz", "unit": "ounces", "substitutions": ["swiss cheese"]},
        {"name": "butter", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "flour", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "milk", "quantity": "1 cup", "unit": "cup", "substitutions": ["whole milk"]},
        {"name": "nutmeg", "quantity": "pinch", "unit": "", "substitutions": []},
        {"name": "dijon mustard", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["yellow mustard"]}
    ]'::json,
    'Make béchamel sauce. Assemble sandwiches with ham and cheese. Top with sauce and more cheese. Bake until golden.',
    'Make béchamel: melt butter, whisk in flour, gradually add milk until thick. Season with salt, pepper, nutmeg. Spread mustard on bread, add ham and half the cheese. Make sandwiches. Top with béchamel and remaining cheese. Bake at 400°F for 10-12 minutes until golden and bubbly.',
    'Don''t skip the béchamel - it makes this sandwich special. Use good quality ham and cheese for best results.',
    '["small saucepan", "whisk", "baking sheet", "knife"]'::json,
    'French',
    'lunch',
    15,
    15,
    '{"calories": 480, "protein": 26, "fat": 28, "carbs": 32, "fiber": 2, "sugar": 6, "sodium": 1200}'::json,
    800,
    'medium',
    'https://example.com/images/croque-monsieur.jpg',
    2,
    true,
    NOW(),
    NOW()
);

-- Recipe 6: Mexican Shrimp Quesadillas
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Mexican Shrimp Quesadillas',
    'Crispy quesadillas filled with seasoned shrimp, peppers, and melted cheese. Served with salsa and sour cream.',
    '[
        {"name": "large shrimp", "quantity": "1 lb", "unit": "pound", "substitutions": ["chicken", "crab"]},
        {"name": "flour tortillas", "quantity": "4", "unit": "whole", "substitutions": ["corn tortillas"]},
        {"name": "monterey jack cheese", "quantity": "2 cups", "unit": "cups", "substitutions": ["cheddar cheese"]},
        {"name": "bell peppers", "quantity": "2", "unit": "whole", "substitutions": ["poblano peppers"]},
        {"name": "red onion", "quantity": "1", "unit": "whole", "substitutions": ["yellow onion"]},
        {"name": "cumin", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "chili powder", "quantity": "1 tsp", "unit": "teaspoon", "substitutions": []},
        {"name": "lime", "quantity": "2", "unit": "whole", "substitutions": ["lemon"]},
        {"name": "cilantro", "quantity": "1/4 cup", "unit": "cup", "substitutions": ["parsley"]}
    ]'::json,
    'Season and cook shrimp. Sauté peppers and onions. Fill tortillas with shrimp, vegetables, and cheese. Cook until crispy.',
    'Season shrimp with cumin, chili powder, salt, and lime juice. Cook shrimp 2-3 minutes per side until pink. Sauté peppers and onions until soft. Fill half of each tortilla with cheese, shrimp, vegetables, and cilantro. Fold over and cook in dry skillet 2-3 minutes per side until golden and cheese melts. Cut into wedges.',
    'Don''t overfill quesadillas or they''ll be hard to flip. Cook on medium heat to ensure cheese melts before tortilla burns.',
    '["large skillet", "spatula", "cutting board", "knife"]'::json,
    'Mexican',
    'lunch',
    15,
    12,
    '{"calories": 420, "protein": 32, "fat": 18, "carbs": 35, "fiber": 3, "sugar": 4, "sodium": 890}'::json,
    1100,
    'easy',
    'https://example.com/images/shrimp-quesadillas.jpg',
    4,
    true,
    NOW(),
    NOW()
);

-- Recipe 7: Italian Mushroom Risotto
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Italian Mushroom Risotto',
    'Creamy Arborio rice cooked with wild mushrooms, white wine, and parmesan cheese. Rich and comforting.',
    '[
        {"name": "arborio rice", "quantity": "1.5 cups", "unit": "cups", "substitutions": ["carnaroli rice"]},
        {"name": "mixed mushrooms", "quantity": "1 lb", "unit": "pound", "substitutions": ["shiitake mushrooms"]},
        {"name": "white wine", "quantity": "1/2 cup", "unit": "cup", "substitutions": ["chicken broth"]},
        {"name": "chicken broth", "quantity": "6 cups", "unit": "cups", "substitutions": ["vegetable broth"]},
        {"name": "onion", "quantity": "1", "unit": "whole", "substitutions": ["shallots"]},
        {"name": "parmesan cheese", "quantity": "1 cup", "unit": "cup", "substitutions": ["pecorino romano"]},
        {"name": "butter", "quantity": "4 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "olive oil", "quantity": "2 tbsp", "unit": "tablespoon", "substitutions": []},
        {"name": "garlic", "quantity": "3 cloves", "unit": "cloves", "substitutions": []},
        {"name": "fresh thyme", "quantity": "1 tbsp", "unit": "tablespoon", "substitutions": ["dried thyme"]}
    ]'::json,
    'Sauté mushrooms. Cook onions, add rice and toast. Add wine, then broth gradually while stirring. Finish with cheese and butter.',
    'Keep broth warm in separate pot. Sauté mushrooms until golden, set aside. Cook onions until soft, add rice and toast 2 minutes. Add wine, stir until absorbed. Add warm broth one ladle at a time, stirring constantly until absorbed before adding more. Continue 18-20 minutes until rice is creamy. Stir in mushrooms, parmesan, and butter.',
    'Constant stirring releases starch for creaminess. Add broth gradually and let each addition absorb. Taste rice - should be tender with slight bite.',
    '["large heavy-bottomed pan", "wooden spoon", "ladle", "separate pot for broth"]'::json,
    'Italian',
    'dinner',
    15,
    35,
    '{"calories": 380, "protein": 12, "fat": 14, "carbs": 52, "fiber": 3, "sugar": 4, "sodium": 680}'::json,
    1200,
    'medium',
    'https://example.com/images/mushroom-risotto.jpg',
    6,
    true,
    NOW(),
    NOW()
);

-- Recipe 8: Vietnamese Pho
INSERT INTO recipes (
    name, description, ingredients, instructions, detailed_instructions,
    cooking_tips, equipment_needed, cuisine_type, meal_type,
    prep_time_minutes, cook_time_minutes, nutritional_info,
    estimated_cost_usd, difficulty_level, image_url, servings,
    is_active, created_at, updated_at
) VALUES (
    'Vietnamese Pho Bo',
    'Aromatic Vietnamese beef noodle soup with rice noodles, herbs, and tender beef in fragrant broth.',
    '[
        {"name": "beef bones", "quantity": "2 lbs", "unit": "pounds", "substitutions": ["chicken bones"]},
        {"name": "beef brisket", "quantity": "1 lb", "unit": "pound", "substitutions": ["beef chuck"]},
        {"name": "rice noodles", "quantity": "1 lb", "unit": "pound", "substitutions": ["fresh pho noodles"]},
        {"name": "onion", "quantity": "1", "unit": "whole", "substitutions": []},
        {"name": "ginger", "quantity": "3 inch", "unit": "piece", "substitutions": ["ground ginger"]},
        {"name": "star anise", "quantity": "6", "unit": "whole", "substitutions": []},
        {"name": "cinnamon stick", "quantity": "1", "unit": "stick", "substitutions": ["ground cinnamon"]},
        {"name": "fish sauce", "quantity": "3 tbsp", "unit": "tablespoon", "substitutions": ["soy sauce"]},
        {"name": "bean sprouts", "quantity": "2 cups", "unit": "cups", "substitutions": []},
        {"name": "thai basil", "quantity": "1 cup", "unit": "cup", "substitutions": ["regular basil"]},
        {"name": "lime", "quantity": "2", "unit": "whole", "substitutions": ["lemon"]}
    ]'::json,
    'Make aromatic broth with bones and spices. Cook brisket separately. Prepare noodles and herbs. Assemble bowls with hot broth.',
    'Char onion and ginger over flame until fragrant. Toast spices in dry pan. Simmer bones with charred vegetables and spices for 6+ hours, skimming foam. Cook brisket separately until tender, slice thin. Soak rice noodles in hot water until soft. Arrange noodles and beef in bowls, ladle hot broth over. Serve with herbs, bean sprouts, lime, and sauces.',
    'Long simmering develops complex flavors. Skim foam regularly for clear broth. Have all garnishes ready before serving.',
    '["large stock pot", "strainer", "ladle", "large bowls", "tongs"]'::json,
    'Vietnamese',
    'lunch',
    30,
    360,
    '{"calories": 420, "protein": 28, "fat": 8, "carbs": 58, "fiber": 2, "sugar": 6, "sodium": 1200}'::json,
    1400,
    'hard',
    'https://example.com/images/vietnamese-pho.jpg',
    6,
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
    servings
FROM recipes
ORDER BY id; 