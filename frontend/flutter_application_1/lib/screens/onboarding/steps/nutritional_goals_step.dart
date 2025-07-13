import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class NutritionalGoalsStep extends StatefulWidget {
  const NutritionalGoalsStep({super.key});

  @override
  State<NutritionalGoalsStep> createState() => _NutritionalGoalsStepState();
}

class _NutritionalGoalsStepState extends State<NutritionalGoalsStep> {
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();
  
  String? _selectedWeightGoal;
  String? _selectedDietaryProgram;

  // Default weight goals
  final List<Map<String, String>> _weightGoals = [
    {
      'value': 'lose_weight',
      'label': 'Lose Weight',
      'description': 'I want to lose weight through proper nutrition',
    },
    {
      'value': 'maintain_weight',
      'label': 'Maintain Weight',
      'description': 'I want to maintain my current weight',
    },
    {
      'value': 'gain_weight',
      'label': 'Gain Weight',
      'description': 'I want to gain weight in a healthy way',
    },
    {
      'value': 'build_muscle',
      'label': 'Build Muscle',
      'description': 'I want to build muscle mass',
    },
  ];

  // Default dietary programs
  final List<Map<String, String>> _defaultDietaryPrograms = [
    {
      'value': 'none',
      'label': 'No Specific Program',
      'description': 'I\'m not following any specific dietary program',
    },
    {
      'value': 'mediterranean',
      'label': 'Mediterranean Diet',
      'description': 'Focus on whole grains, fruits, vegetables, and healthy fats',
    },
    {
      'value': 'keto',
      'label': 'Ketogenic Diet',
      'description': 'High fat, very low carb eating plan',
    },
    {
      'value': 'paleo',
      'label': 'Paleo Diet',
      'description': 'Focus on whole foods, avoiding processed foods',
    },
    {
      'value': 'intermittent_fasting',
      'label': 'Intermittent Fasting',
      'description': 'Eating within specific time windows',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
      final data = provider.profileData;
      
      setState(() {
        _selectedWeightGoal = data.weightGoal;
        _selectedDietaryProgram = data.dietaryProgram;
        
        if (data.dailyCalorieTarget != null) {
          _caloriesController.text = data.dailyCalorieTarget.toString();
        }
        if (data.proteinTargetPct != null) {
          _proteinController.text = (data.proteinTargetPct! * 100).round().toString();
        }
        if (data.carbTargetPct != null) {
          _carbController.text = (data.carbTargetPct! * 100).round().toString();
        }
        if (data.fatTargetPct != null) {
          _fatController.text = (data.fatTargetPct! * 100).round().toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _updateNutritionalGoals() {
    final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
    
    int? dailyCalories;
    if (_caloriesController.text.isNotEmpty) {
      dailyCalories = int.tryParse(_caloriesController.text);
    }

    double? protein;
    if (_proteinController.text.isNotEmpty) {
      final percent = int.tryParse(_proteinController.text);
      if (percent != null) protein = percent / 100.0;
    }

    double? carbs;
    if (_carbController.text.isNotEmpty) {
      final percent = int.tryParse(_carbController.text);
      if (percent != null) carbs = percent / 100.0;
    }

    double? fat;
    if (_fatController.text.isNotEmpty) {
      final percent = int.tryParse(_fatController.text);
      if (percent != null) fat = percent / 100.0;
    }

    provider.updateNutritionalGoals(
      weightGoal: _selectedWeightGoal,
      dailyCalories: dailyCalories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      dietaryProgram: _selectedDietaryProgram,
    );
  }

  bool _validateMacros() {
    final protein = int.tryParse(_proteinController.text) ?? 0;
    final carbs = int.tryParse(_carbController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    final total = protein + carbs + fat;
    
    return total <= 100;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        final options = provider.setupOptions;
        final dietaryPrograms = options?.dietaryPrograms ?? 
            _defaultDietaryPrograms.map((program) => {
              'value': program['value']!,
              'label': program['label']!,
              'description': program['description']!,
            }).toList();

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
                      Icons.fitness_center,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Nutritional Goals',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Set your health and fitness goals for personalized nutrition',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),

              // Weight Goal Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight Management Goal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      ..._weightGoals.map((goal) {
                        final value = goal['value']!;
                        final label = goal['label']!;
                        final description = goal['description']!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                          child: RadioListTile<String>(
                            value: value,
                            groupValue: _selectedWeightGoal,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedWeightGoal = value;
                              });
                              _updateNutritionalGoals();
                            },
                            title: Text(
                              label,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Daily Calorie Target Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Calorie Target',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Set your target daily calorie intake (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      TextFormField(
                        controller: _caloriesController,
                        decoration: const InputDecoration(
                          labelText: 'Daily Calories',
                          hintText: 'e.g., 2000',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_fire_department),
                          suffixText: 'kcal',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _updateNutritionalGoals(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Macro-nutrients Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macro-nutrient Targets',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Set percentage targets for protein, carbs, and fat (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      Row(
                        children: [
                          // Protein
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              decoration: const InputDecoration(
                                labelText: 'Protein',
                                hintText: '30',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (value) {
                                if (_validateMacros()) {
                                  _updateNutritionalGoals();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          
                          // Carbs
                          Expanded(
                            child: TextFormField(
                              controller: _carbController,
                              decoration: const InputDecoration(
                                labelText: 'Carbs',
                                hintText: '40',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (value) {
                                if (_validateMacros()) {
                                  _updateNutritionalGoals();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.smallPadding),
                          
                          // Fat
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              decoration: const InputDecoration(
                                labelText: 'Fat',
                                hintText: '30',
                                border: OutlineInputBorder(),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (value) {
                                if (_validateMacros()) {
                                  _updateNutritionalGoals();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      // Macro validation feedback
                      if (!_validateMacros()) ...[
                        const SizedBox(height: AppConstants.smallPadding),
                        Container(
                          padding: const EdgeInsets.all(AppConstants.smallPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Theme.of(context).colorScheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Expanded(
                                child: Text(
                                  'Total percentages should not exceed 100%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Dietary Program Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dietary Program',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Are you following a specific dietary program? (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      ..._getDietaryProgramWidgets(dietaryPrograms),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Skip Option
              Center(
                child: TextButton.icon(
                  onPressed: () => _updateNutritionalGoals(),
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

  List<Widget> _getDietaryProgramWidgets(dynamic dietaryPrograms) {
    if (dietaryPrograms is List<Map<String, String>>) {
      // Use default dietary programs
      return dietaryPrograms.map((program) {
        final value = program['value']!;
        final label = program['label']!;
        final description = program['description']!;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: RadioListTile<String>(
            value: value,
            groupValue: _selectedDietaryProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedDietaryProgram = value;
              });
              _updateNutritionalGoals();
            },
            title: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      }).toList();
    } else {
      // Use backend dietary programs
      return (dietaryPrograms as List).map((program) {
        final value = program.value;
        final label = program.label;
        final description = program.description;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: RadioListTile<String>(
            value: value,
            groupValue: _selectedDietaryProgram,
            onChanged: (String? value) {
              setState(() {
                _selectedDietaryProgram = value;
              });
              _updateNutritionalGoals();
            },
            title: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      }).toList();
    }
  }
} 