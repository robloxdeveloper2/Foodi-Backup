import 'package:flutter/material.dart';

import '../../models/meal_suggestion.dart';

enum SwipeDirection { left, right, none }

class SwipeableMealCard extends StatefulWidget {
  final MealSuggestion suggestion;
  final bool isBackground;
  final Function(SwipeDirection) onSwipe;
  final VoidCallback onTap;

  const SwipeableMealCard({
    super.key,
    required this.suggestion,
    required this.isBackground,
    required this.onSwipe,
    required this.onTap,
  });

  @override
  State<SwipeableMealCard> createState() => _SwipeableMealCardState();
}

class _SwipeableMealCardState extends State<SwipeableMealCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.isBackground) return;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.isBackground || !_isDragging) return;

    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isBackground || !_isDragging) return;

    _isDragging = false;
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      // Trigger swipe
      final direction = _dragOffset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      _animateSwipe(direction);
    } else {
      // Return to center
      _animateReturn();
    }
  }

  void _animateSwipe(SwipeDirection direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final endOffset = direction == SwipeDirection.right
        ? Offset(screenWidth * 1.5, _dragOffset.dy)
        : Offset(-screenWidth * 1.5, _dragOffset.dy);

    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _getRotation(),
      end: direction == SwipeDirection.right ? 0.3 : -0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward().then((_) {
      widget.onSwipe(direction);
      _resetCard();
    });
  }

  void _animateReturn() {
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _getRotation(),
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward().then((_) {
      _resetCard();
    });
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
    });
    _animationController.reset();
  }

  double _getRotation() {
    const maxRotation = 0.1;
    final screenWidth = MediaQuery.of(context).size.width;
    return (_dragOffset.dx / screenWidth) * maxRotation;
  }

  Color _getOverlayColor() {
    if (_dragOffset.dx > 50) {
      return Colors.green.withOpacity(0.7);
    } else if (_dragOffset.dx < -50) {
      return Colors.red.withOpacity(0.7);
    }
    return Colors.transparent;
  }

  String _getOverlayText() {
    if (_dragOffset.dx > 50) {
      return 'LIKE';
    } else if (_dragOffset.dx < -50) {
      return 'PASS';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final offset = _animationController.isAnimating
            ? _slideAnimation.value
            : _dragOffset;
        final rotation = _animationController.isAnimating
            ? _rotationAnimation.value
            : _getRotation();
        final scale = _animationController.isAnimating
            ? _scaleAnimation.value
            : 1.0;

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: widget.isBackground ? null : widget.onTap,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // Main card
                      Card(
                        elevation: widget.isBackground ? 2 : 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image section
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                  child: widget.suggestion.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                          child: Image.network(
                                            widget.suggestion.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                _buildPlaceholderImage(),
                                          ),
                                        )
                                      : _buildPlaceholderImage(),
                                ),
                              ),
                              
                              // Content section
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        widget.suggestion.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Cuisine and meal type
                                      if (widget.suggestion.cuisineType != null ||
                                          widget.suggestion.mealType != null)
                                        Text(
                                          [
                                            widget.suggestion.cuisineType,
                                            widget.suggestion.mealType,
                                          ].where((e) => e != null).join(' • '),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                      
                                      const Spacer(),
                                      
                                      // Stats row
                                      Row(
                                        children: [
                                          _buildStatChip(
                                            Icons.access_time,
                                            widget.suggestion.displayTime,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatChip(
                                            Icons.local_fire_department,
                                            widget.suggestion.displayCalories,
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatChip(
                                            Icons.attach_money,
                                            widget.suggestion.displayCost,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Swipe overlay
                      if (!widget.isBackground && _getOverlayText().isNotEmpty)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _getOverlayColor(),
                            ),
                            child: Center(
                              child: Text(
                                _getOverlayText(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Colors.green[300]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 