import 'package:flutter/material.dart';
import '../../../models/user_recipe_models.dart';

class CategoryChip extends StatelessWidget {
  final UserRecipeCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showRecipeCount;
  final int? recipeCount;

  const CategoryChip({
    Key? key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.onRemove,
    this.showRecipeCount = false,
    this.recipeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use category color or default
    final chipColor = category.color ?? colorScheme.primary;
    final backgroundColor = isSelected 
        ? chipColor.withOpacity(0.3)
        : chipColor.withOpacity(0.1);
    final borderColor = chipColor;
    final textColor = isSelected 
        ? chipColor
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category color indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            
            // Category name
            Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            
            // Recipe count (optional)
            if (showRecipeCount && recipeCount != null) ...[
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$recipeCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            
            // Remove button (optional)
            if (onRemove != null) ...[
              SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A specialized chip for category selection with filter functionality
class CategoryFilterChip extends StatelessWidget {
  final UserRecipeCategory category;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final int? recipeCount;

  const CategoryFilterChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
    this.recipeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category.color ?? Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          
          // Category name
          Text(category.name),
          
          // Recipe count
          if (recipeCount != null) ...[
            SizedBox(width: 4),
            Text(
              '($recipeCount)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: category.color?.withOpacity(0.1),
      selectedColor: category.color?.withOpacity(0.3),
      checkmarkColor: category.color,
      side: category.color != null
          ? BorderSide(color: category.color!)
          : null,
    );
  }
}

/// A simple category display chip (non-interactive)
class CategoryDisplayChip extends StatelessWidget {
  final UserRecipeCategory category;
  final bool compact;

  const CategoryDisplayChip({
    Key? key,
    required this.category,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = category.color ?? theme.colorScheme.primary;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: chipColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
              fontSize: compact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
} 