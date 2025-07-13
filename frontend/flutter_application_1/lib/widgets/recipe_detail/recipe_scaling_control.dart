import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class RecipeScalingControl extends StatelessWidget {
  final double currentScale;
  final Function(double) onScaleChanged;
  final bool isLoading;

  const RecipeScalingControl({
    Key? key,
    required this.currentScale,
    required this.onScaleChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaleOptions = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0];
    final scaleLabels = {
      0.5: '½x',
      1.0: '1x',
      1.5: '1½x',
      2.0: '2x',
      3.0: '3x',
      4.0: '4x',
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recipe Scale',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Scale options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: scaleOptions.map((scale) {
                final isSelected = (currentScale - scale).abs() < 0.01;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(scaleLabels[scale] ?? '${scale}x'),
                    selected: isSelected,
                    onSelected: isLoading 
                        ? null 
                        : (selected) {
                            if (selected && !isSelected) {
                              onScaleChanged(scale);
                            }
                          },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Custom scale slider (optional)
          if (currentScale > 4.0 || !scaleOptions.contains(currentScale)) ...[
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                const Text('Custom: '),
                Expanded(
                  child: Slider(
                    value: currentScale.clamp(0.5, 10.0),
                    min: 0.5,
                    max: 10.0,
                    divisions: 19, // 0.5 increments
                    label: '${currentScale.toStringAsFixed(1)}x',
                    onChanged: isLoading ? null : onScaleChanged,
                  ),
                ),
                Text('${currentScale.toStringAsFixed(1)}x'),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 