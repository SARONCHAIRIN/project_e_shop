class ApiConstants {

  static const String BASE_URL =
      "https://e-shop-1-m034.onrender.com/api/v1";

  //  Auth
  static const String login =
      "$BASE_URL/public/login";
//register
  static const String register =
      "$BASE_URL/public/accounts/register";

  // User
  static const String user =
      "$BASE_URL/user";

  //  SubCategory
  static const String subcategoriesAll =
      "$BASE_URL/subcategories/All";

  // Cart
  static const String addToCart = "$BASE_URL/cart/user";   // POST /cart/user/{id}/items

// Product
  static const String products = "$BASE_URL/products";

  //cart
  static const String cartByUser = "$BASE_URL/cart/user";

  //search product
static const String searchProduct = "$BASE_URL/products/search?keyword";



}
