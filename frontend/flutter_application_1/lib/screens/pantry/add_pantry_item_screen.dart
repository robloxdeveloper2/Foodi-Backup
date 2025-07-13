import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/pantry_item.dart';
import '../../providers/pantry_provider.dart';
import '../../utils/app_theme.dart';

class AddPantryItemScreen extends StatefulWidget {
  const AddPantryItemScreen({super.key});

  @override
  State<AddPantryItemScreen> createState() => _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends State<AddPantryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedUnit = 'units';
  String? _selectedCategory;
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pantry Item'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                                     color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                                         Icon(
                       Icons.add_shopping_cart,
                       color: AppTheme.primaryGreen,
                       size: 32,
                     ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Item',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Track your grocery inventory',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Item Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g., Milk, Bread, Apples',
                  prefixIcon: const Icon(Icons.local_grocery_store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  if (value.trim().length < 2) {
                    return 'Item name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Quantity and Unit Row
              Row(
                children: [
                  // Quantity Field
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        hintText: '1',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        final quantity = double.tryParse(value.trim());
                        if (quantity == null || quantity <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Unit Dropdown
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.black87,
                      menuMaxHeight: 200,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: const Icon(Icons.straighten),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                      items: PantryConstants.validUnits.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              PantryConstants.unitDisplayNames[unit] ?? unit,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black87,
                menuMaxHeight: 200,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select category (optional)',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: const Text(
                        'No category',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  ...PantryConstants.validCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          PantryConstants.categoryDisplayNames[category] ?? category,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Expiry Date Field
              InkWell(
                onTap: () => _selectExpiryDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'Select expiry date (optional)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: _selectedExpiryDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedExpiryDate = null;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  child: Text(
                    _selectedExpiryDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedExpiryDate!)
                        : 'No expiry date',
                    style: TextStyle(
                      color: _selectedExpiryDate != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Additional notes (optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null && value.length > 1000) {
                    return 'Notes must be less than 1000 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Add Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addPantryItem,
                                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primaryGreen,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                 ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Add to Pantry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedExpiryDate ?? now.add(const Duration(days: 7));
    
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)), // 2 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedExpiryDate = selectedDate;
      });
    }
  }

  Future<void> _addPantryItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text.trim());
      
      final request = PantryItemCreateRequest(
        name: _nameController.text.trim(),
        quantity: quantity,
        unit: _selectedUnit,
        expiryDate: _selectedExpiryDate?.toIso8601String().split('T')[0], // YYYY-MM-DD format
        category: _selectedCategory,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
      final success = await pantryProvider.addPantryItem(request);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Item added to pantry successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          final error = pantryProvider.error ?? 'Failed to add item';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 