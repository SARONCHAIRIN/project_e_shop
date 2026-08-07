import 'package:e_shop/Main_App_Bar/app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../data/models/category /category_model.dart';
import '../../../../provider/category_provider.dart';
import '../../sub_category_screen/icon_sub_with_product/iconCategoryPageSubPro.dart';

import '../../sub_category_screen/subcategory_with_product.dart';

class MobileCategoryBody extends ConsumerStatefulWidget {
  final dynamic authRepository;

  const MobileCategoryBody({super.key, required this.authRepository});

  @override
  ConsumerState<MobileCategoryBody> createState() => _MobileCategoryBodyState();
}

class _MobileCategoryBodyState extends ConsumerState<MobileCategoryBody> {
  ScrollController _rightScrollController = ScrollController();
  int selectedIndex = 0; // 0 = "Featured" / All
  List<CategoryModel> categories = [];
  bool isLoadingCategory = true;
  static const double _sidebarWidth = 90;

  String? get _selectedCategoryName =>
      selectedIndex == 0 ? null : categories[selectedIndex - 1].name;

  @override
  void initState() {
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
      body: Column(
        children: [
          // Full-width app bar on top
          CustomScrollView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              MainAppBar(showBars: true, authRepository: widget.authRepository),
            ],
          ),

          // Sidebar + content below the app bar
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(),
                Expanded(child: _buildRightPanel()),
              ],
            ),
          ),
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

  Widget _buildRightPanel() {
    return CustomScrollView(
      controller: _rightScrollController,
      slivers: [
        // MainAppBar(showBars: true, authRepository: widget.authRepository),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        SliverPadding(
          padding: EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              "brandIcons".tr(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Subcategory icons
        SubcategoryIconPage(categoryName: _selectedCategoryName),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
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

  Widget _mainAppBar() {
    return MainAppBar(showBars: true, authRepository: widget.authRepository);
  }
}
