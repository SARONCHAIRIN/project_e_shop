import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../data/datasources/category /category_icon_service.dart';
import '../data/repositories/category/category_icon_repository.dart';

final dioProvider = Provider<Dio>((ref) {
    return Dio(
      BaseOptions(
        baseUrl: "https://e-shop-1-m034.onrender.com",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),

      ),
    );
  });

final categoryIconServiceProvider = Provider<CategoryIconService>((ref) {
  return CategoryIconService(dio: ref.read(dioProvider));
});

final categoryIconRepositoryProvider = Provider<CategoryIconRepository>((ref) {
  return CategoryIconRepository(service: ref.read(categoryIconServiceProvider));
});
