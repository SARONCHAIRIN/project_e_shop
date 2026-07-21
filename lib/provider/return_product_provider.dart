import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/returnProduct/return_product_service.dart';
import '../data/repositories/returnProduct/return_product_repo.dart';


final returnDioProvider = Provider<Dio>((ref) {

  return Dio(
    BaseOptions(
      baseUrl:
      "https://e-shop-1-m034.onrender.com/api/v1",

      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  );

});


final returnServiceProvider = Provider<ReturnService>((ref) {

  final dio = ref.read(returnDioProvider);

  return ReturnService(dio);

});


final returnRepositoryProvider = Provider<ReturnRepository>((ref) {

  final service = ref.read(returnServiceProvider);

  return ReturnRepository(service);

});