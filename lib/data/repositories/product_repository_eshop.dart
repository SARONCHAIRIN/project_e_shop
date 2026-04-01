import '../models/product_model_eshop.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';

class ProductRepository {
  final ApiService apiService;

  ProductRepository(this.apiService);

  Future<List<Product>> getProductsBySubcategory(int id) {
    return apiService.fetchProductsBySubcategoryId(id);
  }
}