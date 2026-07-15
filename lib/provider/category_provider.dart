import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/category /category_service.dart';
import '../data/models/category /category_model.dart';
import '../data/repositories/category/category_repository.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final service = ref.read(categoryServiceProvider);
  return CategoryRepository(service);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getCategories();
});