import 'package:e_shop/Main_App_Bar/web/web_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/models/category /category_model.dart';
import '../../../../provider/category_provider.dart';
import '../../category_main_page/see_all_category.dart';
import '../../sub_category_screen/icon_sub_with_product/icon_sub_with_product.dart';
import '../../sub_category_screen/subcategory_with_product.dart';
import '../home_view_args.dart';

class WebHomeBody extends ConsumerStatefulWidget {
  final HomeViewArgs args;

  const WebHomeBody({super.key, required this.args});

  @override
  ConsumerState<WebHomeBody> createState() => _WebHomeBodyState();
}

class _WebHomeBodyState extends ConsumerState<WebHomeBody> {
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;
  bool isLoadingCategory = true;

  static const _accent = Color(0xFF1E88E5);
  static const _ink = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.args.selectedCategory;
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
      debugPrint("Web Load Category Error: $e");
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() => isLoadingCategory = false);
    }
  }

  Widget _sectionHeader({
    required String title,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: _accent),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _seeAllButton(VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        minimumSize: const Size(0, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "see_all".tr(),
            style: const TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: _accent),
        ],
      ),
    );
  }

  Widget _translate() {
    final isKhmer = context.locale.languageCode == 'km';

    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<Locale>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 48),
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        initialValue: context.locale,
        onSelected: (Locale locale) => context.setLocale(locale),
        itemBuilder: (context) => [
          _languageMenuItem(
            context,
            locale: const Locale('en'),
            flag: '🇬🇧',
            label: 'English',
            isSelected: !isKhmer,
          ),
          _languageMenuItem(
            context,
            locale: const Locale('km'),
            flag: '🇰🇭',
            label: 'ខ្មែរ',
            isSelected: isKhmer,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isKhmer ? '🇰🇭' : '🇬🇧',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                isKhmer ? 'KM' : 'EN',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<Locale> _languageMenuItem(
    BuildContext context, {
    required Locale locale,
    required String flag,
    required String label,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem(
      value: locale,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceVariant.withOpacity(0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.blueGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryShimmer() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 48),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Container(
                  width: 110 + (index * 12).toDouble(),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 48),
        children: [
          _chip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () {
              setState(() {
                selectedCategory = null;
                debugPrint("WEB CATEGORY FILTER ID: ALL");
              });
            },
          ),
          ...categories.map((category) {
            final isSelected = selectedCategory?.id == category.id;
            return Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _chip(
                label: category.name,
                iconUrl: category.icon,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                    debugPrint("WEB CATEGORY FILTER ID: ${category.id}");
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    String? iconUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: iconUrl != null ? 18 : 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _accent : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? _accent : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _accent.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.blue.shade100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: iconUrl.toLowerCase().endsWith('.svg')
                        ? SvgPicture.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) =>
                                const SizedBox.shrink(),
                          )
                        : Image.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.category,
                              size: 14,
                              color: isSelected
                                  ? _accent
                                  : Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: const Color(0xFFF7F8FA),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            WebAppBar(
              showBars: true,
              authRepository: widget.args.authRepository,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'trending_categories'.tr(),
                icon: Icons.local_fire_department_rounded,
                trailing: _translate(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Fixed: IconSubWithProduct returns a sliver/sliver-compatible layout,
            // so we do NOT wrap it in a SliverToBoxAdapter to avoid the crash.
            IconSubWithProduct(repository: widget.args.authRepository),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),
            SliverToBoxAdapter(
              child: _sectionHeader(
                title: 'popular_products'.tr(),
                icon: Icons.trending_up_rounded,
                trailing: _seeAllButton(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllCategory(
                        repository: widget.args.authRepository,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: isLoadingCategory ? _categoryShimmer() : _categoryChips(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // SubcategoryWithProduct is handled safely as a sliver-based view.
            SubcategoryWithProduct(
              repository: widget.args.authRepository,
              categoryName: selectedCategory?.name,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
