


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';

/// ==============================
/// AUTH STATE
/// ==============================
class AuthState {
  final bool isLoading;
  final String? error;
  final AuthResponse? data;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    AuthResponse? data,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

/// ==============================
/// AUTH CONTROLLER
/// ==============================
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthController(this.repository) : super(const AuthState());

  // =========================
  // LOGIN
  // =========================
  Future<void> login(LoginRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.login(request);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // REGISTER
  // =========================
  Future<void> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.register(request);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // VERIFY OTP
  // =========================
  Future<void> verifyOtp(OtpVerifyRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.verifyOtp(request);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================
  // Future<void> forgotPassword(ForgotPasswordRequest request) async {
  //   state = state.copyWith(isLoading: true, error: null);
  //
  //   try {
  //     final res = await repository.forgotPassword(request);
  //     state = state.copyWith(isLoading: false, data: res);
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e.toString(),
  //     );
  //   }
  // }


  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.forgotPassword(request);

      if (!mounted) return true; // notifier was disposed mid-flight, skip notify
      state = state.copyWith(isLoading: false, data: res);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }


  // =========================
  // RESET PASSWORD
  // =========================
  Future<void> resetPassword(ResetPasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.resetPassword(request);
      state = state.copyWith(isLoading: false, data: res);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  // =========================
// RESEND OTP
// =========================
  Future<bool> resendOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await repository.resendOtp(email);

      state = state.copyWith(
        isLoading: false,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      return false;
    }
  }



  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await repository.logout();
    state = const AuthState();
  }
}
