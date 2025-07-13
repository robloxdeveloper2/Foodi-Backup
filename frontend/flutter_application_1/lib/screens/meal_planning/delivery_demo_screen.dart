import 'package:flutter/material.dart';
import '../../models/grocery_delivery.dart';
import '../../models/grocery_list.dart';
import 'grocery_delivery_screen.dart';

class DeliveryDemoScreen extends StatelessWidget {
  const DeliveryDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Demo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grocery Delivery Integration',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is a mock integration with popular delivery services like DoorDash, Instacart, Uber Eats, and Shipt.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('• Multiple delivery service options'),
                    const Text('• Real-time pricing and delivery estimates'),
                    const Text('• Tip selection and special instructions'),
                    const Text('• Order tracking with status updates'),
                    const Text('• Mock payment integration'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeliveryDemo(context),
                icon: const Icon(Icons.local_shipping),
                label: const Text('Try Delivery Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Note: This is a demo with mock data. To use with real grocery lists, create a meal plan and generate a grocery list first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDemo(BuildContext context) {
    // Create mock grocery list data
    final mockGroceryList = GroceryList(
      id: 'demo_list_1',
      userId: 'demo_user',
      name: 'Demo Grocery List',
      totalCostUsd: 45.67,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final mockItems = [
      GroceryListItem(
        id: 'item_1',
        groceryListId: 'demo_list_1',
        ingredientName: 'Bananas',
        quantity: '2',
        unit: 'lbs',
        category: 'produce',
        costUsd: 3.50,
        isChecked: false,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      GroceryListItem(
        id: 'item_2',
        groceryListId: 'demo_list_1',
        ingredientName: 'Milk',
        quantity: '1',
        unit: 'gallon',
        category: 'dairy',
        costUsd: 4.99,
        isChecked: false,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      GroceryListItem(
        id: 'item_3',
        groceryListId: 'demo_list_1',
        ingredientName: 'Bread',
        quantity: '1',
        unit: 'loaf',
        category: 'bakery',
        costUsd: 2.49,
        isChecked: false,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      GroceryListItem(
        id: 'item_4',
        groceryListId: 'demo_list_1',
        ingredientName: 'Ground Turkey',
        quantity: '1',
        unit: 'lb',
        category: 'meat_seafood',
        costUsd: 6.99,
        isChecked: false,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
      GroceryListItem(
        id: 'item_5',
        groceryListId: 'demo_list_1',
        ingredientName: 'Rice',
        quantity: '2',
        unit: 'lbs',
        category: 'pantry',
        costUsd: 3.25,
        isChecked: false,
        isCustom: false,
        createdAt: DateTime.now(),
      ),
    ];

    final itemsByCategory = <String, List<GroceryListItem>>{};
    for (final item in mockItems) {
      final category = item.category ?? 'other';
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }

    final mockGroceryListWithItems = GroceryListWithItems(
      groceryList: mockGroceryList,
      itemsByCategory: itemsByCategory,
      totalItems: mockItems.length,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroceryDeliveryScreen(
          groceryList: mockGroceryListWithItems,
        ),
      ),
    );
  }
} 