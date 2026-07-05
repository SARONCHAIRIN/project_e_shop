import 'api_endpoints.dart';

class BakongApi {

  static String qr =
      "${ApiEndpoints.base}/api/v1/bakong/get-qr-image";

  static String checkTransaction =
      "${ApiEndpoints.base}/api/v1/bakong/check-transaction";
}