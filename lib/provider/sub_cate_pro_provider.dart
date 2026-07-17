import 'package:e_shop/data/repositories/sub_category%20/sub_category_to_prodcut_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/sub_with_product/sub_product_service.dart';
import '../data/models/product_model_eshop.dart';
import '../data/models/subcategory_model_eshop.dart';

// ==========================================
// 1. Low-level dependencies
// ==========================================

/// Single shared instance of the raw HTTP client wrapper.
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Repository built on top of [ApiService]. Depend on this (not on
/// [apiServiceProvider]) from anywhere that needs eshop data.
final eshopRepositoryProvider = Provider<sub_cate_product_repo>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EshopRepositoryImpl(apiService);
});

// ==========================================
// 2. Subcategories
// ==========================================

/// All subcategories, unfiltered.
final subcategoriesProvider = FutureProvider<List<SubcategoryData>>((
    ref,
    ) async {
  final repo = ref.watch(eshopRepositoryProvider);
  return repo.getSubcategories();
});

/// Subcategories filtered by category id (server-side filter).
final subcategoriesByCategoryIdProvider = FutureProvider.family<
    List<SubcategoryData>, int>((ref, categoryId) async {
  final repo = ref.watch(eshopRepositoryProvider);
  return repo.getSubcategoriesByCategoryId(categoryId);
});

/// Subcategories filtered by category name (client-side filter).
final subcategoriesByCategoryNameProvider = FutureProvider.family<
    List<SubcategoryData>, String>((ref, categoryName) async {
  final repo = ref.watch(eshopRepositoryProvider);
  return repo.getSubcategoriesByCategoryName(categoryName);
});

// ==========================================
// 3. Products
// ==========================================

/// Products that belong to a given subcategory id.
final productsBySubcategoryProvider = FutureProvider.family<List<Product>,
    int>((ref, subcategoryId) async {
  final repo = ref.watch(eshopRepositoryProvider);
  return repo.getProductsBySubcategoryId(subcategoryId);
});

// ==========================================
// 4. UI-facing selection state
// ==========================================

/// Currently selected subcategory id, used to drive
/// [productsBySubcategoryProvider] from a UI widget (e.g. a tab bar or
/// dropdown). Defaults to null (nothing selected yet).
final selectedSubcategoryIdProvider = StateProvider<int?>((ref) => null);

/// Products for whichever subcategory is currently selected.
/// Returns an empty list (not loading/error) when nothing is selected yet.
final selectedSubcategoryProductsProvider = FutureProvider<List<Product>>((
    ref,
    ) async {
  final subcategoryId = ref.watch(selectedSubcategoryIdProvider);
  if (subcategoryId == null) return <Product>[];
  final repo = ref.watch(eshopRepositoryProvider);
  return repo.getProductsBySubcategoryId(subcategoryId);
});