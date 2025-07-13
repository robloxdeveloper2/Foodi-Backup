import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/grocery_delivery.dart';
import '../../models/grocery_list.dart';
import '../../utils/app_constants.dart';
import 'grocery_order_tracking_screen.dart';

class GroceryCheckoutScreen extends StatefulWidget {
  final GroceryListWithItems groceryList;
  final DeliveryService deliveryService;

  const GroceryCheckoutScreen({
    super.key,
    required this.groceryList,
    required this.deliveryService,
  });

  @override
  State<GroceryCheckoutScreen> createState() => _GroceryCheckoutScreenState();
}

class _GroceryCheckoutScreenState extends State<GroceryCheckoutScreen> {
  double _tipAmount = 0.0;
  final List<double> _tipOptions = [0.0, 2.0, 3.0, 5.0];
  int _selectedTipIndex = 0;
  final TextEditingController _instructionsController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double get subtotal => widget.groceryList.groceryList.totalCostUsd ?? 0.0;
  double get total => subtotal + widget.deliveryService.totalFees + _tipAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout - ${widget.deliveryService.name}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Order summary
                _buildOrderSummary(theme),
                const SizedBox(height: 24),
                
                // Delivery details
                _buildDeliveryDetails(theme),
                const SizedBox(height: 24),
                
                // Tip section
                _buildTipSection(theme),
                const SizedBox(height: 24),
                
                // Special instructions
                _buildInstructionsSection(theme),
                const SizedBox(height: 24),
                
                // Payment method (mock)
                _buildPaymentSection(theme),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCheckout(theme),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              widget.groceryList.groceryList.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.groceryList.totalItems} items from your grocery list',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            // Show sample items
            ...widget.groceryList.itemsByCategory.entries.take(3).map((entry) {
              final items = entry.value.take(2).toList();
              return Column(
                children: items.map((item) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity} ${item.unit ?? ''} ${item.ingredientName}'.trim(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          item.formattedCost.isNotEmpty ? item.formattedCost : '\$-.--',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                ).toList(),
              );
            }).toList(),
            
            if (widget.groceryList.totalItems > 6) ...[
              const SizedBox(height: 8),
              Text(
                '+ ${widget.groceryList.totalItems - 6} more items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.deliveryService.logo,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivery Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow(
              Icons.access_time,
              'Estimated delivery',
              widget.deliveryService.estimatedTime,
              theme,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Delivery address',
              '123 Main St, Your City, State 12345',
              theme,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.store_outlined,
              'Store',
              'Local Grocery Store',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add a tip',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Show your appreciation for great service',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: _tipOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                final isSelected = _selectedTipIndex == index;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < _tipOptions.length - 1 ? 8 : 0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTipIndex = index;
                          _tipAmount = tip;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected 
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            tip == 0 ? 'No tip' : '\$${tip.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Special instructions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add any special notes for your shopper',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., "Call when you arrive", "Please select ripe avocados"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visa ending in 4242',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Default payment method',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Mock change payment method
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment method selection (mock)')),
                    );
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCheckout(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cost breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: theme.textTheme.bodyMedium),
                Text('\$${subtotal.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery & fees', style: theme.textTheme.bodyMedium),
                Text('\$${widget.deliveryService.totalFees.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
              ],
            ),
            if (_tipAmount > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tip', style: theme.textTheme.bodyMedium),
                  Text('\$${_tipAmount.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Place order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Place Order • \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    // Simulate order placement
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Create mock order
      final order = MockDeliveryServices.createMockOrder(
        groceryListId: widget.groceryList.groceryList.id,
        service: widget.deliveryService,
        subtotal: subtotal,
        tip: _tipAmount,
      );

      // Navigate to order tracking
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GroceryOrderTrackingScreen(order: order),
        ),
      );
    }
  }
} 