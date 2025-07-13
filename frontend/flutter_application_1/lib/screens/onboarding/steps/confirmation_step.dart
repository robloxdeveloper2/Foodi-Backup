import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_setup_provider.dart';
import '../../../utils/app_constants.dart';

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({super.key});

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
                Icons.check_circle,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.largePadding),
              Text(
                'Profile Setup Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Your profile has been set up successfully. You can now enjoy personalized meal recommendations!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
} 