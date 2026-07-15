import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../data/models/category /category_model.dart';
import '../../../provider/category_provider.dart';

class CategoryMain extends ConsumerStatefulWidget {
  final authRepository;

  const CategoryMain({super.key, required this.authRepository});

  @override
  ConsumerState<CategoryMain> createState() => _CategoryMainState();
}

class _CategoryMainState extends ConsumerState<CategoryMain> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;
  bool isLoadingCategory = true;

  @override
  void initState() {
    super.initState();
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
    print('|              Category Page Loads                |');
    print('|=================================================|');
  }

  Future<void> _loadCategories() async {
    try {
      final result = await ref.read(categoryRepositoryProvider).getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
        selectedCategory = null; // Default = All
        isLoadingCategory = false;
      });
    } catch (e, stack) {
      debugPrint("Load Category Error: $e");
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() {
        isLoadingCategory = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverMainAppBar(
            showBars: showBars,
            authRepository: widget.authRepository,
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 10),

                isLoadingCategory
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SpinKitCircle(color: Colors.grey, size: 20),
                  ),
                )
                    : DefaultTabController(
                  length: categories.length + 1, // +1 for "All"
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: const Color(0xFF1E88E5),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: const Color(0xFF1E88E5),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                        tabs: [
                          const Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                "All",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          ...categories.map((category) {
                            return Tab(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blueAccent.withOpacity(0.4),
                                      ),
                                      child: Image.network(
                                        category.icon ?? '',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.category, size: 20);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],

                        onTap: (index) {
                          setState(() {
                            if (index == 0) {
                              selectedCategory = null; // All
                            } else {
                              selectedCategory = categories[index - 1];
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                SizedBox(height: 10),
              ],
            ),
          ),

          // Your grid — ឥឡូវប្រើ real category name
          SubcategoryWithProduct(
            categoryName: selectedCategory?.name,
            repository: widget.authRepository,
          ),

          SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}