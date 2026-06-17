import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// ==============================
/// TOKEN MODEL
/// ==============================
@freezed
class TokenModel with _$TokenModel {
  const factory TokenModel({
    required String accessToken,
    required String refreshToken,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);
}

/// ==============================
/// LOGIN REQUEST
/// ==============================
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String identifier,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
/// ==============================
/// REGISTER REQUEST
/// ==============================
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String email,
    required String phone,
    required String password,

  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

/// ==============================
/// OTP VERIFY REQUEST
/// ==============================
@freezed
class OtpVerifyRequest with _$OtpVerifyRequest {
  const factory OtpVerifyRequest({
    required String email,
    required String code,
  }) = _OtpVerifyRequest;

  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);
}

/// ==============================
/// FORGOT PASSWORD REQUEST
/// ==============================
@freezed
class ForgotPasswordRequest with _$ForgotPasswordRequest {
  const factory ForgotPasswordRequest({
    required String email,
  }) = _ForgotPasswordRequest;

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
}

/// ==============================
/// RESET PASSWORD REQUEST
/// ==============================
@freezed
class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String email,
    required String code,
    required String newPassword,

  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}

/// ==============================
/// GENERIC AUTH RESPONSE
/// ==============================
// @freezed
// class AuthResponse with _$AuthResponse {
//   const factory AuthResponse({
//     required String message,
//     TokenModel? tokens,
//     required int userId,
//
//   }) = _AuthResponse;
//
//   factory AuthResponse.fromJson(Map<String, dynamic> json) =>
//       _$AuthResponseFromJson(json);
// }
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'id')
    int? userId,

    @JsonKey(name: 'access_token')
    String? accessToken,

    @JsonKey(name: 'refresh_token')
    String? refreshToken,

    @JsonKey(name: 'token_type')
    String? tokenType,

    String? message,
    String? email,
    String? username,
    String? role,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}