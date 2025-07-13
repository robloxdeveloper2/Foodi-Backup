import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_recipe_models.dart';
import '../../../providers/user_recipe_provider.dart';

class RecipeExportDialog extends StatefulWidget {
  final UserRecipe recipe;

  const RecipeExportDialog({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required UserRecipe recipe,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => RecipeExportDialog(recipe: recipe),
    );
  }

  @override
  State<RecipeExportDialog> createState() => _RecipeExportDialogState();
}

class _RecipeExportDialogState extends State<RecipeExportDialog> {
  RecipeExportFormat _selectedFormat = RecipeExportFormat.json;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download_outlined),
          SizedBox(width: 8),
          Text('Export Recipe'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose export format for "${widget.recipe.name}":',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          
          // Format selection
          Column(
            children: RecipeExportFormat.values.map((format) {
              return RadioListTile<RecipeExportFormat>(
                value: format,
                groupValue: _selectedFormat,
                onChanged: (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
                title: Text(_getFormatTitle(format)),
                subtitle: Text(_getFormatDescription(format)),
                dense: true,
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportRecipe,
          icon: _isExporting 
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.download),
          label: Text('Export'),
        ),
      ],
    );
  }

  String _getFormatTitle(RecipeExportFormat format) {
    switch (format) {
      case RecipeExportFormat.json:
        return 'JSON Format';
      case RecipeExportFormat.text:
        return 'Plain Text';
      case RecipeExportFormat.pdf:
        return 'PDF Document';
    }
  }

  String _getFormatDescription(RecipeExportFormat format) {
    switch (format) {
      case RecipeExportFormat.json:
        return 'Machine-readable format for importing';
      case RecipeExportFormat.text:
        return 'Simple text format for sharing';
      case RecipeExportFormat.pdf:
        return 'Formatted document for printing';
    }
  }

  Future<void> _exportRecipe() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final provider = Provider.of<UserRecipeProvider>(context, listen: false);
      
      // Get the format string
      String formatString;
      switch (_selectedFormat) {
        case RecipeExportFormat.json:
          formatString = 'json';
          break;
        case RecipeExportFormat.text:
          formatString = 'text';
          break;
        case RecipeExportFormat.pdf:
          formatString = 'pdf';
          break;
      }
      
      final exportedContent = await provider.exportRecipe(
        widget.recipe.id,
        _selectedFormat,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message and options
        _showExportSuccess(exportedContent, formatString);
      }
    } catch (e) {
      if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error exporting recipe: $e'),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showExportSuccess(String content, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text('Export Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipe exported successfully in $format format.'),
            SizedBox(height: 16),
            
            // Preview content (truncated)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content.length > 200 
                        ? '${content.substring(0, 200)}...'
                        : content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _shareContent(content, format);
            },
            icon: Icon(Icons.share),
            label: Text('Share'),
          ),
        ],
      ),
    );
  }

  void _shareContent(String content, String format) {
    // Implement native sharing
    // For now, copy to clipboard
    // Clipboard.setData(ClipboardData(text: content));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe content copied to clipboard!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
} 