import 'recipe_models.dart';
import 'dart:convert';

/// Enhanced recipe model specifically for the detail view
class RecipeDetail {
  final Recipe baseRecipe;
  final List<RecipeStep> steps;
  final List<CookingTip> cookingTips;
  final List<String> equipmentNeeded;
  final double currentScaleFactor;
  
  RecipeDetail({
    required this.baseRecipe,
    required this.steps,
    required this.cookingTips,
    required this.equipmentNeeded,
    this.currentScaleFactor = 1.0,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      baseRecipe: Recipe.fromJson(json),
      steps: _parseSteps(json['detailed_instructions']),
      cookingTips: _parseCookingTips(json['cooking_tips']),
      equipmentNeeded: _parseEquipment(json['equipment_needed']),
      currentScaleFactor: 1.0,
    );
  }

  static List<RecipeStep> _parseSteps(dynamic instructionsData) {
    if (instructionsData == null) return [];
    
    List<dynamic> instructionsList;
    
    // Handle both string (JSON) and already parsed list
    if (instructionsData is String) {
      try {
        instructionsList = json.decode(instructionsData) as List<dynamic>;
      } catch (e) {
        // If it's not valid JSON, treat as plain text and split into steps by sentences
        return _splitTextIntoSteps(instructionsData);
      }
    } else if (instructionsData is List) {
      instructionsList = instructionsData;
    } else {
      return [];
    }
    
    return instructionsList
        .map((step) => RecipeStep.fromJson(step as Map<String, dynamic>))
        .toList();
  }

  static List<RecipeStep> _splitTextIntoSteps(String text) {
    // Clean up the text and split by sentences
    final cleanText = text.trim();
    if (cleanText.isEmpty) return [];
    
    // Split by periods, exclamation marks, or numbered steps
    List<String> sentences = [];
    
    // First try to split by numbered patterns like "1.", "2.", etc.
    final numberedStepRegex = RegExp(r'(\d+\.\s*)');
    if (numberedStepRegex.hasMatch(cleanText)) {
      sentences = cleanText
          .split(numberedStepRegex)
          .where((s) => s.trim().isNotEmpty && !RegExp(r'^\d+\.\s*$').hasMatch(s))
          .map((s) => s.trim())
          .toList();
    } else {
      // Split by sentences (periods, exclamation marks)
      sentences = cleanText
          .split(RegExp(r'[.!]\s+'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
    }
    
    // Create RecipeStep objects
    List<RecipeStep> steps = [];
    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i];
      
      // Clean up the sentence
      if (!sentence.endsWith('.') && !sentence.endsWith('!') && !sentence.endsWith('?')) {
        sentence += '.';
      }
      
      // Skip very short sentences (likely fragments)
      if (sentence.length < 10) continue;
      
      steps.add(RecipeStep(
        stepNumber: i + 1,
        instruction: sentence,
        durationMinutes: _estimateDuration(sentence),
      ));
    }
    
    // If no valid steps were created, return the original text as one step
    if (steps.isEmpty) {
      return [
        RecipeStep(
          stepNumber: 1,
          instruction: cleanText,
        )
      ];
    }
    
    return steps;
  }

  static int? _estimateDuration(String instruction) {
    // Simple duration estimation based on keywords
    final lowerInstruction = instruction.toLowerCase();
    
    if (lowerInstruction.contains('boil') || lowerInstruction.contains('simmer')) {
      return 10;
    } else if (lowerInstruction.contains('cook') || lowerInstruction.contains('bake')) {
      return 15;
    } else if (lowerInstruction.contains('mix') || lowerInstruction.contains('combine') || lowerInstruction.contains('stir')) {
      return 2;
    } else if (lowerInstruction.contains('chop') || lowerInstruction.contains('dice') || lowerInstruction.contains('slice')) {
      return 5;
    } else if (lowerInstruction.contains('heat') || lowerInstruction.contains('preheat')) {
      return 5;
    } else if (lowerInstruction.contains('rest') || lowerInstruction.contains('chill') || lowerInstruction.contains('cool')) {
      return null; // Variable time
    }
    
    return null; // No estimate
  }

