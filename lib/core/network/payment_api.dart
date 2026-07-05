import 'api_endpoints.dart';

class PaymentApi {

  static String all =
      "${ApiEndpoints.base}/api/v1/payments/user/all";

  static String history =
      "${ApiEndpoints.base}/api/v1/payments/user/history";

  static String detail =
      "${ApiEndpoints.base}/api/v1/payments/user/detail";

  static String order =
      "${ApiEndpoints.base}/api/v1/payments/order";

  static String transaction =
      "${ApiEndpoints.base}/api/v1/payments/transaction";
}