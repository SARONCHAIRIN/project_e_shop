class ApiEndpoints {
  static const String baseUrl = 'https://e-shop-1-m034.onrender.com';

  // Auth endpoints
  static const String login = '/api/v1/public/login';
  static const String register = '/api/v1/public/accounts/register';


  //cart controller
  static String getCart(String userId) =>
      "$baseUrl/api/v1/cart/user/$userId";

  static String getOrCreateCart(String userId) =>
      "$baseUrl/api/v1/cart/user/$userId/get-or-create";

  static String addItem(String userId) =>
      "$baseUrl/api/v1/cart/user/$userId/items";

  static String updateItem(String userId, int cartItemId) =>
      "$baseUrl/api/v1/cart/user/$userId/items/$cartItemId";

  static String deleteItem(String userId, int cartItemId) =>
      "$baseUrl/api/v1/cart/user/$userId/items/$cartItemId";

  static String clearCart(String userId) =>
      "$baseUrl/api/v1/cart/user/$userId/clear";
}