  static List<CookingTip> _parseCookingTips(dynamic tipsData) {
    if (tipsData == null) return [];
    
    List<dynamic> tipsList;
    
    // Handle both string (JSON) and already parsed list
    if (tipsData is String) {
      try {
        tipsList = json.decode(tipsData) as List<dynamic>;
      } catch (e) {
        // If it's not valid JSON, treat as plain text and create a single tip
        return [
          CookingTip(
            tip: tipsData,
            category: 'general',
          )
        ];
      }
    } else if (tipsData is List) {
      tipsList = tipsData;
    } else {
      return [];
    }
    
    return tipsList
        .map((tip) => CookingTip.fromJson(tip as Map<String, dynamic>))
        .toList();
  }

  static List<String> _parseEquipment(dynamic equipmentData) {
    if (equipmentData == null) return [];
    
    if (equipmentData is String) {
      try {
        final parsed = json.decode(equipmentData);
        if (parsed is List) {
          return List<String>.from(parsed);
        }
      } catch (e) {
        // If it's not valid JSON, return as single item
        return [equipmentData];
      }
    } else if (equipmentData is List) {
      return List<String>.from(equipmentData);
    }
    
    return [];
  }

  /// Create a scaled version of this recipe
  RecipeDetail copyWithScale(double scaleFactor) {
    return RecipeDetail(
      baseRecipe: baseRecipe,
      steps: steps,
      cookingTips: cookingTips,
      equipmentNeeded: equipmentNeeded,
      currentScaleFactor: scaleFactor,
    );
  }

  /// Get scaled ingredients list
  List<IngredientWithSubstitutions> getScaledIngredients() {
    return baseRecipe.ingredients.map((ingredient) {
      return IngredientWithSubstitutions(
        name: ingredient.name,
        quantity: _scaleQuantity(ingredient.quantity, currentScaleFactor),
        unit: ingredient.unit,
        substitutions: _parseSubstitutions(ingredient),
      );
    }).toList();
  }

  /// Get scaled nutritional information
  NutritionalInfo? getScaledNutrition() {
    if (baseRecipe.nutritionalInfo == null) return null;
    
    return NutritionalInfo(
      calories: baseRecipe.nutritionalInfo!.calories * currentScaleFactor,
      protein: baseRecipe.nutritionalInfo!.protein != null 
          ? baseRecipe.nutritionalInfo!.protein! * currentScaleFactor 
          : null,
      carbs: baseRecipe.nutritionalInfo!.carbs != null 
          ? baseRecipe.nutritionalInfo!.carbs! * currentScaleFactor 
          : null,
      fat: baseRecipe.nutritionalInfo!.fat != null 
          ? baseRecipe.nutritionalInfo!.fat! * currentScaleFactor 
          : null,
      fiber: baseRecipe.nutritionalInfo!.fiber != null 
          ? baseRecipe.nutritionalInfo!.fiber! * currentScaleFactor 
          : null,
      sugar: baseRecipe.nutritionalInfo!.sugar != null 
          ? baseRecipe.nutritionalInfo!.sugar! * currentScaleFactor 
          : null,
      sodium: baseRecipe.nutritionalInfo!.sodium != null 
          ? baseRecipe.nutritionalInfo!.sodium! * currentScaleFactor 
          : null,
    );
  }

  int get scaledServings => (baseRecipe.servings * currentScaleFactor).round();

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

  List<String> _parseSubstitutions(Ingredient ingredient) {
    // For now, return empty list. In a real implementation, this would come from the API
    // or be inferred based on ingredient type
    return [];
  }
}

