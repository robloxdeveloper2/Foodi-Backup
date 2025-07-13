import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/grocery_list_provider.dart';
import '../../models/grocery_list.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_routes.dart';
import 'grocery_list_screen.dart';
import 'grocery_delivery_screen.dart';

class GroceryListsScreen extends StatefulWidget {
  const GroceryListsScreen({super.key});

  @override
  State<GroceryListsScreen> createState() => _GroceryListsScreenState();
}

class _GroceryListsScreenState extends State<GroceryListsScreen> {
  @override
  void initState() {
    super.initState();
    _initializeGroceryLists();
  }

  Future<void> _initializeGroceryLists() async {
    final authProvider = context.read<AuthProvider>();
    final groceryListProvider = context.read<GroceryListProvider>();

    if (authProvider.isAuthenticated && authProvider.token != null) {
      groceryListProvider.setAuthToken(authProvider.token!);
      await groceryListProvider.loadGroceryListHistory();
    }
  }

  Future<void> _refreshGroceryLists() async {
    final groceryListProvider = context.read<GroceryListProvider>();
    await groceryListProvider.loadGroceryListHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grocery Lists'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GroceryListProvider>(
        builder: (context, groceryListProvider, child) {
          if (groceryListProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (groceryListProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading grocery lists',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    groceryListProvider.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshGroceryLists,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groceryLists = groceryListProvider.groceryListHistory;

          if (groceryLists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No grocery lists yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a meal plan and generate your first grocery list!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.mealPlanning);
                    },
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Create Meal Plan'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Show demo delivery UI
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Create a grocery list first, then you\'ll see delivery options!'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Demo Delivery Feature'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshGroceryLists,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: groceryLists.length,
              itemBuilder: (context, index) {
                final groceryList = groceryLists[index];
                return _buildGroceryListCard(context, groceryList, theme);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroceryListCard(BuildContext context, GroceryList groceryList, ThemeData theme) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(groceryList.createdAt);

    final totalCost = groceryList.totalCostUsd ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openGroceryList(context, groceryList.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      groceryList.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${totalCost.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to view items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openGroceryList(context, groceryList.id),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openDeliveryForList(context, groceryList),
                      icon: const Icon(Icons.local_shipping, size: 16),
                      label: const Text('Order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGroceryList(BuildContext context, String groceryListId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroceryListScreen(
          groceryListId: groceryListId,
        ),
      ),
    );
  }

  void _openDeliveryForList(BuildContext context, GroceryList groceryList) async {
    // Load the full grocery list with items first
    final groceryListProvider = context.read<GroceryListProvider>();
    groceryListProvider.setAuthToken(context.read<AuthProvider>().token!);
    
    final success = await groceryListProvider.loadGroceryList(groceryList.id);
    
    if (success && groceryListProvider.currentGroceryList != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroceryDeliveryScreen(
              groceryList: groceryListProvider.currentGroceryList!,
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load grocery list for delivery'),
          ),
        );
      }
    }
  }
} 