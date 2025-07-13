import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_recipe_models.dart';
import '../../models/recipe_detail_models.dart';
import '../../models/recipe_models.dart';
import '../../providers/user_recipe_provider.dart';
import '../widgets/user_recipes/ingredient_input.dart';
import '../widgets/user_recipes/instruction_step_input.dart';
import '../widgets/user_recipes/category_selector.dart';

class CustomRecipeFormScreen extends StatefulWidget {
  final UserRecipe? existingRecipe;
  final bool isEditing;

  const CustomRecipeFormScreen({
    Key? key,
    this.existingRecipe,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<CustomRecipeFormScreen> createState() => _CustomRecipeFormScreenState();
}

class _CustomRecipeFormScreenState extends State<CustomRecipeFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  // Form state
  String _selectedCuisineType = '';
  String _selectedMealType = '';
  String _selectedDifficulty = 'Easy';
  List<IngredientWithSubstitutions> _ingredients = [];
  List<String> _instructions = [];
  List<String> _selectedCategoryIds = [];
  String? _imageUrl;
  
  bool _isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Lists for dropdowns
  final List<String> _cuisineTypes = [
    'Italian', 'Chinese', 'Mexican', 'Indian', 'Thai', 'French', 'Greek',
    'Japanese', 'American', 'Mediterranean', 'Korean', 'Spanish', 'Other'
  ];
  
  final List<String> _mealTypes = [
    'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert', 'Appetizer', 'Beverage'
  ];
  
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _totalSteps, vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingRecipe != null && widget.isEditing) {
      final recipe = widget.existingRecipe!;
      _nameController.text = recipe.name;
      _descriptionController.text = recipe.description ?? '';
      _selectedCuisineType = recipe.cuisineType ?? '';
      _selectedMealType = recipe.mealType ?? '';
      _selectedDifficulty = recipe.difficultyLevel ?? 'Easy';
      _prepTimeController.text = recipe.prepTimeMinutes?.toString() ?? '';
      _cookTimeController.text = recipe.cookTimeMinutes?.toString() ?? '';
      _servingsController.text = recipe.servings.toString();
      
      // Convert ingredients to IngredientWithSubstitutions
      _ingredients = recipe.ingredients.map((ingredient) {
        return IngredientWithSubstitutions(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          substitutions: [], // UserRecipe ingredients don't have substitutions
        );
      }).toList();
      
      // Split instructions string into list
      _instructions = recipe.instructions.split('\n')
          .where((step) => step.trim().isNotEmpty)
          .toList();
      
      _selectedCategoryIds = recipe.categories.map((cat) => cat.id).toList();
      _imageUrl = recipe.imageUrl;
    } else {
      _servingsController.text = '4';
      _ingredients = [IngredientWithSubstitutions(name: '', quantity: '', unit: '', substitutions: [])];
      _instructions = [''];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Recipe' : 'Create Recipe'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Basic Info'),
            Tab(text: 'Ingredients'),
            Tab(text: 'Instructions'),
            Tab(text: 'Categories'),
          ],
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text('Back'),
            ),
          if (_currentStep < _totalSteps - 1)
            TextButton(
              onPressed: _nextStep,
              child: Text('Next'),
            ),
          if (_currentStep == _totalSteps - 1)
            TextButton(
              onPressed: _isLoading ? null : _saveRecipe,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoStep(),
            _buildIngredientsStep(),
            _buildInstructionsStep(),
            _buildCategoriesStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Recipe Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Recipe name is required';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCuisineType.isEmpty ? null : _selectedCuisineType,
                  decoration: InputDecoration(
                    labelText: 'Cuisine Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _cuisineTypes.map((cuisine) {
                    return DropdownMenuItem(
                      value: cuisine,
                      child: Text(cuisine),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCuisineType = value ?? '';
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMealType.isEmpty ? null : _selectedMealType,
                  decoration: InputDecoration(
                    labelText: 'Meal Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _mealTypes.map((meal) {
                    return DropdownMenuItem(
                      value: meal,
                      child: Text(meal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMealType = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _prepTimeController,
                  decoration: InputDecoration(
                    labelText: 'Prep Time (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final time = int.tryParse(value);
                      if (time == null || time < 0) {
                        return 'Enter valid minutes';
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cookTimeController,
                  decoration: InputDecoration(
                    labelText: 'Cook Time (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final time = int.tryParse(value);
                      if (time == null || time < 0) {
                        return 'Enter valid minutes';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _servingsController,
                  decoration: InputDecoration(
                    labelText: 'Servings *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Servings is required';
                    }
                    final servings = int.tryParse(value);
                    if (servings == null || servings <= 0) {
                      return 'Enter valid servings';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(),
                  ),
                  items: _difficultyLevels.map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value ?? 'Easy';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          
          ..._ingredients.asMap().entries.map((entry) {
            int index = entry.key;
            IngredientWithSubstitutions ingredient = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: IngredientInput(
                ingredient: ingredient,
                onChanged: (updatedIngredient) {
                  setState(() {
                    _ingredients[index] = updatedIngredient;
                  });
                },
                onRemove: _ingredients.length > 1 ? () {
                  setState(() {
                    _ingredients.removeAt(index);
                  });
                } : null,
              ),
            );
          }).toList(),
          
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _ingredients.add(IngredientWithSubstitutions(
                  name: '',
                  quantity: '',
                  unit: '',
                  substitutions: [],
                ));
              });
            },
            icon: Icon(Icons.add),
            label: Text('Add Ingredient'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          
          ..._instructions.asMap().entries.map((entry) {
            int index = entry.key;
            String instruction = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: InstructionStepInput(
                stepNumber: index + 1,
                instruction: instruction,
                onChanged: (updatedInstruction) {
                  setState(() {
                    _instructions[index] = updatedInstruction;
                  });
                },
                onRemove: _instructions.length > 1 ? () {
                  setState(() {
                    _instructions.removeAt(index);
                  });
                } : null,
              ),
            );
          }).toList(),
          
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _instructions.add('');
              });
            },
            icon: Icon(Icons.add),
            label: Text('Add Step'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          
          CategorySelector(
            selectedCategoryIds: _selectedCategoryIds,
            onSelectionChanged: (categoryIds) {
              setState(() {
                _selectedCategoryIds = categoryIds;
              });
            },
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _tabController.animateTo(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _tabController.animateTo(_currentStep);
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Validate ingredients
    if (_ingredients.isEmpty || _ingredients.every((ing) => ing.name.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    // Validate instructions
    if (_instructions.isEmpty || _instructions.every((inst) => inst.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one instruction step')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<UserRecipeProvider>(context, listen: false);
      
      // Convert IngredientWithSubstitutions to Ingredient for UserRecipe
      final ingredients = _ingredients
          .where((ing) => ing.name.trim().isNotEmpty)
          .map((ing) => Ingredient(
                name: ing.name,
                quantity: ing.quantity,
                unit: ing.unit,
              ))
          .toList();
      
      final instructionsText = _instructions
          .where((inst) => inst.trim().isNotEmpty)
          .join('\n');
      
      if (widget.isEditing && widget.existingRecipe != null) {
        // Update existing recipe
        final updateRequest = UpdateRecipeRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null : _descriptionController.text.trim(),
          ingredients: ingredients,
          instructions: instructionsText,
          cuisineType: _selectedCuisineType.isEmpty ? null : _selectedCuisineType,
          mealType: _selectedMealType.isEmpty ? null : _selectedMealType,
          prepTimeMinutes: _prepTimeController.text.isEmpty 
              ? null : int.tryParse(_prepTimeController.text),
          cookTimeMinutes: _cookTimeController.text.isEmpty 
              ? null : int.tryParse(_cookTimeController.text),
          difficultyLevel: _selectedDifficulty,
          servings: int.parse(_servingsController.text),
          categoryIds: _selectedCategoryIds,
        );
        
        await provider.updateCustomRecipe(widget.existingRecipe!.id, updateRequest);
      } else {
        // Create new recipe
        final createRequest = CreateRecipeRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null : _descriptionController.text.trim(),
          ingredients: ingredients,
          instructions: instructionsText,
          cuisineType: _selectedCuisineType.isEmpty ? null : _selectedCuisineType,
          mealType: _selectedMealType.isEmpty ? null : _selectedMealType,
          prepTimeMinutes: _prepTimeController.text.isEmpty 
              ? null : int.tryParse(_prepTimeController.text),
          cookTimeMinutes: _cookTimeController.text.isEmpty 
              ? null : int.tryParse(_cookTimeController.text),
          difficultyLevel: _selectedDifficulty,
          servings: int.parse(_servingsController.text),
          categoryIds: _selectedCategoryIds,
        );
        
        await provider.createCustomRecipe(createRequest);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing 
                ? 'Recipe updated successfully!' 
                : 'Recipe created successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 