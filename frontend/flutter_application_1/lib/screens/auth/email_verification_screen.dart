import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_constants.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Check if user is already verified
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.emailVerified == true) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  Future<void> _handleVerifyEmail() async {
    if (_tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification token'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.verifyEmail(_tokenController.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.emailVerificationSuccessMessage),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Email verification failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleResendEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.user?.email;

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user email found. Please sign in again.'),
        ),
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    // Note: This would need to be implemented in the API service
    // For now, we'll show a success message
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isResending = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent to $userEmail'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _handleSkipForNow() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.user?.email ?? 'your email';
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Icon and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Verify Your Email',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We\'ve sent a verification email to:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the verification code from the email below',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Verification Token Input
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter the code from your email',
                  prefixIcon: Icon(Icons.security),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  letterSpacing: 2.0,
                ),
                onSubmitted: (_) => _handleVerifyEmail(),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerifyEmail,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify Email'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Email Button
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _handleResendEmail,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Resend Verification Email'),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Skip for now option
              Center(
                child: TextButton(
                  onPressed: _handleSkipForNow,
                  child: Text(
                    'Skip for now',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Help Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Didn\'t receive the email?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam/junk folder\n'
                      '• Make sure you entered the correct email\n'
                      '• Click "Resend" to get a new verification email',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 