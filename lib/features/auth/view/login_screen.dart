import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/auth/view_model/auth_view_model.dart';
import 'package:my_sauda/features/auth/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(authViewModelProvider.notifier);

    final success = await viewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // 🔥 Clear messages after displaying (prevents repetition)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.errorMessage != null ||
          authState.successMessage != null) {
        ref.read(authViewModelProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'My Sauda',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Login with email and password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please verify your email before logging in',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // 📧 Email Field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final email = value.trim();
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // 🔒 Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ❌ Error Message
                  if (authState.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),

                  // 🔘 Login Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submitLogin,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppTheme.white),
                            ),
                          )
                        : const Text('Login'),
                  ),

                  const SizedBox(height: 20),

                  // 🔗 Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .clearMessages();
                          context.go('/register');
                        },
                        child: const Text('Create account'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(authViewModelProvider.notifier)
                              .clearMessages();
                          context.go('/forgot-password');
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}