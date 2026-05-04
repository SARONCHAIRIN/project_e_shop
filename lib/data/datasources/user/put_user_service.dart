

import 'dart:convert';
import 'package:e_shop/core/constants/user/put_user_constants.dart';
import 'package:e_shop/data/models/user/put_user_model.dart';
import 'package:http/http.dart' as http;
import '../../../core/storage/token_storage.dart';

class PutUserService {
  Future<bool> updateUser(int userId , PutUserModel user) async{

    final token = await TokenStorage().readToken();

    final url = Uri.parse("${UserConstants.BSER_URL}/user/$userId/update",);

    final respose = await http.put(
      url,
      headers: {
        "Content-Type" : "application/json",
        "accept" : "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(user.toJson()),
    );
    print('response body ${respose.body}');
    print('PUT STATUS: ${respose.statusCode}');
    print('PUT BODY: ${respose.body}');
    print('PUT URL: url');
    return respose.statusCode == 200;
  }

}