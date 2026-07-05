class AddressConstants {

  //server
  // static String   BaseUrl = 'https://e-shop-1-m034.onrender.com';

  // ip rupp
  // static String   BaseUrl = 'http://10.1.121.208:8080';

  // local
  static String   BaseUrl = 'http://localhost:8080';

  static String createaddress = '$BaseUrl/api/v1/addresses/user';

  static String getaddressbyuserId = "$BaseUrl/api/v1/addresses/user";

  static String deleteAddress = "$BaseUrl/api/v1/addresses";

  static String updateAddress = "$BaseUrl/api/v1/addresses";
}