


import 'package:dio/dio.dart';
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


  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            'Request failed';
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout';
        case DioExceptionType.receiveTimeout:
          return 'Server timeout';
        case DioExceptionType.connectionError:
          return 'No internet connection';
        default:
          return 'Request failed';
      }
    }

    return 'Something went wrong';
  }
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
        error: _getErrorMessage(e),
      );
    }
  }

  // =========================
  // REGISTER
  // =========================

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await repository.register(request);

      state = state.copyWith(
        isLoading: false,
        data: res,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );

      return false;
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
        error: _getErrorMessage(e,)
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
        error: _getErrorMessage(e),
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
        error: _getErrorMessage(e,)
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
