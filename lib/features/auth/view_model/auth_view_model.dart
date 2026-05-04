import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(),
);

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel() : super(const AuthState());

  // 🔐 LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await AuthService.instance.login(
        email: email,
        password: password,
      );

      // ✅ Ensure profile exists after login
      await AuthService.instance.ensureProfile();

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Login successful.',
      );

      return true;
    } catch (error) {
      String message = error.toString();

      // 🔥 Handle common Supabase error
      if (message.contains('Email not confirmed')) {
        message = 'Please verify your email before logging in.';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );

      return false;
    }
  }

  // 📝 REGISTER
  Future<bool> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await AuthService.instance.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      state = state.copyWith(
        isLoading: false,
        successMessage:
            'Registration successful. Please verify your email before logging in.',
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }

  // 🔁 FORGOT PASSWORD
  Future<bool> forgotPassword({
    required String email,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await AuthService.instance.resetPassword(email: email);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Reset email sent. Please check your inbox.',
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );

      return false;
    }
  }

  // 🧹 CLEAR STATE
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}