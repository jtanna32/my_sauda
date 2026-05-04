import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/auth/view_model/auth_view_model.dart';
import 'package:my_sauda/features/auth/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = ref.read(authViewModelProvider.notifier);
    final success = await viewModel.forgotPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ref.read(authViewModelProvider.notifier).clearMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

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
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email to receive reset instructions',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 24),
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
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submitReset,
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
                        : const Text('Send reset email'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      ref.read(authViewModelProvider.notifier).clearMessages();
                      context.go('/login');
                    },
                    child: const Text('Back to login'),
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
