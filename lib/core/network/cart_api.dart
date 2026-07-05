import 'api_endpoints.dart';

class CartApi {

  static String getCart =
      "${ApiEndpoints.base}/api/v1/cart/user/id";

  static String getOrCreate =
      "${ApiEndpoints.base}/api/v1/cart/user/id/get-or-create";

  static String addItem =
      "${ApiEndpoints.base}/api/v1/cart/user/id/items";

  static String updateItem =
      "${ApiEndpoints.base}/api/v1/cart/user/id/items/cartItemId";

  static String deleteItem =
      "${ApiEndpoints.base}/api/v1/cart/user/userId/items/cartItemId";

  static String clear =
      "${ApiEndpoints.base}/api/v1/cart/user/userId/clear";
}