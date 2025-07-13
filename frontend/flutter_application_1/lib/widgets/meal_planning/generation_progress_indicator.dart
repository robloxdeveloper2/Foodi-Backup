import 'package:flutter/material.dart';

class GenerationProgressIndicator extends StatefulWidget {
  const GenerationProgressIndicator({super.key});

  @override
  State<GenerationProgressIndicator> createState() => _GenerationProgressIndicatorState();
}

class _GenerationProgressIndicatorState extends State<GenerationProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _loadingMessages = [
    'Analyzing your preferences...',
    'Finding recipes that match your diet...',
    'Optimizing nutritional balance...',
    'Calculating costs and portions...',
    'Creating your perfect meal plan...',
  ];

  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    _startMessageRotation();
  }

  void _startMessageRotation() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _startMessageRotation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated cooking icon
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (_fadeAnimation.value * 0.2),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.green[600],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            ),
          ),

          const SizedBox(height: 24),

          // Loading message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingMessages[_currentMessageIndex],
              key: ValueKey(_currentMessageIndex),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'This may take a few moments...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 