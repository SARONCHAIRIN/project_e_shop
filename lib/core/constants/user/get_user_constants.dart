class GetUserConstants {

  static String bastUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  // get user byu id
 static String getUser(int id ) => '$bastUrl/user/$id/user';
}
