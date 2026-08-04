import '../../../data/models/category /category_model.dart';

class HomeViewArgs {
  final dynamic authRepository;

  final List<CategoryModel> categories;

  final CategoryModel? selectedCategory;

  final bool loading;

  final bool showBars;

  final Function(CategoryModel?) onCategoryChanged;

  HomeViewArgs({
    required this.authRepository,

    required this.categories,

    required this.selectedCategory,

    required this.loading,

    required this.showBars,

    required this.onCategoryChanged,
  });
}
