class DemoMode {
  static const bool isDemoMode = true;
  
  // Mock data for investor demo
  static const Map<String, dynamic> mockUserProfile = {
    'name': 'Demo User',
    'email': 'demo@foodi.com',
    'dietaryRestrictions': ['vegetarian'],
    'cookingExperience': 'intermediate',
    'budget': 'medium',
    'nutritionalGoals': ['weight_loss']
  };
  
  static const List<Map<String, dynamic>> mockMealPlans = [
    {
      'id': '1',
      'name': 'Healthy Vegetarian Week',
      'totalCost': 85.50,
      'calories': 1800,
      'meals': [
        {'type': 'breakfast', 'name': 'Avocado Toast', 'cost': 3.50},
        {'type': 'lunch', 'name': 'Quinoa Bowl', 'cost': 8.25},
        {'type': 'dinner', 'name': 'Lentil Curry', 'cost': 6.75},
      ]
    }
  ];
  
  static const List<Map<String, dynamic>> mockRecipes = [
    {
      'id': '1',
      'name': 'Avocado Toast',
      'prepTime': 5,
      'cookTime': 0,
      'difficulty': 'easy',
      'cost': 3.50,
      'calories': 320,
      'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400'
    },
    {
      'id': '2', 
      'name': 'Quinoa Buddha Bowl',
      'prepTime': 15,
      'cookTime': 20,
      'difficulty': 'medium',
      'cost': 8.25,
      'calories': 450,
      'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400'
    }
  ];
} 