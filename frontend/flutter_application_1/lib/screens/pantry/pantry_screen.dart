import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pantry_item.dart';
import '../../providers/pantry_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_routes.dart';
import 'add_pantry_item_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPantryItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPantryItems() async {
    final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
    await pantryProvider.loadPantryItems(refresh: true);
  }

  Future<void> _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPantryItemScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the list if item was added successfully
      _loadPantryItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadPantryItems,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<PantryProvider>(
        builder: (context, pantryProvider, child) {
          return Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search pantry items...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          pantryProvider.setSearchQuery(value);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Items', 
                            pantryProvider.totalItems.toString(),
                            Icons.inventory,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Expiring Soon', 
                            pantryProvider.expiringSoonCount.toString(),
                            Icons.warning,
                            Colors.orange[100]!,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Expired', 
                            pantryProvider.expiredCount.toString(),
                            Icons.dangerous,
                            Colors.red[100]!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: !pantryProvider.showExpiredOnly && !pantryProvider.showExpiringSoon,
                        onSelected: (selected) {
                          if (selected) {
                            pantryProvider.setExpiredOnly(false);
                            pantryProvider.setExpiringSoon(false);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(
                          'Expiring Soon',
                          style: TextStyle(
                            color: pantryProvider.showExpiringSoon ? Colors.white : Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: pantryProvider.showExpiringSoon,
                        onSelected: (selected) {
                          pantryProvider.setExpiringSoon(selected);
                        },
                        backgroundColor: Colors.orange[50],
                        selectedColor: Colors.orange[600],
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(
                          'Expired',
                          style: TextStyle(
                            color: pantryProvider.showExpiredOnly ? Colors.white : Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: pantryProvider.showExpiredOnly,
                        onSelected: (selected) {
                          pantryProvider.setExpiredOnly(selected);
                        },
                        backgroundColor: Colors.red[50],
                        selectedColor: Colors.red[600],
                      ),
                      const SizedBox(width: 8),
                      // Category filter dropdown
                      DropdownButton<String?>(
                        value: pantryProvider.selectedCategory,
                        hint: const Text('Category'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...PantryConstants.validCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(PantryConstants.categoryDisplayNames[category] ?? category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          pantryProvider.setCategory(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Pantry Items List
              Expanded(
                child: pantryProvider.isLoading && pantryProvider.pantryItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : pantryProvider.pantryItems.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadPantryItems,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: pantryProvider.pantryItems.length + 
                                  (pantryProvider.hasNextPage ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == pantryProvider.pantryItems.length) {
                                  // Load more button
                                  return Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: pantryProvider.isLoading
                                          ? const CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: () {
                                                pantryProvider.loadMoreItems();
                                              },
                                              child: const Text('Load More'),
                                            ),
                                    ),
                                  );
                                }
                                
                                final item = pantryProvider.pantryItems[index];
                                return _buildPantryItemCard(item);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryGreen),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.kitchen,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No items in your pantry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to track your grocery inventory',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantryItemCard(PantryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.displayQuantity,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                                 if (item.isExpired)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.red[600],
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: const Text(
                       'EXPIRED',
                       style: TextStyle(
                         fontSize: 10,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                   )
                 else if (item.isExpiringSoon)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.orange[600],
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: const Text(
                       'EXPIRING',
                       style: TextStyle(
                         fontSize: 10,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                   ),
              ],
            ),
            
            if (item.category != null || item.expiryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.categoryDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                                     if (item.expiryDate != null)
                     Text(
                       item.expiryDisplayText,
                       style: TextStyle(
                         fontSize: 12,
                         color: item.isExpired ? Colors.red[700] : 
                                item.isExpiringSoon ? Colors.orange[700] : Colors.grey[600],
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                ],
              ),
            ],
            
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.notes!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 