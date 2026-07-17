
import '../../datasources/sub_with_product/sub_product_service.dart';
import '../../models/product_model_eshop.dart';
import '../../models/subcategory_model_eshop.dart';

/// Repository layer for the E-shop feature.
///
/// This sits between the Riverpod providers and [ApiService]. Its job is to:
///  - give the rest of the app a stable, testable contract (an interface
///    that can be mocked in unit tests without hitting the network),
///  - centralize any data-shaping / error-mapping logic that shouldn't
///    live inside the raw API client,
///  - make it trivial to swap or cache the data source later without
///    touching any UI or provider code.
abstract class sub_cate_product_repo {
  Future<List<SubcategoryData>> getSubcategories();

  Future<List<SubcategoryData>> getSubcategoriesByCategoryId(int categoryId);

  Future<List<SubcategoryData>> getSubcategoriesByCategoryName(
      String categoryName,
      );

  Future<List<Product>> getProductsBySubcategoryId(int subcategoryId);
}

class EshopRepositoryImpl implements sub_cate_product_repo {
  EshopRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<List<SubcategoryData>> getSubcategories() async {
    try {
      return await _apiService.fetchSubcategories();
    } catch (e, st) {
      // Rethrow so callers / providers can surface the failure (e.g. via
      // AsyncValue.error), while still logging it here in one place.
      _logError('getSubcategories', e, st);
      rethrow;
    }
  }

  @override
  Future<List<SubcategoryData>> getSubcategoriesByCategoryId(
      int categoryId,
      ) async {
    try {
      return await _apiService.fetchSubcategoriesByCategoryId(categoryId);
    } catch (e, st) {
      _logError('getSubcategoriesByCategoryId', e, st);
      rethrow;
    }
  }

  @override
  Future<List<SubcategoryData>> getSubcategoriesByCategoryName(
      String categoryName,
      ) async {
    try {
      return await _apiService.fetchSubcategoriesByCategoryName(categoryName);
    } catch (e, st) {
      _logError('getSubcategoriesByCategoryName', e, st);
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsBySubcategoryId(int subcategoryId) async {
    try {
      return await _apiService.fetchProductsBySubcategoryId(subcategoryId);
    } catch (e, st) {
      _logError('getProductsBySubcategoryId', e, st);
      rethrow;
    }
  }

  void _logError(String method, Object error, StackTrace st) {
    // ignore: avoid_print
    print('EshopRepository.$method ERROR => $error');
  }
}