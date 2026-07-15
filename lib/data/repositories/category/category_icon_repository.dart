import '../../datasources/category /category_icon_service.dart';
import '../../models/category /category_icon_model.dart';

class CategoryIconRepository {
  final CategoryIconService service;

  CategoryIconRepository({
    required this.service,
  });


  Future<List<CategoryIcon>> getCategoryIcons() async {
    try {
      final response = await service.getCategoryIcons();

      final List<dynamic> data = response.data;

      return data.map((item) {
        return CategoryIconResponse
            .fromJson(item)
            .category;
      }).toList();

    } catch (e) {
      throw Exception(
        "Failed to load category icons: $e",
      );
    }
  }
}