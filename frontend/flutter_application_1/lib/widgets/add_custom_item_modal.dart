import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_list_provider.dart';

class AddCustomItemModal extends StatefulWidget {
  final String groceryListId;

  const AddCustomItemModal({
    Key? key,
    required this.groceryListId,
  }) : super(key: key);

  @override
  State<AddCustomItemModal> createState() => _AddCustomItemModalState();
}

class _AddCustomItemModalState extends State<AddCustomItemModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final groceryListProvider = Provider.of<GroceryListProvider>(context, listen: false);
    
    final success = await groceryListProvider.addCustomItem(
      widget.groceryListId,
      ingredientName: _nameController.text.trim(),
      quantity: _quantityController.text.trim(),
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(groceryListProvider.error ?? 'Failed to add item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add Custom Item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Item Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name *',
                    hintText: 'e.g., Bananas, Milk, Bread',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.shopping_basket),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Quantity and Unit Row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity *',
                          hintText: '1, 2, 1.5',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Enter quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Unit
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          hintText: 'cups, lbs, oz',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                            'Add Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Help Text
          Text(
            'Tip: You can always edit the quantity or delete items later by tapping the menu on each item.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 