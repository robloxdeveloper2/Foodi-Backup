import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signInWithApple();

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Apple sign in failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleTestUserLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.createTestUser();

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Test user creation failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo and Welcome
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back!',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your culinary journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!EmailValidator.validate(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Social Login Buttons
              if (AppConstants.enableSocialLogin) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : null,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleAppleSignIn,
                    icon: const Icon(Icons.apple, size: 24),
                    label: const Text('Continue with Apple'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Test User Button (for development)
              if (AppConstants.enableTestUser && !AppConstants.isProduction) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleTestUserLogin,
                    child: const Text('Create Test User (Development)'),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Test Profile Setup Button (TEMPORARY - REMOVE IN PRODUCTION)
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profileSetup);
                  },
                  child: const Text('Test Profile Setup (Debug Only)'),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.register);
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 