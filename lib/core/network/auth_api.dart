import 'api_endpoints.dart';

class AuthApi {
  static String register = "${ApiEndpoints.base}/api/v1/public/register";

  static String login =
      "${ApiEndpoints.base}/api/v1/public/email/username/login";

  static String verify =
      "${ApiEndpoints.base}/api/v1/public/verify";

  static String resend =
      "${ApiEndpoints.base}/api/v1/public/resend";

  static String forgotPassword =
      "${ApiEndpoints.base}/api/v1/public/forgot-password";

  static String resetPassword =
      "${ApiEndpoints.base}/api/v1/public/reset-password";

  static String refresh =
      "${ApiEndpoints.base}/api/v1/public/refresh";

  static String logout =
      "${ApiEndpoints.base}/api/v1/public/logout";
}