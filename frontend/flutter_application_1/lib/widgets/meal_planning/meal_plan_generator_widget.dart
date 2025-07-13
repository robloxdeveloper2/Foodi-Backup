import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealPlanGeneratorWidget extends StatefulWidget {
  final Function({
    required int durationDays,
    String? planDate,
    double? budgetUsd,
    bool includeSnacks,
  }) onGeneratePressed;

  const MealPlanGeneratorWidget({
    super.key,
    required this.onGeneratePressed,
  });

  @override
  State<MealPlanGeneratorWidget> createState() => _MealPlanGeneratorWidgetState();
}

class _MealPlanGeneratorWidgetState extends State<MealPlanGeneratorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  
  int _durationDays = 1;
  DateTime? _selectedDate;
  bool _includeSnacks = false;
  bool _setBudget = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration Selection
              const Text(
                'Plan Duration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(7, (index) {
                    final days = index + 1;
                    final isSelected = _durationDays == days;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _durationDays = days),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[600] : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$days',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 20),

              // Start Date Selection
              const Text(
                'Start Date (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                            : 'Start today',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Budget Setting
              Row(
                children: [
                  Switch(
                    value: _setBudget,
                    onChanged: (value) {
                      setState(() {
                        _setBudget = value;
                        if (!value) {
                          _budgetController.clear();
                        }
                      });
                    },
                    activeColor: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Set Budget Limit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              if (_setBudget) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Budget (\$)',
                    hintText: 'Enter your budget',
                    prefixIcon: Icon(Icons.attach_money, color: Colors.green[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[600]!),
                    ),
                  ),
                  validator: (value) {
                    if (_setBudget && (value == null || value.isEmpty)) {
                      return 'Please enter a budget amount';
                    }
                    if (_setBudget && double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    if (_setBudget && double.parse(value!) <= 0) {
                      return 'Budget must be greater than 0';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Include Snacks
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SwitchListTile(
                  value: _includeSnacks,
                  onChanged: (value) => setState(() => _includeSnacks = value),
                  title: const Text(
                    'Include Snacks',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Add healthy snacks to your meal plan',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  activeColor: Colors.green[600],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),

              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateMealPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Generate Meal Plan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _generateMealPlan() {
    if (_formKey.currentState!.validate()) {
      final budgetUsd = _setBudget && _budgetController.text.isNotEmpty
          ? double.tryParse(_budgetController.text)
          : null;

      final planDate = _selectedDate?.toIso8601String().split('T')[0];

      widget.onGeneratePressed(
        durationDays: _durationDays,
        planDate: planDate,
        budgetUsd: budgetUsd,
        includeSnacks: _includeSnacks,
      );
    }
  }
} 