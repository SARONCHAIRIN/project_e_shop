import 'package:dio/dio.dart';

import '../../models/returnProduct/returnProductModel.dart';



class ReturnService {

  final Dio dio;

  ReturnService(this.dio);


  static const String _returnUrl =
      "https://e-shop-1-m034.onrender.com/admin/returns/user"; // absolute — no /api/v1


  Future<Map<String,dynamic>> createReturn({
    required ReturnRequestModel request,
    required String token,
  }) async {

    try {

      final response = await dio.post(
        '/admin/returns/user',
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );


      if(response.statusCode == 200){
        return response.data;
      }

      throw Exception(
          "Return failed ${response.statusCode}"
      );


    } on DioException catch(e){

      throw Exception(
          e.response?.data ?? e.message
      );

    }

  }
  Future<Map<String,dynamic>> requestReturn({

    required Map<String,dynamic> data,
    required String token,

  }) async {

    try {

      final response = await dio.post(
        _returnUrl,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );


      print("STATUS: ${response.statusCode}");
      print("URL: ${response.requestOptions.uri}");
      print("BODY: ${response.requestOptions.data}");
      print("RESPONSE: ${response.data}");


      return response.data;


    } on DioException catch(e){

      print("====================");
      print("DIO ERROR");
      print("URL: ${e.requestOptions.uri}");
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      print("MESSAGE: ${e.message}");
      print("====================");

      throw Exception(
          e.response?.data ?? e.message
      );

    }
  }
}