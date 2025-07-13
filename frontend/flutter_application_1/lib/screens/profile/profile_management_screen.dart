import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/profile_setup_provider.dart';
import '../../utils/app_constants.dart';
import '../../models/user_model.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Current user selections (persisted locally)
  List<String> _selectedDietaryRestrictions = [];
  List<String> _selectedAllergies = [];
  List<String> _customDietaryRestrictions = [];
  List<String> _customAllergies = [];

  // SharedPreferences keys
  static const String _keyDietaryRestrictions = 'dietary_restrictions';
  static const String _keyAllergies = 'allergies';
  static const String _keyCustomDietaryRestrictions = 'custom_dietary_restrictions';
  static const String _keyCustomAllergies = 'custom_allergies';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Load setup options and saved data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // Load setup options
    await context.read<ProfileSetupProvider>().initializeProfileSetup();
    
    // Load saved dietary data
    await _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _selectedDietaryRestrictions = prefs.getStringList(_keyDietaryRestrictions) ?? [];
        _selectedAllergies = prefs.getStringList(_keyAllergies) ?? [];
        _customDietaryRestrictions = prefs.getStringList(_keyCustomDietaryRestrictions) ?? [];
        _customAllergies = prefs.getStringList(_keyCustomAllergies) ?? [];
      });
    } catch (e) {
      debugPrint('Error loading saved dietary data: $e');
    }
  }

  Future<void> _saveDietaryRestrictions(List<String> selected, List<String> custom) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyDietaryRestrictions, selected);
      await prefs.setStringList(_keyCustomDietaryRestrictions, custom);
    } catch (e) {
      debugPrint('Error saving dietary restrictions: $e');
    }
  }

  Future<void> _saveAllergies(List<String> selected, List<String> custom) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyAllergies, selected);
      await prefs.setStringList(_keyCustomAllergies, custom);
    } catch (e) {
      debugPrint('Error saving allergies: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile Management'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Personal', icon: Icon(Icons.person, size: 20)),
            Tab(text: 'Dietary', icon: Icon(Icons.restaurant, size: 20)),
            Tab(text: 'Cooking', icon: Icon(Icons.kitchen, size: 20)),
            Tab(text: 'Budget', icon: Icon(Icons.attach_money, size: 20)),
            Tab(text: 'Goals', icon: Icon(Icons.fitness_center, size: 20)),
          ],
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalTab(context, user),
              _buildDietaryTab(context, user),
              _buildCookingTab(context, user),
              _buildBudgetTab(context, user),
              _buildGoalsTab(context, user),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalTab(BuildContext context, User user) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Completion Card
          _buildProfileCompletionCard(context),
          
          const SizedBox(height: 24),
          
          // Personal Information Section
          _buildSectionCard(
            context,
            'Personal Information',
            [
              _buildEditableField(
                context,
                'First Name',
                user.firstName ?? '',
                Icons.person,
                (value) {
                  // TODO: Update first name
                },
              ),
              _buildEditableField(
                context,
                'Last Name',
                user.lastName ?? '',
                Icons.person_outline,
                (value) {
                  // TODO: Update last name
                },
              ),
              _buildReadOnlyField(
                context,
                'Username',
                user.username,
                Icons.alternate_email,
              ),
              _buildReadOnlyField(
                context,
                'Email',
                user.email,
                Icons.email,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Account Status Section
          _buildSectionCard(
            context,
            'Account Status',
            [
              _buildStatusField(
                context,
                'Email Verified',
                user.emailVerified,
                user.emailVerified ? Icons.verified : Icons.warning,
              ),
              _buildReadOnlyField(
                context,
                'Member Since',
                _formatDate(user.createdAt),
                Icons.calendar_today,
              ),
              _buildReadOnlyField(
                context,
                'Last Updated',
                _formatDate(user.updatedAt),
                Icons.update,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryTab(BuildContext context, User user) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context,
                'Dietary Restrictions',
                [
                  _buildSelectableChipListField(
                    context,
                    'Current Restrictions',
                    _selectedDietaryRestrictions,
                    _customDietaryRestrictions,
                    profileProvider.setupOptions?.dietaryRestrictions ?? [],
                    Icons.no_food,
                    onSelectionChanged: (selected, custom) async {
                      setState(() {
                        _selectedDietaryRestrictions = selected;
                        _customDietaryRestrictions = custom;
                      });
                      await _saveDietaryRestrictions(selected, custom);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSectionCard(
                context,
                'Food Allergies',
                [
                  _buildSelectableChipListField(
                    context,
                    'Known Allergies',
                    _selectedAllergies,
                    _customAllergies,
                    profileProvider.setupOptions?.allergies ?? [],
                    Icons.warning,
                    onSelectionChanged: (selected, custom) async {
                      setState(() {
                        _selectedAllergies = selected;
                        _customAllergies = custom;
                      });
                      await _saveAllergies(selected, custom);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCookingTab(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            'Cooking Experience',
            [
              _buildDropdownField(
                context,
                'Experience Level',
                '', // TODO: Get from detailed profile API
                ['Beginner', 'Intermediate', 'Advanced'],
                Icons.restaurant_menu,
                (value) {
                  // TODO: Update cooking experience
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionCard(
            context,
            'Kitchen Equipment',
            [
              _buildChipListField(
                context,
                'Available Equipment',
                [], // TODO: Get from user preferences
                Icons.kitchen,
                onAdd: (value) {
                  // TODO: Add equipment
                },
                onRemove: (value) {
                  // TODO: Remove equipment
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            'Budget Settings',
            [
              _buildDropdownField(
                context,
                'Budget Period',
                '', // TODO: Get from detailed profile API
                ['Weekly', 'Monthly'],
                Icons.schedule,
                (value) {
                  // TODO: Update budget period
                },
              ),
              _buildEditableField(
                context,
                'Budget Amount',
                '', // TODO: Get from detailed profile API
                Icons.attach_money,
                (value) {
                  // TODO: Update budget amount
                },
                inputType: TextInputType.number,
              ),
              _buildDropdownField(
                context,
                'Currency',
                'USD', // TODO: Get from detailed profile API
                ['USD', 'EUR', 'GBP', 'CAD'],
                Icons.monetization_on,
                (value) {
                  // TODO: Update currency
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            'Nutritional Goals',
            [
              _buildDropdownField(
                context,
                'Weight Goal',
                '', // TODO: Get from detailed profile API
                ['Lose', 'Maintain', 'Gain'],
                Icons.fitness_center,
                (value) {
                  // TODO: Update weight goal
                },
              ),
              _buildEditableField(
                context,
                'Daily Calorie Target',
                '', // TODO: Get from detailed profile API
                Icons.local_fire_department,
                (value) {
                  // TODO: Update calorie target
                },
                inputType: TextInputType.number,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context) {
    final theme = Theme.of(context);
    
    // TODO: Get actual completion percentage from detailed profile
    final completionPercentage = 65;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Completion',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '$completionPercentage% Complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Function(String) onChanged, {
    TextInputType inputType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
      ),
    );
  }

  Widget _buildStatusField(
    BuildContext context,
    String label,
    bool status,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: status ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  status ? 'Yes' : 'No',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: status ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context,
    String label,
    String value,
    List<String> options,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value.isNotEmpty ? value : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildChipListField(
    BuildContext context,
    String label,
    List<String> items,
    IconData icon, {
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onRemove(item),
                );
              }).toList(),
            )
          else
            Text(
              'None selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // TODO: Show dialog to add new item
              _showAddItemDialog(context, label, onAdd);
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add ${label.toLowerCase()}'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String label, Function(String) onAdd) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableChipListField(
    BuildContext context,
    String label,
    List<String> selectedItems,
    List<String> customItems,
    List<String> availableOptions,
    IconData icon, {
    required Function(List<String> selected, List<String> custom) onSelectionChanged,
  }) {
    final theme = Theme.of(context);
    final allItems = [...selectedItems, ...customItems];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (allItems.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allItems.map((item) {
                return Chip(
                  label: Text(_formatOption(item)),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final newSelected = List<String>.from(selectedItems);
                    final newCustom = List<String>.from(customItems);
                    
                    if (selectedItems.contains(item)) {
                      newSelected.remove(item);
                    }
                    if (customItems.contains(item)) {
                      newCustom.remove(item);
                    }
                    
                    onSelectionChanged(newSelected, newCustom);
                  },
                );
              }).toList(),
            )
          else
            Text(
              'None selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  _showSelectionDialog(
                    context, 
                    label, 
                    availableOptions, 
                    selectedItems, 
                    customItems,
                    onSelectionChanged,
                  );
                },
                icon: const Icon(Icons.checklist, size: 18),
                label: Text('Select ${label.toLowerCase()}'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  _showAddCustomItemDialog(
                    context, 
                    label, 
                    selectedItems, 
                    customItems,
                    onSelectionChanged,
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add custom'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    String label,
    List<String> availableOptions,
    List<String> currentSelected,
    List<String> currentCustom,
    Function(List<String> selected, List<String> custom) onSelectionChanged,
  ) {
    List<String> tempSelected = List.from(currentSelected);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Select $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose from available options:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableOptions.map((option) {
                      final isSelected = tempSelected.contains(option);
                      return FilterChip(
                        label: Text(_formatOption(option)),
                        selected: isSelected,
                        onSelected: (bool value) {
                          setDialogState(() {
                            if (value) {
                              tempSelected.add(option);
                            } else {
                              tempSelected.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSelectionChanged(tempSelected, currentCustom);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomItemDialog(
    BuildContext context,
    String label,
    List<String> currentSelected,
    List<String> currentCustom,
    Function(List<String> selected, List<String> custom) onSelectionChanged,
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter custom ${label.toLowerCase()}',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newCustom = List<String>.from(currentCustom);
                newCustom.add(controller.text.trim());
                onSelectionChanged(currentSelected, newCustom);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _formatOption(String option) {
    return option.split('-').map((word) => 
        word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
} 