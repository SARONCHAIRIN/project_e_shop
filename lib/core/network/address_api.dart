import 'api_endpoints.dart';

class AddressApi {

  static String create =
      "${ApiEndpoints.base}/api/v1/addresses/user";

  static String userAddress =
      "${ApiEndpoints.base}/api/v1/addresses/user";

  static String update =
      "${ApiEndpoints.base}/api/v1/addresses";

  static String delete =
      "${ApiEndpoints.base}/api/v1/addresses";

  static String byId =
      "${ApiEndpoints.base}/api/v1/addresses";
}