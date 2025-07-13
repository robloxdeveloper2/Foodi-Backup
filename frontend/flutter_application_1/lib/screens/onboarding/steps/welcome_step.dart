import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.largePadding),
              Text(
                'Welcome to Foodi!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Let\'s set up your profile to give you personalized meal recommendations.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding),
              Text(
                'This will only take a few minutes and you can skip any step.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
} 