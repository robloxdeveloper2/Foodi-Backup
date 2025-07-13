import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class BudgetStep extends StatefulWidget {
  const BudgetStep({super.key});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  final _budgetAmountController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();
  
  String _selectedPeriod = 'weekly';
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
      final data = provider.profileData;
      
      if (data.budgetAmount != null) {
        _budgetAmountController.text = data.budgetAmount.toString();
      }
      if (data.budgetPeriod != null) {
        _selectedPeriod = data.budgetPeriod!;
      }
      if (data.currency.isNotEmpty) {
        _selectedCurrency = data.currency;
      }
      if (data.pricePerMealMin != null) {
        _priceMinController.text = data.pricePerMealMin.toString();
      }
      if (data.pricePerMealMax != null) {
        _priceMaxController.text = data.pricePerMealMax.toString();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _budgetAmountController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  void _updateBudgetInfo() {
    final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
    
    double? budgetAmount;
    if (_budgetAmountController.text.isNotEmpty) {
      budgetAmount = double.tryParse(_budgetAmountController.text);
    }

    double? priceMin;
    if (_priceMinController.text.isNotEmpty) {
      priceMin = double.tryParse(_priceMinController.text);
    }

    double? priceMax;
    if (_priceMaxController.text.isNotEmpty) {
      priceMax = double.tryParse(_priceMaxController.text);
    }

    provider.updateBudgetInfo(
      period: _selectedPeriod,
      amount: budgetAmount,
      currency: _selectedCurrency,
      priceMin: priceMin,
      priceMax: priceMax,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        final options = provider.setupOptions;
        final currencies = options?.currencies ?? ['USD', 'EUR', 'GBP', 'CAD', 'AUD'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Budget Information',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Help us recommend meals that fit your budget',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),

              // Overall Budget Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Budget',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      // Budget Period Selection
                      Text(
                        'Budget Period',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'weekly',
                            label: Text('Weekly'),
                            icon: Icon(Icons.calendar_view_week),
                          ),
                          ButtonSegment<String>(
                            value: 'monthly',
                            label: Text('Monthly'),
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                        selected: {_selectedPeriod},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedPeriod = newSelection.first;
                          });
                          _updateBudgetInfo();
                        },
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      // Currency and Amount
                      Row(
                        children: [
                          // Currency Dropdown
                          SizedBox(
                            width: 100,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: const InputDecoration(
                                labelText: 'Currency',
                                border: OutlineInputBorder(),
                              ),
                              items: currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCurrency = value;
                                  });
                                  _updateBudgetInfo();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.defaultPadding),
                          
                          // Budget Amount
                          Expanded(
                            child: TextFormField(
                              controller: _budgetAmountController,
                              decoration: InputDecoration(
                                labelText: '${_selectedPeriod.capitalize()} Budget',
                                hintText: '0.00',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.attach_money),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onChanged: (value) => _updateBudgetInfo(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Price Per Meal Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Range Per Meal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Set your preferred price range for individual meals',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      Row(
                        children: [
                          // Minimum Price
                          Expanded(
                            child: TextFormField(
                              controller: _priceMinController,
                              decoration: const InputDecoration(
                                labelText: 'Min Price',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.remove),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onChanged: (value) => _updateBudgetInfo(),
                            ),
                          ),
                          
                          const SizedBox(width: AppConstants.defaultPadding),
                          
                          // Maximum Price
                          Expanded(
                            child: TextFormField(
                              controller: _priceMaxController,
                              decoration: const InputDecoration(
                                labelText: 'Max Price',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.add),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onChanged: (value) => _updateBudgetInfo(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Skip Option
              Center(
                child: TextButton.icon(
                  onPressed: () => _updateBudgetInfo(),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip - I\'ll set this later'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
} 