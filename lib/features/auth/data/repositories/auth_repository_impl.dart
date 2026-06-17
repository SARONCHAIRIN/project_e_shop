import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_service.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenStorage,
  });

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final res = await authService.login(
      request.identifier,
      request.password,
    );

    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);

    return data;
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final Response res = await authService.register(request);
    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);
    return data;
  }

  @override
  Future<AuthResponse> verifyOtp(OtpVerifyRequest request) async {
    final Response res = await authService.verifyOtp(request);
    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);
    return data;
  }

  @override
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    final Response res = await authService.forgotPassword(request);
    return AuthResponse.fromJson(res.data);
  }

  @override
  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    final Response res = await authService.resetPassword(request);
    return AuthResponse.fromJson(res.data);
  }

  @override
  Future<void> resendOtp(String email) async {
    await authService.resendOtp(email);
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearAll(); //  FIXED (your real method)
  }

  // =========================
  // TOKEN SAVING (FIXED)
  // =========================
  Future<void> _saveTokens(AuthResponse response) async {
    final accessToken = response.accessToken;
    final refreshToken = response.refreshToken;

    if (accessToken == null || refreshToken == null) {
      return;
    }

    await tokenStorage.writeToken(accessToken);
    await tokenStorage.writeRefreshToken(refreshToken);
  }
}