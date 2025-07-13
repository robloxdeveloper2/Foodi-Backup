import 'package:flutter/material.dart';
import '../models/grocery_list.dart';

class GroceryListSummaryWidget extends StatelessWidget {
  final GroceryListWithItems groceryList;

  const GroceryListSummaryWidget({
    Key? key,
    required this.groceryList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionPercentage = groceryList.completionPercentage;
    final checkedCount = groceryList.checkedCount;
    final totalItems = groceryList.totalItems;
    final totalCost = groceryList.groceryList.formattedCost;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping Progress',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$checkedCount of $totalItems items',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: completionPercentage / 100,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 6,
              ),
              const SizedBox(width: 12),
              Text(
                '${completionPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white30,
          ),
          
          const SizedBox(height: 16),
          
          // Cost and Stats Section
          Row(
            children: [
              // Total Cost
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Total',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalCost,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Categories Count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.category,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${groceryList.categoriesWithItems.length} categories',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Completion Message
          if (completionPercentage == 100) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[300]!, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[300],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Shopping Complete!',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 