
import 'package:dio/dio.dart';
import '../models/auth_models.dart';
class AuthService {
  final Dio dio;

  AuthService({required this.dio});

  static const _base = "/api/v1/public";

  Future<Response> login(String input, String password) async {
    final isEmail = input.contains("@");

    final body = {
      "CriteriaType": isEmail ? 1 : 2,
      "CriteriaValue": input,
      "Password": password,
    };

    try {
      print("====================================");
      print("LOGIN START");
      print("URL: ${dio.options.baseUrl}/api/v1/public/username/login");
      print("INPUT: $input");
      print("IS EMAIL: $isEmail");
      print("REQUEST BODY: $body");
      print("HEADERS: ${dio.options.headers}");
      print("====================================");

      final res = await dio.post(
        "/api/v1/public/username/login",
        data: body,
      );

      print("====================================");
      print("LOGIN SUCCESS");
      print("STATUS CODE: ${res.statusCode}");
      print("STATUS MESSAGE: ${res.statusMessage}");
      print("RESPONSE HEADERS: ${res.headers.map}");
      print("RESPONSE DATA:");
      print(res.data);
      print("====================================");

      return res;
    } catch (e) {
      // print("====================================");
      // print("LOGIN ERROR");
      // print("TYPE: ${e.type}");
      // print("MESSAGE: ${e.message}");
      // print("REQUEST URI: ${e.requestOptions.uri}");
      // print("REQUEST METHOD: ${e.requestOptions.method}");
      // print("REQUEST DATA: ${e.requestOptions.data}");
      // print("REQUEST HEADERS: ${e.requestOptions.headers}");
      // print("STATUS: ${e.response?.statusCode}");
      // print("STATUS MESSAGE: ${e.response?.statusMessage}");
      // print("ERROR DATA: ${e.response?.data}");
      // print("====================================");

      throw "LOGIN FAILED";
    }
  }

  Future<Response> register(RegisterRequest request) async {
    try {
      print("========== REGISTER ==========");
      print("URL: $_base/register");
      print("BODY: ${request.toJson()}");

      final res = await dio.post(
        // "http://localhost:8080/api/v1/public/register",
        "/api/v1/public/register",
        data: request.toJson(),
      );

      print("STATUS: ${res.statusCode}");
      print("DATA: ${res.data}");
      print("==============================");

      return res;
    } on DioException catch (e) {
      print("REGISTER ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> verifyOtp(OtpVerifyRequest request) async {
    try {
      print("========== VERIFY OTP ==========");
      print("URL: $_base/verify");
      print("QUERY: ${request.toJson()}");

      final res = await dio.post(
        "$_base/verify",
        queryParameters: request.toJson(), // FIX HERE
      );

      print("STATUS: ${res.statusCode}");
      print("DATA: ${res.data}");
      print("================================");

      return res;
    } on DioException catch (e) {
      print("VERIFY ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    try {
      print("======= FORGOT PASSWORD =======");
      print("URL: $_base/forgot-password");
      print("BODY: ${request.toJson()}");

      final res = await dio.post(
        "$_base/forgot-password",
        data: request.toJson(),
      );

      print("STATUS: ${res.statusCode}");
      print("DATA: ${res.data}");
      print("===============================");

      return res;
    } on DioException catch (e) {
      print("FORGOT PASSWORD ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      rethrow;
    }
  }
  Future<Response> resetPassword(
      ResetPasswordRequest request,
      ) async {
    try {
      print("======== RESET PASSWORD ========");
      print("URL: $_base/reset-password");
      print("BODY: ${request.toJson()}");

      final res = await dio.post(
        "$_base/reset-password",
        data: request.toJson(),
      );

      print("STATUS: ${res.statusCode}");
      print("DATA: ${res.data}");
      print("================================");

      return res;
    } on DioException catch (e) {
      print("RESET PASSWORD ERROR");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> resendOtp(String email) async {
    await dio.post(
      '/api/v1/public/resend',
      queryParameters: {
        'email': email,
      },
    );
  }

}