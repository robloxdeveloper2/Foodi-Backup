import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/grocery_delivery.dart';
import '../../utils/app_constants.dart';

class GroceryOrderTrackingScreen extends StatefulWidget {
  final GroceryOrder order;

  const GroceryOrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<GroceryOrderTrackingScreen> createState() => _GroceryOrderTrackingScreenState();
}

class _GroceryOrderTrackingScreenState extends State<GroceryOrderTrackingScreen> {
  late GroceryOrder _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_currentOrder.id.substring(6, 12).toUpperCase()}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentOrder.statusDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Order details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Service: ${_currentOrder.serviceName}'),
                  Text('Total: \$${_currentOrder.total.toStringAsFixed(2)}'),
                  Text('Order time: ${DateFormat('MMM dd, h:mm a').format(_currentOrder.orderTime)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 