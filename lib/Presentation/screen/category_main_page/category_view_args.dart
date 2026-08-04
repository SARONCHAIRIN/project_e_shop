import 'package:e_shop/data/models/category /category_model.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';

class CategoryViewArgs {
  final User_AuthRepository authRepository;

  final List<CategoryModel> categories;

  final int selectedIndex;

  final String? selectedCategoryName;

  final Function(int) onCategorySelected;

  const CategoryViewArgs({
    required this.authRepository,

    required this.categories,

    required this.selectedIndex,

    required this.selectedCategoryName,

    required this.onCategorySelected,
  });
}
