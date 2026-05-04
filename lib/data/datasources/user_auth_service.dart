import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class AuthService {
  final ApiClient client;
  AuthService(this.client);

  Future<Map<String, dynamic>> login(
      String username,
      String password,
      ) {
    return client.post(ApiConstants.login, {
      'username': username,
      'password': password,
    },);
  }

  //register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async{
    return client.post(ApiConstants.register, {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    });






  }



}