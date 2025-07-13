import 'package:flutter/material.dart';
import '../models/grocery_list.dart';
import 'grocery_item_card.dart';

class GroceryCategorySection extends StatelessWidget {
  final String category;
  final List<GroceryListItem> items;
  final Function(String) onItemToggled;
  final Function(String) onItemDeleted;
  final Function(String, String, String?) onItemQuantityChanged;

  const GroceryCategorySection({
    Key? key,
    required this.category,
    required this.items,
    required this.onItemToggled,
    required this.onItemDeleted,
    required this.onItemQuantityChanged,
  }) : super(key: key);

  String get _categoryDisplayName {
    switch (category) {
      case 'produce':
        return 'Produce';
      case 'meat_seafood':
        return 'Meat & Seafood';
      case 'dairy':
        return 'Dairy';
      case 'pantry':
        return 'Pantry';
      case 'frozen':
        return 'Frozen';
      case 'bakery':
        return 'Bakery';
      case 'beverages':
        return 'Beverages';
      case 'canned_goods':
        return 'Canned Goods';
      case 'condiments':
        return 'Condiments';
      case 'snacks':
        return 'Snacks';
      default:
        return 'Other';
    }
  }

  IconData get _categoryIcon {
    switch (category) {
      case 'produce':
        return Icons.eco;
      case 'meat_seafood':
        return Icons.set_meal;
      case 'dairy':
        return Icons.local_drink;
      case 'pantry':
        return Icons.kitchen;
      case 'frozen':
        return Icons.ac_unit;
      case 'bakery':
        return Icons.bakery_dining;
      case 'beverages':
        return Icons.local_cafe;
      case 'canned_goods':
        return Icons.food_bank;
      case 'condiments':
        return Icons.emoji_food_beverage;
      case 'snacks':
        return Icons.cookie;
      default:
        return Icons.shopping_basket;
    }
  }

  Color get _categoryColor {
    switch (category) {
      case 'produce':
        return Colors.green;
      case 'meat_seafood':
        return Colors.red;
      case 'dairy':
        return Colors.blue;
      case 'pantry':
        return Colors.orange;
      case 'frozen':
        return Colors.lightBlue;
      case 'bakery':
        return Colors.brown;
      case 'beverages':
        return Colors.purple;
      case 'canned_goods':
        return Colors.grey;
      case 'condiments':
        return Colors.deepOrange;
      case 'snacks':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Sort items: unchecked first, then checked
    final sortedItems = [...items];
    sortedItems.sort((a, b) {
      if (a.isChecked == b.isChecked) {
        return a.ingredientName.compareTo(b.ingredientName);
      }
      return a.isChecked ? 1 : -1;
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _categoryIcon,
                  color: _categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _categoryDisplayName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _categoryColor.withOpacity(0.9),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _categoryColor.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Items List
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: sortedItems.map((item) {
                return GroceryItemCard(
                  item: item,
                  onToggled: () => onItemToggled(item.id),
                  onDeleted: () => onItemDeleted(item.id),
                  onQuantityChanged: (quantity, unit) => 
                      onItemQuantityChanged(item.id, quantity, unit),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 