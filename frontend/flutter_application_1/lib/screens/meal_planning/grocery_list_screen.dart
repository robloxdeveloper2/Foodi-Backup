import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grocery_list_provider.dart';
import '../../models/grocery_list.dart';
import '../../widgets/grocery_category_section.dart';
import '../../widgets/add_custom_item_modal.dart';
import '../../widgets/grocery_list_summary_widget.dart';
import 'grocery_delivery_screen.dart';

class GroceryListScreen extends StatefulWidget {
  final String groceryListId;

  const GroceryListScreen({
    Key? key,
    required this.groceryListId,
  }) : super(key: key);

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // Check if the grocery list is already loaded
    final groceryListProvider = Provider.of<GroceryListProvider>(context, listen: false);
    final currentList = groceryListProvider.currentGroceryList;
    
    if (currentList?.groceryList.id == widget.groceryListId) {
      // List is already loaded, just update local state
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } else {
      // Need to load the list
      _loadGroceryList();
    }
  }

  Future<void> _loadGroceryList() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final groceryListProvider = Provider.of<GroceryListProvider>(context, listen: false);
    final success = await groceryListProvider.loadGroceryList(widget.groceryListId);

    if (!success && mounted) {
      setState(() {
        _error = groceryListProvider.error ?? 'Failed to load grocery list';
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddItemModal() async {
    final groceryListProvider = Provider.of<GroceryListProvider>(context, listen: false);
    
    if (groceryListProvider.currentGroceryList == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCustomItemModal(
        groceryListId: groceryListProvider.currentGroceryList!.groceryList.id,
      ),
    );
  }

  Future<void> _showEditListNameDialog() async {
    final groceryListProvider = Provider.of<GroceryListProvider>(context, listen: false);
    final currentList = groceryListProvider.currentGroceryList;
    
    if (currentList == null) return;

    final controller = TextEditingController(text: currentList.groceryList.name);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'List Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentList.groceryList.name) {
      await groceryListProvider.updateGroceryListName(currentList.groceryList.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<GroceryListProvider>(
          builder: (context, provider, child) {
            if (provider.currentGroceryList != null) {
              return GestureDetector(
                onTap: _showEditListNameDialog,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.currentGroceryList!.groceryList.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit, size: 16, color: Colors.grey),
                  ],
                ),
              );
            }
            return const Text(
              'Grocery List',
              style: TextStyle(color: Colors.black87),
            );
          },
        ),
        actions: [
          Consumer<GroceryListProvider>(
            builder: (context, provider, child) {
              if (provider.currentGroceryList != null) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.local_shipping, color: Colors.black87),
                      onPressed: () => _navigateToDelivery(provider.currentGroceryList!),
                      tooltip: 'Order Delivery',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black87),
                      onPressed: _showAddItemModal,
                      tooltip: 'Add Item',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildDeliveryFab(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGroceryList,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Consumer<GroceryListProvider>(
      builder: (context, provider, child) {
        final groceryList = provider.currentGroceryList;

        if (groceryList == null) {
          return const Center(
            child: Text(
              'No grocery list found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          );
        }

        if (groceryList.totalItems == 0) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadGroceryList,
          child: Column(
            children: [
              // Summary Widget
              GroceryListSummaryWidget(groceryList: groceryList),
              
              // Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._buildCategoryWidgets(groceryList),
                    const SizedBox(height: 80), // Extra space for floating button
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your grocery list is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddItemModal,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryWidgets(GroceryListWithItems groceryList) {
    final categories = groceryList.categoriesWithItems;
    
    return categories.map((category) {
      final items = groceryList.itemsByCategory[category] ?? [];
      return GroceryCategorySection(
        category: category,
        items: items,
        onItemToggled: (itemId) {
          final provider = Provider.of<GroceryListProvider>(context, listen: false);
          provider.toggleItemChecked(itemId);
        },
        onItemDeleted: (itemId) async {
          final provider = Provider.of<GroceryListProvider>(context, listen: false);
          
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Item'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await provider.deleteItem(itemId);
          }
        },
        onItemQuantityChanged: (itemId, quantity, unit) async {
          final provider = Provider.of<GroceryListProvider>(context, listen: false);
          await provider.updateItemQuantity(itemId, quantity: quantity, unit: unit);
        },
      );
    }).toList();
  }

  Widget _buildDeliveryFab() {
    return Consumer<GroceryListProvider>(
      builder: (context, provider, child) {
        final groceryList = provider.currentGroceryList;
        
        // Show FAB if we have items (regardless of checked state)
        if (groceryList == null || groceryList.totalItems == 0) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _navigateToDelivery(groceryList),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.local_shipping),
          label: const Text('Order Delivery'),
        );
      },
    );
  }

  void _navigateToDelivery(GroceryListWithItems groceryList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroceryDeliveryScreen(groceryList: groceryList),
      ),
    );
  }
} 