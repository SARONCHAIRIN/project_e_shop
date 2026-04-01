
import '../../entities/sub_category.dart';

abstract class SubCategoryRepository {
  Future<List<SubCategory>> getAllSubCategories();
}