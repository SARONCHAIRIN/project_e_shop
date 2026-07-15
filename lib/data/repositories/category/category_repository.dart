
import '../../datasources/category /category_service.dart';
import '../../models/category /category_model.dart';

class CategoryRepository {
  final CategoryService _service;

  CategoryRepository(this._service);

  Future<List<CategoryModel>> getCategories() {
    return _service.fetchCategories();
  }
}