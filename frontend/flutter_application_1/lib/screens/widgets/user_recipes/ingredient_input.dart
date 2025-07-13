import 'package:flutter/material.dart';
import '../../../models/recipe_detail_models.dart';

class IngredientInput extends StatefulWidget {
  final IngredientWithSubstitutions ingredient;
  final ValueChanged<IngredientWithSubstitutions> onChanged;
  final VoidCallback? onRemove;

  const IngredientInput({
    Key? key,
    required this.ingredient,
    required this.onChanged,
    this.onRemove,
  }) : super(key: key);

  @override
  State<IngredientInput> createState() => _IngredientInputState();
}

class _IngredientInputState extends State<IngredientInput> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _substitutionsController;

  // Common ingredient suggestions
  final List<String> _commonIngredients = [
    'Salt', 'Black pepper', 'Olive oil', 'Garlic', 'Onion', 'Tomato',
    'Chicken breast', 'Ground beef', 'Eggs', 'Milk', 'Butter', 'Flour',
    'Sugar', 'Vanilla extract', 'Baking powder', 'Baking soda',
    'Rice', 'Pasta', 'Cheese', 'Lemon', 'Herbs', 'Spices'
  ];

  // Common units
  final List<String> _commonUnits = [
    'cup', 'cups', 'tablespoon', 'tablespoons', 'teaspoon', 'teaspoons',
    'pound', 'pounds', 'ounce', 'ounces', 'gram', 'grams', 'kilogram',
    'liter', 'milliliter', 'piece', 'pieces', 'clove', 'cloves',
    'pinch', 'dash', 'slice', 'slices', 'whole', 'to taste'
  ];

  bool _showSubstitutions = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _quantityController = TextEditingController(text: widget.ingredient.quantity);
    _unitController = TextEditingController(text: widget.ingredient.unit);
    _substitutionsController = TextEditingController(
      text: widget.ingredient.substitutions?.join(', ') ?? '',
    );

    // Set up listeners
    _nameController.addListener(_onNameChanged);
    _quantityController.addListener(_onQuantityChanged);
    _unitController.addListener(_onUnitChanged);
    _substitutionsController.addListener(_onSubstitutionsChanged);

    // Show substitutions if they exist
    _showSubstitutions = widget.ingredient.substitutions?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _substitutionsController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    _updateIngredient();
  }

  void _onQuantityChanged() {
    _updateIngredient();
  }

  void _onUnitChanged() {
    _updateIngredient();
  }

  void _onSubstitutionsChanged() {
    _updateIngredient();
  }

  void _updateIngredient() {
    final substitutions = _substitutionsController.text.trim().isEmpty
        ? null
        : _substitutionsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final updatedIngredient = IngredientWithSubstitutions(
      name: _nameController.text,
      quantity: _quantityController.text,
      unit: _unitController.text,
      substitutions: substitutions ?? [],
    );

    widget.onChanged(updatedIngredient);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main ingredient input row
            Row(
              children: [
                // Quantity
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(width: 8),
                
                // Unit
                Expanded(
                  flex: 1,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _commonUnits.where((unit) {
                        return unit.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      _unitController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      // Sync with our controller
                      if (controller.text != _unitController.text) {
                        controller.text = _unitController.text;
                      }
                      
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        onChanged: (value) {
                          _unitController.text = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.next,
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                
                // Ingredient name
                Expanded(
                  flex: 3,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _commonIngredients.where((ingredient) {
                        return ingredient.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      _nameController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      // Sync with our controller
                      if (controller.text != _nameController.text) {
                        controller.text = _nameController.text;
                      }
                      
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        onChanged: (value) {
                          _nameController.text = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Ingredient *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      );
                    },
                  ),
                ),
                
                // Remove button
                if (widget.onRemove != null) ...[
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: Icon(Icons.remove_circle_outline),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Remove ingredient',
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 8),
            
            // Substitutions toggle and input
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showSubstitutions = !_showSubstitutions;
                      if (!_showSubstitutions) {
                        _substitutionsController.clear();
                      }
                    });
                  },
                  icon: Icon(_showSubstitutions 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down),
                  label: Text('Substitutions'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                ),
                if (widget.ingredient.substitutions?.isNotEmpty ?? false)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.ingredient.substitutions!.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (_showSubstitutions) ...[
              SizedBox(height: 8),
              TextFormField(
                controller: _substitutionsController,
                decoration: InputDecoration(
                  labelText: 'Substitutions (comma-separated)',
                  hintText: 'e.g., butter, margarine, coconut oil',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 