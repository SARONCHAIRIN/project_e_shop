
import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);

  Future<AuthResponse> verifyOtp(OtpVerifyRequest request);

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request);

  Future<AuthResponse> resetPassword(ResetPasswordRequest request);

  Future<void> resendOtp(String email);

  Future<void> logout();
}