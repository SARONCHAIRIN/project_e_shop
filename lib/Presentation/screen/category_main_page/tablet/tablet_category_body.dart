import 'package:e_shop/Main_App_Bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../data/models/category /category_model.dart';
import '../../../../provider/category_provider.dart';
import '../../sub_category_screen/icon_sub_with_product/iconCategoryPageSubPro.dart';
import '../../sub_category_screen/subcategory_with_product.dart';

class TabletCategoryBody extends ConsumerStatefulWidget {
  final dynamic authRepository;

  const TabletCategoryBody({super.key, required this.authRepository});

  @override
  ConsumerState<TabletCategoryBody> createState() => _TabletCategoryBodyState();
}

class _TabletCategoryBodyState extends ConsumerState<TabletCategoryBody> {
  ScrollController _rightScrollController = ScrollController();
  int selectedIndex = 0; // 0 = "Featured" / All
  List<CategoryModel> categories = [];
  bool isLoadingCategory = true;
  static const double _sidebarWidth = 90;

  String? get _selectedCategoryName =>
      selectedIndex == 0 ? null : categories[selectedIndex - 1].name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _rightScrollController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(top: kToolbarHeight + 50),
            child: _buildSidebar(),
          ),
          Expanded(child: _buildRightPanel()),
        ],
      ),
    );
  }

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

  Widget _buildSidebar() {
    if (isLoadingCategory) {
      return _buildSidebarShimmer();
    }
    return Container(
      width: _sidebarWidth,
      color: const Color(0xFFFDF8F2),
      // Soft cream/peach background matching design
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        itemCount: categories.length + 1, // +1 for "Featured"
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = index == 0 ? 'Featured' : categories[index - 1].name;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  // White rounded container style for the selected tab, matching screenshot cards
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 0) ...[
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.orange.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightPanel() {
    return CustomScrollView(
      controller: _rightScrollController,
      slivers: [
        // 1. App Bar Sliver
        MainAppBar(showBars: true, authRepository: widget.authRepository),

        // 2. Icon Categories Sliver Padding
        const SliverPadding(
          padding: EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              "Brand Icons",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Make sure SubcategoryIconPage returns a Sliver (e.g., SliverGrid)
        SubcategoryIconPage(categoryName: _selectedCategoryName),

        // 3. Products Sliver Padding
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              "Brand & Products",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Make sure SubcategoryWithProduct returns a Sliver
        SubcategoryWithProduct(
          repository: widget.authRepository,
          categoryName: _selectedCategoryName,
        ),
      ],
    );
  }
}
