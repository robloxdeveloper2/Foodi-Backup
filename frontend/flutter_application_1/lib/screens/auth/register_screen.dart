import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.registrationSuccessMessage),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      // Navigate to email verification or home
      Navigator.pushReplacementNamed(context, AppRoutes.emailVerification);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleAppleSignUp() async {
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
          content: Text(authProvider.error ?? 'Apple sign up failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (!RegExp(AppConstants.usernameRegex).hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
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
              const SizedBox(height: 40),
              
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
                      'Create Account',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join Foodi to start your culinary journey',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // First Name and Last Name Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              hintText: 'John',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              hintText: 'Doe',
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Username
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        hintText: 'johndoe',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: _validateUsername,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'john@example.com',
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
                    
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter a strong password',
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
                      validator: _validatePassword,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleRegister(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account'),
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
              
              // Social Sign Up Buttons
              if (AppConstants.enableSocialLogin) ...[
                SizedBox(
                  width: double.infinity,
                  height: AppConstants.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : null,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: const Text('Sign up with Google'),
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
                    onPressed: _isLoading ? null : _handleAppleSignUp,
                    icon: const Icon(Icons.apple, size: 24),
                    label: const Text('Sign up with Apple'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: const Text('Sign In'),
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