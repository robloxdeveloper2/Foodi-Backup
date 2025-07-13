import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_recipe_models.dart';
import '../../../providers/user_recipe_provider.dart';
import '../../user_recipes/custom_recipe_form_screen.dart';
import 'recipe_export_dialog.dart';

class RecipeActionSheet extends StatelessWidget {
  final UserRecipe recipe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const RecipeActionSheet({
    Key? key,
    required this.recipe,
    this.onEdit,
    this.onDelete,
    this.onShare,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required UserRecipe recipe,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onShare,
  }) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RecipeActionSheet(
        recipe: recipe,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          
          // Recipe header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Recipe image or placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: recipe.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                color: theme.colorScheme.onSurfaceVariant,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
                SizedBox(width: 16),
                
                // Recipe info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.description != null) ...[
                        SizedBox(height: 4),
                        Text(
                          recipe.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4),
                      Text(
                        recipe.isCustom ? 'Custom Recipe' : 'Favorited Recipe',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: recipe.isCustom 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Action buttons
          ..._buildActionButtons(context),
          
          // Cancel button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return [
      // Edit action (only for custom recipes)
      if (recipe.isCustom)
        _ActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit Recipe',
          onTap: () {
            Navigator.of(context).pop();
            _editRecipe(context);
          },
        ),
      
      // Share action
      _ActionButton(
        icon: Icons.share_outlined,
        label: 'Share Recipe',
        onTap: () {
          Navigator.of(context).pop();
          _shareRecipe(context);
        },
      ),
      
      // Export action
      _ActionButton(
        icon: Icons.download_outlined,
        label: 'Export Recipe',
        onTap: () {
          Navigator.of(context).pop();
          _exportRecipe(context);
        },
      ),
      
      // Duplicate action (create copy)
      _ActionButton(
        icon: Icons.copy_outlined,
        label: 'Duplicate Recipe',
        onTap: () {
          Navigator.of(context).pop();
          _duplicateRecipe(context);
        },
      ),
      
      // Remove from collection (for favorited) or delete (for custom)
      _ActionButton(
        icon: recipe.isCustom ? Icons.delete_outline : Icons.favorite_border,
        label: recipe.isCustom ? 'Delete Recipe' : 'Remove from Favorites',
        textColor: theme.colorScheme.error,
        onTap: () {
          Navigator.of(context).pop();
          _showDeleteConfirmation(context);
        },
      ),
    ];
  }

  void _editRecipe(BuildContext context) {
    if (!recipe.isCustom) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomRecipeFormScreen(
          existingRecipe: recipe,
          isEditing: true,
        ),
      ),
    );
    
    onEdit?.call();
  }

  void _shareRecipe(BuildContext context) {
    // Implement sharing functionality
    // This could open native share dialog or copy link
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing functionality coming soon!')),
    );
    
    onShare?.call();
  }

  void _exportRecipe(BuildContext context) {
    RecipeExportDialog.show(
      context: context,
      recipe: recipe,
    );
  }

  void _duplicateRecipe(BuildContext context) async {
    try {
      final provider = Provider.of<UserRecipeProvider>(context, listen: false);
      
      // Create a copy of the recipe as a custom recipe
      final createRequest = CreateRecipeRequest(
        name: '${recipe.name} (Copy)',
        description: recipe.description,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        cuisineType: recipe.cuisineType,
        mealType: recipe.mealType,
        prepTimeMinutes: recipe.prepTimeMinutes,
        cookTimeMinutes: recipe.cookTimeMinutes,
        difficultyLevel: recipe.difficultyLevel,
        servings: recipe.servings,
        categoryIds: recipe.categories.map((cat) => cat.id).toList(),
      );
      
      await provider.createCustomRecipe(createRequest);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe duplicated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating recipe: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.isCustom ? 'Delete Recipe' : 'Remove from Favorites'),
        content: Text(
          recipe.isCustom
              ? 'Are you sure you want to delete "${recipe.name}"? This action cannot be undone.'
              : 'Are you sure you want to remove "${recipe.name}" from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecipe(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(recipe.isCustom ? 'Delete' : 'Remove'),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(BuildContext context) async {
    try {
      final provider = Provider.of<UserRecipeProvider>(context, listen: false);
      
             if (recipe.isCustom) {
         await provider.deleteUserRecipe(recipe.id);
       } else {
         await provider.unfavoriteRecipe(recipe.id);
       }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recipe.isCustom 
                ? 'Recipe deleted successfully' 
                : 'Recipe removed from favorites'),
          ),
        );
      }
      
      onDelete?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 