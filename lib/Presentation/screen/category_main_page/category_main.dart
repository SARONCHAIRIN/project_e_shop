import 'package:e_shop/Presentation/screen/sub_category_screen/icon_sub_with_product/iconCategoryPageSubPro.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../data/models/category /category_model.dart';
import '../../../provider/category_provider.dart';

/// Two-pane category screen:
///  - LEFT  : vertical list of parent/top-level categories (Featured, Beauty & Health, ...)
///  - RIGHT : scrollable panel with sub-category circles for the selected
///            parent category, followed by the product grid.
///
/// NOTE: This assumes `CategoryModel` can represent both parent categories
/// (the left list) and sub-categories (the circles). If your API returns
/// sub-categories nested inside a parent (e.g. `category.subCategories`),
/// swap the `_subCategoriesFor()` helper below to read that field instead
/// of re-using the flat `categories` list.
class CategoryMain extends ConsumerStatefulWidget {
  final authRepository;

  const CategoryMain({super.key, required this.authRepository});

  @override
  ConsumerState<CategoryMain> createState() => _CategoryMainState();
}

class _CategoryMainState extends ConsumerState<CategoryMain> {
  final ScrollController _rightScrollController = ScrollController();

  List<CategoryModel> categories = [];
  int selectedIndex = 0; // 0 = "Featured" / All
  bool isLoadingCategory = true;

  static const double _sidebarWidth = 90;

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
        isLoadingCategory = false;
      });
    } catch (e, stack) {
      debugPrint("Load Category Error: $e");
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() => isLoadingCategory = false);
    }
  }

  @override
  void dispose() {
    _rightScrollController.dispose();
    super.dispose();
  }

  /// Sub-categories shown as circles for whichever parent is selected.
  /// Replace this with real nested data once available
  /// (e.g. `categories[selectedIndex - 1].subCategories`).

  String? get _selectedCategoryName =>
      selectedIndex == 0 ? null : categories[selectedIndex - 1].name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey.shade50,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar sits below the app bar, so pad it down manually
          // to roughly match the app bar's height.
          Padding(
            padding: EdgeInsets.only(top: kToolbarHeight + 50),
            child: _buildSidebar(),
          ),
          Expanded(child: _buildRightPanel()),
        ],
      ),
    );
  }

  //left shimmer
  Widget _buildSidebarShimmer() {
    return Container(
      width: _sidebarWidth,
      color: const Color(0xFFFFF3E6),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 15),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// LEFT column — parent category list.
  Widget _buildSidebar() {
    if (isLoadingCategory) {
      return _buildSidebarShimmer();
    }
    return Container(
      width: _sidebarWidth,
      color: const Color(0xFFFFF3E6), // light peach background like screenshot
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 15),
        itemCount: categories.length + 1, // +1 for "Featured"
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = index == 0 ? 'Featured' : categories[index - 1].name;

          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              width: double.infinity,
              color: isSelected ? Colors.white : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Column(
                children: [
                  if (isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? Colors.orange : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// RIGHT column — sub-category circles (grid) + products.
  Widget _buildRightPanel() {
    return CustomScrollView(
      controller: _rightScrollController,
      slivers: [
        SliverMainAppBar(showBars: true, authRepository: widget.authRepository),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Subcategory icons
        SubcategoryIconPage(categoryName: _selectedCategoryName),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12),
            child:  Text(
              'products'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Product list
        SubcategoryWithProduct(
          categoryName: _selectedCategoryName,
          repository: widget.authRepository,
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

