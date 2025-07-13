import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_recipe_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String recipeId;
  final bool isFavorited;
  final VoidCallback? onToggle;
  final double size;
  final Color? color;

  const FavoriteButton({
    Key? key,
    required this.recipeId,
    required this.isFavorited,
    this.onToggle,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isProcessing = false;
  late bool _currentFavoriteState;

  @override
  void initState() {
    super.initState();
    _currentFavoriteState = widget.isFavorited;
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_currentFavoriteState) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorited != oldWidget.isFavorited) {
      _currentFavoriteState = widget.isFavorited;
      if (_currentFavoriteState) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<UserRecipeProvider>(context, listen: false);
      
      if (_currentFavoriteState) {
        // Unfavorite the recipe
        await provider.unfavoriteRecipe(widget.recipeId);
        if (mounted) {
          setState(() {
            _currentFavoriteState = false;
          });
          _animationController.reverse();
        }
      } else {
        // Favorite the recipe
        await provider.favoriteRecipe(widget.recipeId);
        if (mounted) {
          setState(() {
            _currentFavoriteState = true;
          });
          _animationController.forward();
        }
      }
      
      // Call optional callback
      widget.onToggle?.call();
      
      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentFavoriteState
                  ? 'Recipe added to favorites!'
                  : 'Recipe removed from favorites',
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Handle error and revert state
      debugPrint('Error updating favorite: $e');
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorite: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Don't change the state on error - keep it as it was
      // The animation should already be in the correct state
    } finally {
      // Always clear the processing state
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isProcessing ? null : _toggleFavorite,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Only show background when processing or during animation
                color: _isProcessing 
                    ? Colors.red.withOpacity(0.2)
                    : (_currentFavoriteState && _animationController.isAnimating)
                        ? Colors.red.withOpacity(0.1)
                        : Colors.transparent,
              ),
              child: _isProcessing
                  ? SizedBox(
                      width: widget.size * 0.7,
                      height: widget.size * 0.7,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.red,
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      _currentFavoriteState ? Icons.favorite : Icons.favorite_border,
                      size: widget.size,
                      color: widget.color ?? 
                          (_currentFavoriteState ? Colors.red : Colors.grey),
                    ),
            ),
          );
        },
      ),
    );
  }
} 