
import 'package:dio/dio.dart';

import '../../../core/storage/token_storage.dart';

class CategoryIconService {
  final Dio dio;

  CategoryIconService({required this.dio});

  Future<Response> getCategoryIcons() async {
    final token = await TokenStorage().getToken();

    return await dio.get(
      "/api/v1/category-icons/get/all",
      options: Options(

        headers: {

          "Authorization": "Bearer $token",

          "Accept": "application/json",

        },

      ),

    );
  }
  Future<Response> getCategoryIconById(int id) async {

    return await dio.get(
      "/api/v1/category-icons/id",
      queryParameters: {
        "id": id,
      },
    );

  }
}