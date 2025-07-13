import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/grocery_delivery.dart';
import '../../models/grocery_list.dart';
import '../../utils/app_constants.dart';
import 'grocery_checkout_screen.dart';

class GroceryDeliveryScreen extends StatefulWidget {
  final GroceryListWithItems groceryList;

  const GroceryDeliveryScreen({
    super.key,
    required this.groceryList,
  });

  @override
  State<GroceryDeliveryScreen> createState() => _GroceryDeliveryScreenState();
}

class _GroceryDeliveryScreenState extends State<GroceryDeliveryScreen> {
  List<DeliveryService> _services = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveryServices();
  }

  void _loadDeliveryServices() {
    _services = MockDeliveryServices.getAvailableServices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = widget.groceryList.groceryList.totalCostUsd ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Delivery'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with order summary
          Container(
            width: double.infinity,
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.groceryList.groceryList.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.groceryList.totalItems} items • \$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Available delivery services
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                Text(
                  'Choose a delivery service',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your groceries delivered to your door',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Service cards
                ...(_services.map((service) => _buildServiceCard(context, service, subtotal))),
                
                const SizedBox(height: 24),
                
                // Info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delivery Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Prices may vary from in-store prices\n'
                          '• Additional fees may apply\n'
                          '• Substitutions may be made for unavailable items\n'
                          '• You can add special instructions during checkout',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, DeliveryService service, double subtotal) {
    final theme = Theme.of(context);
    final estimatedTotal = subtotal + service.totalFees;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: service.isAvailable ? () => _selectService(context, service) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: service.isAvailable ? null : Colors.grey.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Service logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: service.isAvailable 
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        service.logo,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              service.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: service.isAvailable ? null : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (service.isAvailable) ...[
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                service.rating.toString(),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.isAvailable 
                              ? '${service.estimatedTime} delivery'
                              : service.promoText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: service.isAvailable 
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (service.promoText.isNotEmpty && service.isAvailable) ...[
                          const SizedBox(height: 2),
                          Text(
                            service.promoText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Price and arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (service.isAvailable) ...[
                        Text(
                          '\$${estimatedTotal.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'est. total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ] else ...[
                        Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Fee breakdown for available services
              if (service.isAvailable) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildFeeRow('Subtotal', subtotal),
                      _buildFeeRow('Delivery fee', service.baseFee),
                      if (service.serviceFee > 0)
                        _buildFeeRow('Service fee', service.serviceFee),
                      const Divider(height: 16),
                      _buildFeeRow('Estimated total', estimatedTotal, isBold: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  void _selectService(BuildContext context, DeliveryService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroceryCheckoutScreen(
          groceryList: widget.groceryList,
          deliveryService: service,
        ),
      ),
    );
  }
} 