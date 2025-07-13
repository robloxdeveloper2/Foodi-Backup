import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_detail_models.dart';
import '../models/recipe_models.dart';
import '../utils/app_constants.dart';

class RecipeDetailService {
  static const String baseUrl = AppConstants.baseUrl;
  static const bool _useMockData = false; // Set to false when backend is ready

  /// Get detailed recipe information
  Future<RecipeDetail?> getRecipeDetails(String recipeId, String token) async {
    if (_useMockData) {
      return _getMockRecipeDetail(recipeId);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/recipes/$recipeId'),
        headers: {
          'Content-Type': 'application/json',
          // Don't send Authorization header since this endpoint is public
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RecipeDetail.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Recipe not found
      } else {
        throw Exception('Failed to load recipe details: ${response.statusCode}');
      }
    } catch (e) {
      // Fall back to mock data on error
      return _getMockRecipeDetail(recipeId);
    }
  }

  /// Scale a recipe by the given factor
  Future<RecipeScaling> scaleRecipe(String recipeId, double scaleFactor, String token) async {
    if (_useMockData) {
      return _getMockRecipeScaling(recipeId, scaleFactor);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/recipes/$recipeId/scale'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'scale_factor': scaleFactor}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RecipeScaling.fromApiResponse(data);
      } else {
        throw Exception('Failed to scale recipe: ${response.statusCode}');
      }
    } catch (e) {
      // Fall back to mock data on error
      return _getMockRecipeScaling(recipeId, scaleFactor);
    }
  }

  // MOCK DATA METHODS
  RecipeDetail? _getMockRecipeDetail(String recipeId) {
    final mockRecipes = _getMockRecipes();
    
    // Try to find the recipe by ID - handle both string and integer IDs
    Recipe? baseRecipe;
    try {
      baseRecipe = mockRecipes.firstWhere(
        (recipe) => recipe.id == recipeId,
      );
    } catch (e) {
      // If direct match fails, try to match by converting integer ID to string format
      try {
        // If recipeId is a number (like "1"), try to find "recipe-1"
        final int? numericId = int.tryParse(recipeId);
        if (numericId != null) {
          try {
            baseRecipe = mockRecipes.firstWhere(
              (recipe) => recipe.id == 'recipe-$numericId',
            );
          } catch (e3) {
            // Create a fallback recipe for any integer ID that doesn't exist in mock data
            baseRecipe = Recipe(
              id: recipeId,
              name: 'Recipe #$recipeId',
              description: 'This recipe is from the database but details are not available in mock data.',
              ingredients: [
                Ingredient(name: 'Various ingredients', quantity: 'As needed', unit: ''),
              ],
              instructions: 'Recipe instructions are not available in mock data. Please check the database.',
              cuisineType: 'Various',
              mealType: 'dinner',
              prepTimeMinutes: 30,
              cookTimeMinutes: 30,
              nutritionalInfo: NutritionalInfo(calories: 300, protein: 15, carbs: 30, fat: 10),
              estimatedCostUsd: 1000,
              difficultyLevel: 'medium',
              servings: 4,
              isActive: true,
            );
          }
        } else {
          // If recipeId is like "recipe-1", try to find by just the number
          final match = RegExp(r'recipe-(\d+)').firstMatch(recipeId);
          if (match != null) {
            final numericPart = match.group(1);
            baseRecipe = mockRecipes.firstWhere(
              (recipe) => recipe.id == numericPart,
            );
          }
        }
      } catch (e2) {
        // Recipe not found - return null instead of falling back to first recipe
        return null;
      }
    }

    if (baseRecipe == null) {
      return null;
    }

    return RecipeDetail(
      baseRecipe: baseRecipe,
      steps: _getMockStepsForRecipe(baseRecipe.id),
      cookingTips: _getMockCookingTips(),
      equipmentNeeded: _getMockEquipment(baseRecipe.id),
    );
  }

  List<Recipe> _getMockRecipes() {
    return [
      Recipe(
        id: 'recipe-1',
        name: 'Classic Spaghetti Carbonara',
        description: 'A traditional Italian pasta dish with eggs, cheese, and pancetta. Rich, creamy, and absolutely delicious!',
        ingredients: [
          Ingredient(name: 'Spaghetti', quantity: '400', unit: 'g'),
          Ingredient(name: 'Pancetta', quantity: '150', unit: 'g'),
          Ingredient(name: 'Large eggs', quantity: '4', unit: 'pieces'),
          Ingredient(name: 'Parmesan cheese', quantity: '100', unit: 'g'),
          Ingredient(name: 'Black pepper', quantity: '1', unit: 'tsp'),
        ],
        instructions: 'Cook pasta, prepare sauce, combine and serve',
        cuisineType: 'Italian',
        mealType: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        nutritionalInfo: NutritionalInfo(calories: 520, protein: 28, carbs: 65, fat: 18, fiber: 3, sugar: 2, sodium: 450),
        estimatedCostUsd: 850, // $8.50 in cents
        difficultyLevel: 'medium',
        servings: 4,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-2',
        name: 'Chicken Tikka Masala',
        description: 'Tender chicken in a creamy, spiced tomato sauce',
        ingredients: [
          Ingredient(name: 'Chicken breast', quantity: '500', unit: 'g'),
          Ingredient(name: 'Yogurt', quantity: '200', unit: 'ml'),
          Ingredient(name: 'Tomato sauce', quantity: '400', unit: 'ml'),
          Ingredient(name: 'Heavy cream', quantity: '100', unit: 'ml'),
          Ingredient(name: 'Garam masala', quantity: '2', unit: 'tsp'),
        ],
        instructions: 'Marinate chicken, cook, prepare sauce, combine',
        cuisineType: 'Indian',
        mealType: 'dinner',
        prepTimeMinutes: 30,
        cookTimeMinutes: 25,
        nutritionalInfo: NutritionalInfo(calories: 420, protein: 35, carbs: 12, fat: 25),
        estimatedCostUsd: 1200, // $12.00 in cents
        difficultyLevel: 'medium',
        servings: 4,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-3',
        name: 'Avocado Toast',
        description: 'Simple and healthy breakfast with creamy avocado',
        ingredients: [
          Ingredient(name: 'Bread slices', quantity: '2', unit: 'pieces'),
          Ingredient(name: 'Avocado', quantity: '1', unit: 'large'),
          Ingredient(name: 'Lemon juice', quantity: '1', unit: 'tbsp'),
          Ingredient(name: 'Salt', quantity: 'to taste', unit: ''),
          Ingredient(name: 'Red pepper flakes', quantity: 'pinch', unit: ''),
        ],
        instructions: 'Toast bread, mash avocado, spread and season',
        cuisineType: 'American',
        mealType: 'breakfast',
        prepTimeMinutes: 5,
        cookTimeMinutes: 2,
        nutritionalInfo: NutritionalInfo(calories: 280, protein: 8, carbs: 30, fat: 18),
        estimatedCostUsd: 350, // $3.50 in cents
        difficultyLevel: 'easy',
        servings: 1,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-4',
        name: 'Beef Stir Fry',
        description: 'Quick and flavorful Asian-inspired dish',
        ingredients: [
          Ingredient(name: 'Beef strips', quantity: '300', unit: 'g'),
          Ingredient(name: 'Mixed vegetables', quantity: '400', unit: 'g'),
          Ingredient(name: 'Soy sauce', quantity: '3', unit: 'tbsp'),
          Ingredient(name: 'Garlic', quantity: '3', unit: 'cloves'),
          Ingredient(name: 'Ginger', quantity: '1', unit: 'inch'),
        ],
        instructions: 'Heat oil, cook beef, add vegetables, season and toss',
        cuisineType: 'Asian',
        mealType: 'dinner',
        prepTimeMinutes: 15,
        cookTimeMinutes: 10,
        nutritionalInfo: NutritionalInfo(calories: 350, protein: 30, carbs: 15, fat: 20),
        estimatedCostUsd: 950, // $9.50 in cents
        difficultyLevel: 'easy',
        servings: 3,
        isActive: true,
      ),
      Recipe(
        id: 'recipe-5',
        name: 'Caesar Salad',
        description: 'Crisp romaine lettuce with classic Caesar dressing',
        ingredients: [
          Ingredient(name: 'Romaine lettuce', quantity: '1', unit: 'head'),
          Ingredient(name: 'Parmesan cheese', quantity: '50', unit: 'g'),
          Ingredient(name: 'Croutons', quantity: '100', unit: 'g'),
          Ingredient(name: 'Caesar dressing', quantity: '4', unit: 'tbsp'),
        ],
        instructions: 'Wash lettuce, add dressing, top with cheese and croutons',
        cuisineType: 'American',
        mealType: 'lunch',
        prepTimeMinutes: 10,
        cookTimeMinutes: 0,
        nutritionalInfo: NutritionalInfo(calories: 220, protein: 12, carbs: 18, fat: 12),
        estimatedCostUsd: 600, // $6.00 in cents
        difficultyLevel: 'easy',
        servings: 2,
        isActive: true,
      ),
    ];
  }

  List<RecipeStep> _getMockStepsForRecipe(String recipeId) {
    switch (recipeId) {
      case 'recipe-1': // Carbonara
        return [
          RecipeStep(
            stepNumber: 1,
            instruction: 'Bring a large pot of salted water to boil. Cook spaghetti according to package directions until al dente.',
            durationMinutes: 10,
            tips: 'Save some pasta water before draining - it helps bind the sauce!',
          ),
          RecipeStep(
            stepNumber: 2,
            instruction: 'While pasta cooks, dice the pancetta and cook in a large skillet until crispy.',
            durationMinutes: 5,
            tips: 'No oil needed - pancetta will render its own fat.',
          ),
          RecipeStep(
            stepNumber: 3,
            instruction: 'In a bowl, whisk together eggs, grated Parmesan, and black pepper.',
            durationMinutes: 2,
          ),
          RecipeStep(
            stepNumber: 4,
            instruction: 'Drain pasta and immediately add to the skillet with pancetta. Remove from heat.',
            durationMinutes: 1,
          ),
          RecipeStep(
            stepNumber: 5,
            instruction: 'Quickly stir in the egg mixture, tossing constantly to create a creamy sauce without scrambling the eggs.',
            durationMinutes: 2,
            tips: 'Work quickly and keep tossing to prevent the eggs from cooking into chunks.',
          ),
          RecipeStep(
            stepNumber: 6,
            instruction: 'Serve immediately with extra Parmesan and freshly cracked black pepper.',
            tips: 'Carbonara is best enjoyed hot and fresh!',
          ),
        ];
      default:
        return [
          RecipeStep(
            stepNumber: 1,
            instruction: 'Prepare all your ingredients by washing, chopping, and measuring as needed.',
            durationMinutes: 10,
            tips: 'Having everything ready makes cooking much smoother!',
          ),
          RecipeStep(
            stepNumber: 2,
            instruction: 'Follow the cooking method appropriate for this dish.',
            durationMinutes: 15,
          ),
          RecipeStep(
            stepNumber: 3,
            instruction: 'Taste and adjust seasoning as needed.',
            durationMinutes: 2,
            tips: 'Always taste before serving and adjust salt, pepper, or other seasonings.',
          ),
          RecipeStep(
            stepNumber: 4,
            instruction: 'Serve hot and enjoy!',
            tips: 'Fresh dishes taste best when served immediately.',
          ),
        ];
    }
  }

  List<CookingTip> _getMockCookingTips() {
    return [
      CookingTip(tip: 'Use room temperature eggs for better incorporation', category: 'technique'),
      CookingTip(tip: 'Always taste and adjust seasoning at the end', category: 'technique'),
      CookingTip(tip: 'Let meat rest before slicing for juicier results', category: 'technique'),
      CookingTip(tip: 'Fresh herbs should be added at the end of cooking', category: 'ingredient'),
      CookingTip(tip: 'Salt pasta water generously - it should taste like seawater', category: 'technique'),
    ];
  }

  List<String> _getMockEquipment(String recipeId) {
    switch (recipeId) {
      case 'recipe-1': // Carbonara
        return ['Large pot', 'Skillet', 'Whisk', 'Grater', 'Tongs'];
      case 'recipe-2': // Tikka Masala
        return ['Large pot', 'Skillet', 'Measuring cups', 'Wooden spoon'];
      case 'recipe-3': // Avocado Toast
        return ['Toaster', 'Fork', 'Knife', 'Cutting board'];
      case 'recipe-4': // Stir Fry
        return ['Wok or large skillet', 'Cutting board', 'Knife', 'Wooden spoon'];
      case 'recipe-5': // Caesar Salad
        return ['Large bowl', 'Salad tongs', 'Cutting board', 'Knife'];
      default:
        return ['Basic kitchen tools'];
    }
  }

  RecipeScaling _getMockRecipeScaling(String recipeId, double scaleFactor) {
    final recipe = _getMockRecipes().firstWhere(
      (r) => r.id == recipeId,
      orElse: () => _getMockRecipes().first,
    );

    // Scale ingredients
    final scaledIngredients = recipe.ingredients.map((ingredient) {
      return IngredientWithSubstitutions(
        name: ingredient.name,
        quantity: _scaleQuantity(ingredient.quantity, scaleFactor),
        unit: ingredient.unit,
        substitutions: [], // Mock - no substitutions for now
      );
    }).toList();

    // Scale nutrition
    NutritionalInfo? scaledNutrition;
    if (recipe.nutritionalInfo != null) {
      final original = recipe.nutritionalInfo!;
      scaledNutrition = NutritionalInfo(
        calories: original.calories * scaleFactor,
        protein: original.protein != null ? original.protein! * scaleFactor : null,
        carbs: original.carbs != null ? original.carbs! * scaleFactor : null,
        fat: original.fat != null ? original.fat! * scaleFactor : null,
        fiber: original.fiber != null ? original.fiber! * scaleFactor : null,
        sugar: original.sugar != null ? original.sugar! * scaleFactor : null,
        sodium: original.sodium != null ? original.sodium! * scaleFactor : null,
      );
    }

    return RecipeScaling(
      scaleFactor: scaleFactor,
      originalServings: recipe.servings,
      scaledServings: (recipe.servings * scaleFactor).round(),
      scaledIngredients: scaledIngredients,
      scaledNutrition: scaledNutrition,
    );
  }

  String _scaleQuantity(String originalQuantity, double factor) {
    // Try to extract and scale numeric portions
    final RegExp numericRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = numericRegex.firstMatch(originalQuantity);
    
    if (match != null) {
      final originalNum = double.parse(match.group(1)!);
      final scaledNum = originalNum * factor;
      
      // Format nicely
      String scaledStr;
      if (scaledNum == scaledNum.toInt()) {
        scaledStr = scaledNum.toInt().toString();
      } else {
        scaledStr = scaledNum.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      }
      
      return originalQuantity.replaceFirst(match.group(1)!, scaledStr);
    }
    
    return originalQuantity; // Return original if no number found
  }

  /// Generate shareable text for recipe
  String buildShareText(RecipeDetail recipe) {
    final buffer = StringBuffer();
    
    // Recipe title and basic info
    buffer.writeln('🍽️ ${recipe.baseRecipe.name}');
    buffer.writeln();
    
    if (recipe.baseRecipe.description != null) {
      buffer.writeln(recipe.baseRecipe.description);
      buffer.writeln();
    }

    // Time and serving info
    final times = <String>[];
    if (recipe.baseRecipe.prepTimeMinutes != null) {
      times.add('Prep: ${recipe.baseRecipe.prepTimeMinutes}min');
    }
    if (recipe.baseRecipe.cookTimeMinutes != null) {
      times.add('Cook: ${recipe.baseRecipe.cookTimeMinutes}min');
    }
    if (times.isNotEmpty) {
      buffer.writeln('⏱️ ${times.join(' | ')}');
    }
    
    buffer.writeln('👥 Serves ${recipe.scaledServings}');
    
    if (recipe.baseRecipe.difficultyLevel != null) {
      buffer.writeln('📊 Difficulty: ${recipe.baseRecipe.difficultyLevel}');
    }
    buffer.writeln();

    // Ingredients
    buffer.writeln('📋 Ingredients:');
    for (final ingredient in recipe.getScaledIngredients()) {
      buffer.writeln('• ${ingredient.displayText}');
    }
    buffer.writeln();

    // Instructions
    buffer.writeln('👨‍🍳 Instructions:');
    for (final step in recipe.steps) {
      buffer.writeln('${step.stepNumber}. ${step.instruction}');
    }
    buffer.writeln();

    // Nutritional info (if available)
    final nutrition = recipe.getScaledNutrition();
    if (nutrition != null) {
      buffer.writeln('📊 Nutrition (per serving):');
      buffer.writeln('Calories: ${nutrition.calories.round()}');
      if (nutrition.protein != null) {
        buffer.writeln('Protein: ${nutrition.protein!.round()}g');
      }
      if (nutrition.carbs != null) {
        buffer.writeln('Carbs: ${nutrition.carbs!.round()}g');
      }
      if (nutrition.fat != null) {
        buffer.writeln('Fat: ${nutrition.fat!.round()}g');
      }
      buffer.writeln();
    }

    // App attribution
    buffer.writeln('📱 Made with Foodi App');

    return buffer.toString();
  }

  /// Get common recipe scaling factors
  List<double> getCommonScaleFactors() {
    return [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];
  }

  /// Get scale factor labels for UI
  Map<double, String> getScaleFactorLabels() {
    return {
      0.5: '½x (Half)',
      1.0: '1x (Original)',
      1.5: '1½x',
      2.0: '2x (Double)',
      3.0: '3x (Triple)',
      4.0: '4x',
    };
  }

  /// Get cooking tips by category
  Map<String, List<CookingTip>> getCookingTipsByCategory(List<CookingTip> tips) {
    final Map<String, List<CookingTip>> tipsByCategory = {};
    
    for (final tip in tips) {
      tipsByCategory.putIfAbsent(tip.category, () => []).add(tip);
    }
    
    return tipsByCategory;
  }

  /// Validate scale factor
  bool isValidScaleFactor(double scaleFactor) {
    return scaleFactor > 0 && scaleFactor <= 10.0; // Reasonable limits
  }

  /// Get equipment needed grouped by type
  Map<String, List<String>> getEquipmentByType(List<String> equipment) {
    final Map<String, List<String>> equipmentByType = {
      'Cookware': [],
      'Tools': [],
      'Other': [],
    };

    final cookwareKeywords = ['pot', 'pan', 'skillet', 'saucepan', 'baking', 'sheet', 'dish'];
    final toolKeywords = ['whisk', 'spatula', 'spoon', 'knife', 'cutting', 'measuring', 'mixer'];

    for (final item in equipment) {
      final itemLower = item.toLowerCase();
      
      if (cookwareKeywords.any((keyword) => itemLower.contains(keyword))) {
        equipmentByType['Cookware']!.add(item);
      } else if (toolKeywords.any((keyword) => itemLower.contains(keyword))) {
        equipmentByType['Tools']!.add(item);
      } else {
        equipmentByType['Other']!.add(item);
      }
    }

    // Remove empty categories
    equipmentByType.removeWhere((key, value) => value.isEmpty);
    
    return equipmentByType;
  }
} 