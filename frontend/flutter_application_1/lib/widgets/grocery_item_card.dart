import 'package:flutter/material.dart';
import '../models/grocery_list.dart';

class GroceryItemCard extends StatelessWidget {
  final GroceryListItem item;
  final VoidCallback onToggled;
  final VoidCallback onDeleted;
  final Function(String, String?) onQuantityChanged;

  const GroceryItemCard({
    Key? key,
    required this.item,
    required this.onToggled,
    required this.onDeleted,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: item.isChecked ? Colors.grey[100] : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggled,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.isChecked ? Colors.green : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: item.isChecked ? Colors.green : Colors.transparent,
                  ),
                  child: item.isChecked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ingredientName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: item.isChecked ? Colors.grey[600] : Colors.black87,
                          decoration: item.isChecked 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                      if (item.displayQuantity.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.displayQuantity,
                          style: TextStyle(
                            fontSize: 14,
                            color: item.isChecked ? Colors.grey[500] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Cost (if available)
                if (item.formattedCost.isNotEmpty) ...[
                  Text(
                    item.formattedCost,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.isChecked ? Colors.grey[500] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Custom item indicator
                if (item.isCustom) ...[
                  Icon(
                    Icons.person_add,
                    size: 16,
                    color: Colors.blue[400],
                  ),
                  const SizedBox(width: 8),
                ],
                
                // More options button
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditQuantityDialog(context);
                        break;
                      case 'delete':
                        onDeleted();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit Quantity'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context) {
    final quantityController = TextEditingController(text: item.quantity);
    final unitController = TextEditingController(text: item.unit ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.ingredientName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., cups, lbs, oz',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = quantityController.text.trim();
              final unit = unitController.text.trim();
              
              if (quantity.isNotEmpty) {
                onQuantityChanged(quantity, unit.isEmpty ? null : unit);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 