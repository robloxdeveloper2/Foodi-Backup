import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class DietaryRestrictionsStep extends StatefulWidget {
  const DietaryRestrictionsStep({super.key});

  @override
  State<DietaryRestrictionsStep> createState() => _DietaryRestrictionsStepState();
}

class _DietaryRestrictionsStepState extends State<DietaryRestrictionsStep> {
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        final options = provider.setupOptions;
        if (options == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dietary Restrictions & Preferences',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Select any dietary restrictions or preferences you have. This helps us recommend suitable recipes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              
              // Dietary Restrictions Section
              _buildSection(
                context,
                'Dietary Restrictions',
                options.dietaryRestrictions,
                provider.profileData.dietaryRestrictions,
                (selected) => provider.updateDietaryRestrictions(selected),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Allergies Section
              _buildSection(
                context,
                'Food Allergies',
                options.allergies,
                provider.profileData.allergies,
                (selected) => provider.updateAllergies(selected),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Custom Restrictions Section
              _buildCustomRestrictionsSection(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> options,
    List<String> selected,
    Function(List<String>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(_formatOption(option)),
              selected: isSelected,
              onSelected: (bool value) {
                final newSelected = List<String>.from(selected);
                if (value) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomRestrictionsSection(BuildContext context, ProfileSetupProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Restrictions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          'Add any other dietary restrictions not listed above.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Custom input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  hintText: 'Enter custom restriction',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => _addCustomRestriction(provider, value),
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            IconButton(
              onPressed: () => _addCustomRestriction(provider, _customController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Display custom restrictions
        if (provider.profileData.customDietaryRestrictions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.profileData.customDietaryRestrictions.map((restriction) {
              return Chip(
                label: Text(_formatOption(restriction)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => provider.removeCustomDietaryRestriction(restriction),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addCustomRestriction(ProfileSetupProvider provider, String value) {
    if (value.trim().isNotEmpty) {
      provider.addCustomDietaryRestriction(value.trim());
      _customController.clear();
    }
  }

  String _formatOption(String option) {
    return option.split('-').map((word) => 
        word.substring(0, 1).toUpperCase() + word.substring(1)
    ).join(' ');
  }
} 