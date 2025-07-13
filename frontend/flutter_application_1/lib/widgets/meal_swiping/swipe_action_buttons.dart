import 'package:flutter/material.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback? onDislike;
  final VoidCallback? onLike;
  final VoidCallback? onInfo;

  const SwipeActionButtons({
    super.key,
    this.onDislike,
    this.onLike,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dislike button
          _ActionButton(
            icon: Icons.close,
            color: Colors.red,
            size: 56,
            onPressed: onDislike,
          ),
          
          // Info button
          _ActionButton(
            icon: Icons.info_outline,
            color: Colors.blue,
            size: 48,
            onPressed: onInfo,
          ),
          
          // Like button
          _ActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            size: 56,
            onPressed: onLike,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null ? color : Colors.grey[400],
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
} 