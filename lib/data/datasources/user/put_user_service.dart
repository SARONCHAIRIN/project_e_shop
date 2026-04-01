

import 'dart:convert';

import 'package:e_shop/core/constants/user/put_user_constants.dart';
import 'package:e_shop/data/models/user/put_user_model.dart';
import 'package:http/http.dart' as http;

class PutUserService {
  Future<bool> updateUser(int userId , PutUserModel user) async{

    final url = Uri.parse("${UserConstants.BSER_URL}/user/$userId/update",);

    final respose = await http.put(
      url,
      headers: {
        "Content-Type" : "application/json",
        "accept" : "application/json",
      },
      body: jsonEncode(user.toJson()),
    );
    print('response body ${respose.body}');
    return respose.statusCode == 200;
  }

}