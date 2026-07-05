import 'api_endpoints.dart';

class UserApi {

  static String getAllUsers =
      "${ApiEndpoints.base}/api/v1/user/All";

  static String getUser =
      "${ApiEndpoints.base}/api/v1/user/id/user";

  static String updateUser =
      "${ApiEndpoints.base}/api/v1/user/id/update";

  static String updateImage =
      "${ApiEndpoints.base}/api/v1/user/id/image";

  static String deleteUser =
      "${ApiEndpoints.base}/api/v1/user/id/delete";

  static String countUsers =
      "${ApiEndpoints.base}/api/v1/user/count";
}