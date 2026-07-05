import 'api_endpoints.dart';

class InventoryApi {

  static String create =
      "${ApiEndpoints.base}/api/v1/inventory";

  static String all =
      "${ApiEndpoints.base}/api/v1/inventory/all";

  static String product =
      "${ApiEndpoints.base}/api/v1/inventory/product";

  static String sku =
      "${ApiEndpoints.base}/api/v1/inventory/sku";

  static String lowStock =
      "${ApiEndpoints.base}/api/v1/inventory/low-stock";

  static String restock =
      "${ApiEndpoints.base}/api/v1/inventory/restock";

  static String adjust =
      "${ApiEndpoints.base}/api/v1/inventory/exact";

  static String delete =
      "${ApiEndpoints.base}/api/v1/inventory/delete";
}