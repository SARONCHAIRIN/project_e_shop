import 'package:e_shop/Presentation/screen/home_main_page/tablet/tablet_home.dart';
import 'package:e_shop/Presentation/screen/home_main_page/web/web_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive.dart';
import '../../../data/models/category /category_model.dart';
import '../../../provider/category_provider.dart';
import 'desktop/desktop_home.dart';
import 'home_view_args.dart';
import 'mobile/mobile_home.dart';

class HomeMainPage extends ConsumerStatefulWidget {
  final dynamic authRepository;

  const HomeMainPage({super.key, required this.authRepository});

  @override
  ConsumerState<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends ConsumerState<HomeMainPage> {
  List<CategoryModel> categories = [];

  CategoryModel? selectedCategory;

  bool loading = true;

  bool showBars = true;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ref.read(categoryRepositoryProvider).getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void changeCategory(CategoryModel? value) {
    setState(() {
      selectedCategory = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = HomeViewArgs(
      authRepository: widget.authRepository,

      categories: categories,

      selectedCategory: selectedCategory,

      loading: loading,

      showBars: showBars,

      onCategoryChanged: changeCategory,
    );

    // / ប្រើប្រាស់ Responsive ជំនួសឱ្យ context.screenType
    if (Responsive.isMobile(context)) {
    return MobileHome(args: args);
    } else if (Responsive.isTablet(context)) {
    return TabletHome(args: args);
    } else if (Responsive.width(context) >= 1600) {
    return WebHome(args: args);
    } else {
    return DesktopHome(args: args);
    }
  }
}
