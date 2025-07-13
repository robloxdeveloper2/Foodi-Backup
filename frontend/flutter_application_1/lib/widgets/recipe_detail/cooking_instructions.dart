import 'package:flutter/material.dart';
import '../../models/recipe_detail_models.dart';
import '../../utils/app_constants.dart';

class CookingInstructions extends StatelessWidget {
  final List<RecipeStep> steps;
  final Function(int) onStepCompleted;
  final Function(int) onStepUncompleted;
  final bool isCookingMode;

  const CookingInstructions({
    Key? key,
    required this.steps,
    required this.onStepCompleted,
    required this.onStepUncompleted,
    this.isCookingMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isCookingMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Cooking Mode',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Steps list
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: step.isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: step.isCompleted 
                    ? Colors.green.withOpacity(0.3)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: InkWell(
              onTap: isCookingMode 
                  ? () {
                      if (step.isCompleted) {
                        onStepUncompleted(index);
                      } else {
                        onStepCompleted(index);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number or checkbox
                    if (isCookingMode) ...[
                      Checkbox(
                        value: step.isCompleted,
                        onChanged: (value) {
                          if (value == true) {
                            onStepCompleted(index);
                          } else {
                            onStepUncompleted(index);
                          }
                        },
                        activeColor: Colors.green,
                      ),
                    ] else ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${step.stepNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(width: AppConstants.defaultPadding),
                    
                    // Step content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step instruction
                          Text(
                            step.instruction,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: step.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: step.isCompleted 
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                  : null,
                            ),
                          ),
                          
                          // Duration and tips
                          if (step.durationMinutes != null || step.tips != null) ...[
                            const SizedBox(height: AppConstants.smallPadding),
                            
                            // Duration
                            if (step.durationMinutes != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    step.durationDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            
                            // Tips
                            if (step.tips != null) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        step.tips!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
} 