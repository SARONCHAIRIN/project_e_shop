import 'package:dio/dio.dart';

import '../../models/returnProduct/returnProductModel.dart';

class ReturnService {

  final Dio dio;

  ReturnService(this.dio);


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


    final response = await dio.post(

      '/admin/returns/user',

      data: data,

      options: Options(

        headers: {

          "Authorization": "Bearer $token",

          "Content-Type": "application/json",

        },

      ),

    );


    return response.data;

  }

}