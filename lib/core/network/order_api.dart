import 'api_endpoints.dart';

class OrderApi {

  static String create =
      "${ApiEndpoints.base}/api/v1/orders/user/from-cart";

  static String createBakong =
      "${ApiEndpoints.base}/api/v1/orders/user/from-cart/bakong";

  static String history =
      "${ApiEndpoints.base}/api/v1/orders/user/history";

  static String detail =
      "${ApiEndpoints.base}/api/v1/orders/user/detail";

  static String byId =
      "${ApiEndpoints.base}/api/v1/orders/id";

  static String byNumber =
      "${ApiEndpoints.base}/api/v1/orders/number";

  static String cancel =
      "${ApiEndpoints.base}/api/v1/orders/user/cancel";

  static String status =
      "${ApiEndpoints.base}/api/v1/orders/status";

  static String initiateBakong =
      "${ApiEndpoints.base}/api/v1/orders/bakong/initiate";

  static String verifyBakong =
      "${ApiEndpoints.base}/api/v1/orders/bakong/verify";

  static String callback =
      "${ApiEndpoints.base}/api/v1/orders/bakong/callback";
}