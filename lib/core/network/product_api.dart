import 'api_endpoints.dart';

class ProductApi {

  static String all =
      "${ApiEndpoints.base}/api/v1/products/get/all";

  static String byId =
      "${ApiEndpoints.base}/api/v1/products/id";

  static String create =
      "${ApiEndpoints.base}/api/v1/products/create";

  static String update =
      "${ApiEndpoints.base}/api/v1/products/update";

  static String delete =
      "${ApiEndpoints.base}/api/v1/products/delete";

  static String search =
      "${ApiEndpoints.base}/api/v1/products/search";

  static String active =
      "${ApiEndpoints.base}/api/v1/products/active";

  static String category =
      "${ApiEndpoints.base}/api/v1/products/category/id";

  static String subCategory =
      "${ApiEndpoints.base}/api/v1/products/subcategory/id";

  static String withSku =
      "${ApiEndpoints.base}/api/v1/products/id/with-skus";

  static String updateStatus =
      "${ApiEndpoints.base}/api/v1/products/id/status";
}