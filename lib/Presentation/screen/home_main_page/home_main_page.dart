import 'package:e_shop/Presentation/screen/category_main_page/see_all_category.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/icon_sub_with_product/icon_sub_with_product.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/category%20/category_model.dart';
import 'package:e_shop/provider/category_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../data/models/user_model.dart';

class HomeMainPage extends ConsumerStatefulWidget {
  final UserModel? user;
  final authRepository;

  const HomeMainPage({super.key, this.user, required this.authRepository});

  @override
  ConsumerState<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends ConsumerState<HomeMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;
  bool isLoadingCategory = true;
  int? userId;

  static const _accent = Color(0xFF1E88E5);
  static const _ink = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCategories();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showBars) setState(() => showBars = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showBars) setState(() => showBars = true);
      }
    });

    print('|=================================================|');
    print('|             HomeMainPage  loaded                |');
    print('|=================================================|');
  }

  Future<void> _loadUserData() async {
    final id = await TokenStorage().readUserId();
    print('userId in home page :  ${id}');
    if (!mounted) return;
    setState(() => userId = id);
  }

  Future<void> _loadCategories() async {
    try {
      debugPrint("================================");
      debugPrint("Start loading categories...");

      final result = await ref.read(categoryRepositoryProvider).getCategories();

      debugPrint("Category count from API: ${result.length}");
      for (var item in result) {
        debugPrint(
          "Category => id:${item.id}, name:${item.name}, icon:${item.icon}",
        );
      }

      if (!mounted) return;

      setState(() {
        categories = result;
        selectedCategory = null;
        debugPrint("Selected Category: ALL");
        isLoadingCategory = false;
      });

      debugPrint("===============================");
    } catch (e, stack) {
      debugPrint("Load Category Error: $e");
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() => isLoadingCategory = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Section header (icon + title + optional trailing action) ──
  Widget _sectionHeader({
    required String title,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: _accent),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:  [
          Text(
            "see_all".tr(),
            style: TextStyle(
              color: _accent,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right, size: 15, color: _accent),
        ],
      ),
    );
  }

  //=====translate khmer <=> english
  Widget _translate() {
    final isKhmer = context.locale.languageCode == 'km';

    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<Locale>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 44),
        elevation: 1,
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
          _languageMenuItem(context,
              locale: const Locale('en'), flag: '🇬🇧', label: 'English', isSelected: !isKhmer),
          _languageMenuItem(context,
              locale: const Locale('km'), flag: '🇰🇭', label: 'ខ្មែរ', isSelected: isKhmer),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isKhmer ? '🇰🇭' : '🇬🇧', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                isKhmer ? 'KM' : 'EN',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        width: 160,
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
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: Colors.blueGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  //========shimmer for category chips
  Widget _categoryShimmer() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Container(
                  width: 70 + (index * 14).toDouble(),
                  height: 42,
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

  // ── Modern pill-style category selector ──
  Widget _categoryChips() {
    return DefaultTabController(
      length: categories.length + 1,
      child: SizedBox(
        height: 42,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _chip(
              label: 'All',
              isSelected: selectedCategory == null,
              onTap: () {
                setState(() {
                  selectedCategory = null;
                  debugPrint("CATEGORY FILTER ID: ALL");
                });
              },
            ),
            ...categories.map((category) {
              final isSelected = selectedCategory?.id == category.id;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _chip(
                  label: category.name,
                  iconUrl: category.icon,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      debugPrint("CATEGORY FILTER ID: ${category.id}");
                    });
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    String? iconUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: iconUrl != null ? 10 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? _accent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _accent.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl != null) ...[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withOpacity(1)
                      : Colors.blue.shade300,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox.shrink();
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.category,
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6F8),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverMainAppBar(
            showBars: showBars,
            authRepository: widget.authRepository,
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 14),
                _sectionHeader(
                  title: 'trending_categories'.tr(),
                  icon: Icons.local_fire_department_rounded,
                  trailing: _translate(),
                ),
                const SizedBox(height: 10),

              ],
            ),
          ),

          IconSubWithProduct(repository: widget.authRepository),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 22),
                _sectionHeader(
                  title: 'popular_products'.tr(),
                  icon: Icons.trending_up_rounded,
                  trailing: _seeAllButton(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeeAllCategory(repository: widget.authRepository),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                isLoadingCategory ? _categoryShimmer() : _categoryChips(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          SubcategoryWithProduct(
            categoryName: selectedCategory?.name,
            repository: widget.authRepository,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