/// Individual cooking step with completion tracking
class RecipeStep {
  final int stepNumber;
  final String instruction;
  final int? durationMinutes;
  final String? tips;
  final bool isCompleted;

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
    this.tips,
    this.isCompleted = false,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['step'] as int,
      instruction: json['instruction'] as String,
      durationMinutes: json['duration_minutes'] as int?,
      tips: json['tips'] as String?,
    );
  }

  RecipeStep copyWith({bool? isCompleted}) {
    return RecipeStep(
      stepNumber: stepNumber,
      instruction: instruction,
      durationMinutes: durationMinutes,
      tips: tips,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String get durationDisplay {
    if (durationMinutes == null) return '';
    return '${durationMinutes}min';
  }
}

/// Ingredient with substitution options
class IngredientWithSubstitutions {
  final String name;
  final String quantity;
  final String? unit;
  final List<String> substitutions;

  IngredientWithSubstitutions({
    required this.name,
    required this.quantity,
    this.unit,
    required this.substitutions,
  });

  String get displayText {
    if (unit != null && unit!.isNotEmpty) {
      return '$quantity $unit $name';
    }
    return '$quantity $name';
  }

  bool get hasSubstitutions => substitutions.isNotEmpty;
}

/// Cooking tip with category
class CookingTip {
  final String tip;
  final String category;

  CookingTip({
    required this.tip,
    required this.category,
  });

  factory CookingTip.fromJson(Map<String, dynamic> json) {
    return CookingTip(
      tip: json['tip'] as String,
      category: json['category'] as String? ?? 'general',
    );
  }
}

/// Tracks user's cooking session progress
class CookingSession {
  final String recipeId;
  final List<bool> stepCompletions;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isPaused;

  CookingSession({
    required this.recipeId,
    required this.stepCompletions,
    required this.startTime,
    this.endTime,
    this.isPaused = false,
  });

  CookingSession copyWith({
    List<bool>? stepCompletions,
    DateTime? endTime,
    bool? isPaused,
  }) {
    return CookingSession(
      recipeId: recipeId,
      stepCompletions: stepCompletions ?? this.stepCompletions,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  double get progressPercentage {
    if (stepCompletions.isEmpty) return 0.0;
    final completedSteps = stepCompletions.where((completed) => completed).length;
    return completedSteps / stepCompletions.length;
  }

  bool get isCompleted => stepCompletions.every((completed) => completed);

  Duration get elapsedTime {
    final endTimeForCalculation = endTime ?? DateTime.now();
    return endTimeForCalculation.difference(startTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'step_completions': stepCompletions,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_paused': isPaused,
    };
  }

  factory CookingSession.fromJson(Map<String, dynamic> json) {
    return CookingSession(
      recipeId: json['recipe_id'] as String,
      stepCompletions: List<bool>.from(json['step_completions'] ?? []),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String) 
          : null,
      isPaused: json['is_paused'] as bool? ?? false,
    );
  }
}

/// Data for recipe scaling calculations
class RecipeScaling {
  final double scaleFactor;
  final int originalServings;
  final int scaledServings;
  final List<IngredientWithSubstitutions> scaledIngredients;
  final NutritionalInfo? scaledNutrition;

  RecipeScaling({
    required this.scaleFactor,
    required this.originalServings,
    required this.scaledServings,
    required this.scaledIngredients,
    this.scaledNutrition,
  });

  factory RecipeScaling.fromApiResponse(Map<String, dynamic> json) {
    final scaledData = json['scaled_data'] as Map<String, dynamic>;
    
    return RecipeScaling(
      scaleFactor: (json['scale_factor'] as num).toDouble(),
      originalServings: json['original_servings'] as int,
      scaledServings: scaledData['servings'] as int,
      scaledIngredients: (scaledData['ingredients'] as List<dynamic>)
          .map((ingredient) => IngredientWithSubstitutions(
                name: ingredient['name'] as String,
                quantity: ingredient['quantity'] as String,
                unit: ingredient['unit'] as String?,
                substitutions: [], // Would come from API in full implementation
              ))
          .toList(),
      scaledNutrition: scaledData['nutritional_info'] != null 
          ? NutritionalInfo.fromJson(scaledData['nutritional_info'] as Map<String, dynamic>)
          : null,
    );
  }
} 