import '../entities/sub_category.dart';
import '../repositories/sub_category_repositories/sub_category_repository.dart';

class GetAllSubCategory {
  final SubCategoryRepository repository;

  GetAllSubCategory(this.repository);

  Future<List<SubCategory>> call() {
    return repository.getAllSubCategories();
  }
}