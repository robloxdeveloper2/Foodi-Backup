import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_recipe_models.dart';
import '../../../providers/user_recipe_provider.dart';

class CategorySelector extends StatefulWidget {
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;

  const CategorySelector({
    Key? key,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _newCategoryController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isCreatingCategory = false;

  // Predefined colors for categories
  final List<Color> _predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    // Load categories when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserRecipeProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRecipeProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected categories section
            if (widget.selectedCategoryIds.isNotEmpty) ...[
              Text(
                'Selected Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedCategoryIds.map((categoryId) {
                                     final category = categories.firstWhere(
                     (cat) => cat.id == categoryId,
                     orElse: () => UserRecipeCategory(
                       id: categoryId,
                       name: 'Unknown',
                       userId: '',
                       createdAt: DateTime.now(),
                     ),
                   );
                  
                  return Chip(
                    label: Text(category.name),
                    backgroundColor: category.color?.withOpacity(0.2),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () {
                      final updatedSelection = List<String>.from(widget.selectedCategoryIds)
                        ..remove(categoryId);
                      widget.onSelectionChanged(updatedSelection);
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],
            
            // Available categories section
            Text(
              'Available Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            
            if (categories.isEmpty && !provider.isLoading)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No categories yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first category to organize your recipes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              // Category grid
              Container(
                constraints: BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = widget.selectedCategoryIds.contains(category.id);
                      
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          List<String> updatedSelection = List.from(widget.selectedCategoryIds);
                          
                          if (selected) {
                            updatedSelection.add(category.id);
                          } else {
                            updatedSelection.remove(category.id);
                          }
                          
                          widget.onSelectionChanged(updatedSelection);
                        },
                        backgroundColor: category.color?.withOpacity(0.1),
                        selectedColor: category.color?.withOpacity(0.3),
                        checkmarkColor: category.color,
                        side: category.color != null
                            ? BorderSide(color: category.color!)
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 16),
            
            // Create new category section
            if (_isCreatingCategory) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Category name input
                      TextField(
                        controller: _newCategoryController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _createCategory(provider),
                      ),
                      SizedBox(height: 12),
                      
                      // Color selection
                      Text(
                        'Choose Color',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _predefinedColors.map((color) {
                          final isSelected = _selectedColor == color;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context).colorScheme.primary,
                                        width: 3,
                                      )
                                    : Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isCreatingCategory = false;
                                _newCategoryController.clear();
                                _selectedColor = Colors.blue;
                              });
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: provider.isLoading ? null : () => _createCategory(provider),
                            child: provider.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text('Create'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Add category button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isCreatingCategory = true;
                  });
                },
                icon: Icon(Icons.add),
                label: Text('Create New Category'),
              ),
            ],
            
            // Loading indicator
            if (provider.isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(UserRecipeProvider provider) async {
    final name = _newCategoryController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }
    
    try {
      await provider.createCategory(
        name,
        color: _selectedColor,
      );
      
      // Reset form
      setState(() {
        _isCreatingCategory = false;
        _newCategoryController.clear();
        _selectedColor = Colors.blue;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category "$name" created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }
} 