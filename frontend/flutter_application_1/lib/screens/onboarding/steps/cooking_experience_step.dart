import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class CookingExperienceStep extends StatefulWidget {
  const CookingExperienceStep({super.key});

  @override
  State<CookingExperienceStep> createState() => _CookingExperienceStepState();
}

class _CookingExperienceStepState extends State<CookingExperienceStep> {
  String? _selectedExperienceLevel;
  String? _selectedFrequency;
  final Set<String> _selectedEquipment = <String>{};

  // Default cooking experience levels if not loaded from backend
  final List<Map<String, String>> _defaultExperienceLevels = [
    {
      'value': 'beginner',
      'label': 'Beginner',
      'description': 'I\'m new to cooking and prefer simple recipes with basic techniques.',
    },
    {
      'value': 'intermediate',
      'label': 'Intermediate',
      'description': 'I can handle most recipes and am comfortable with various cooking methods.',
    },
    {
      'value': 'advanced',
      'label': 'Advanced',
      'description': 'I\'m experienced with complex recipes and advanced cooking techniques.',
    },
  ];

  final List<String> _cookingFrequencies = [
    'Daily',
    'Several times a week',
    'Weekly',
    'Occasionally',
    'Rarely',
  ];

  final List<String> _defaultKitchenEquipment = [
    'Oven',
    'Stovetop',
    'Microwave',
    'Blender',
    'Food Processor',
    'Stand Mixer',
    'Air Fryer',
    'Slow Cooker',
    'Pressure Cooker',
    'Grill',
    'Rice Cooker',
    'Toaster Oven',
    'Immersion Blender',
    'Kitchen Scale',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
      final data = provider.profileData;
      
      setState(() {
        _selectedExperienceLevel = data.cookingExperienceLevel;
        _selectedFrequency = data.cookingFrequency;
        _selectedEquipment.addAll(data.kitchenEquipment);
      });
    });
  }

  void _updateCookingExperience() {
    final provider = Provider.of<ProfileSetupProvider>(context, listen: false);
    provider.updateCookingExperience(
      level: _selectedExperienceLevel,
      frequency: _selectedFrequency,
      equipment: _selectedEquipment.toList(),
    );
  }

  List<Widget> _getExperienceLevelWidgets(dynamic experienceLevels) {
    if (experienceLevels is List<Map<String, String>>) {
      // Use default experience levels
      return experienceLevels.map((level) {
        final value = level['value']!;
        final label = level['label']!;
        final description = level['description']!;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: RadioListTile<String>(
            value: value,
            groupValue: _selectedExperienceLevel,
            onChanged: (String? value) {
              setState(() {
                _selectedExperienceLevel = value;
              });
              _updateCookingExperience();
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
      // Use backend experience levels
      return (experienceLevels as List).map((level) {
        final value = level.value;
        final label = level.label;
        final description = level.description;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: RadioListTile<String>(
            value: value,
            groupValue: _selectedExperienceLevel,
            onChanged: (String? value) {
              setState(() {
                _selectedExperienceLevel = value;
              });
              _updateCookingExperience();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        final options = provider.setupOptions;
        final experienceLevels = options?.cookingExperienceLevels ?? _defaultExperienceLevels;
        final availableEquipment = options?.kitchenEquipment ?? _defaultKitchenEquipment;

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
                      Icons.kitchen,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Cooking Experience',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      'Tell us about your cooking skills and kitchen setup',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppConstants.largePadding),

              // Experience Level Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cooking Experience Level',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      ..._getExperienceLevelWidgets(experienceLevels),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Cooking Frequency Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Often Do You Cook?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'This helps us recommend recipes with appropriate time requirements',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      Wrap(
                        spacing: AppConstants.smallPadding,
                        runSpacing: AppConstants.smallPadding,
                        children: _cookingFrequencies.map((frequency) {
                          final isSelected = _selectedFrequency == frequency;
                          
                          return FilterChip(
                            label: Text(frequency),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedFrequency = selected ? frequency : null;
                              });
                              _updateCookingExperience();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.defaultPadding),

              // Kitchen Equipment Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Kitchen Equipment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        'Select the equipment you have available for cooking',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      
                      Wrap(
                        spacing: AppConstants.smallPadding,
                        runSpacing: AppConstants.smallPadding,
                        children: availableEquipment.map((equipment) {
                          final isSelected = _selectedEquipment.contains(equipment);
                          
                          return FilterChip(
                            label: Text(equipment),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedEquipment.add(equipment);
                                } else {
                                  _selectedEquipment.remove(equipment);
                                }
                              });
                              _updateCookingExperience();
                            },
                          );
                        }).toList(),
                      ),
                      
                      if (_selectedEquipment.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.defaultPadding),
                        Container(
                          padding: const EdgeInsets.all(AppConstants.smallPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Expanded(
                                child: Text(
                                  '${_selectedEquipment.length} items selected',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedEquipment.clear();
                                  });
                                  _updateCookingExperience();
                                },
                                child: const Text('Clear All'),
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

              // Skip Option
              Center(
                child: TextButton.icon(
                  onPressed: () => _updateCookingExperience(),
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