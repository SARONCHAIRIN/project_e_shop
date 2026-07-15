import 'package:e_shop/Presentation/screen/category_main_page/see_all_category.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/icon_sub_with_product/icon_sub_with_product.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/category%20/category_model.dart';
import 'package:e_shop/provider/category_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../data/models/category /category_icon_model.dart';
import '../../../data/models/user_model.dart';

class HomeMainPage extends ConsumerStatefulWidget {
  final UserModel? user;
  final authRepository;

  // final bool showBars;

  const HomeMainPage({
    super.key,
    this.user,
    required this.authRepository,

    // required this.showBars,
  });

  @override
  ConsumerState<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends ConsumerState<HomeMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;
  bool _isAnimationLoaded = false;
  bool _isloading = true;


  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  bool isLoadingCategory = true;

  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCategories();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showBars) setState(() => showBars = false);
        // if(showTextField ) setState(() => showTextField = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showBars) setState(() => showBars = true);
        // if(!showTextField) setState(() => showTextField = true);
      }
    });

    //Home page show in console
    print('|=================================================|');
    print('|             HomeMainPage  loaded                |');
    print('|=================================================|');
  }

  Future<void> _loadUserData() async {
    final id = await TokenStorage().readUserId();

    print('userId in home page :  ${id}');

    if (!mounted) return;

    setState(() {
      userId = id;
    });
  }

  Future<void> _loadCategories() async {
    try {
      debugPrint("================================");
      debugPrint("Start loading categories...");

      final result = await ref
          .read(categoryRepositoryProvider)
          .getCategories();

      debugPrint("Category count from API: ${result.length}");

      for (var item in result) {
        debugPrint(
          "Category => id:${item.id}, name:${item.name}, icon:${item.icon}",
        );
      }

      if (!mounted) return;

      setState(() {
        categories = result;

        // Default = All
        selectedCategory = null;

        debugPrint("Selected Category: ALL");

        isLoadingCategory = false;
      });

      debugPrint("===============================");
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
    return Stack(
      children: [
        Scaffold(
          extendBody: false,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            // physics: PageScrollPhysics(),
            physics: ClampingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              // Your app bar - will scroll away
              SliverMainAppBar(
                showBars: showBars,
                authRepository: widget.authRepository,
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 10),

                    SizedBox(height: 4),

                    //carousel slider of home page
                    // HomeCarouselSlider(),
                    // const SizedBox(height: 20,),

                    //Trending Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      //text category see all
                      child: Row(
                        children: [
                          Text(
                            'Trending Categories',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Expanded(child: SizedBox(width: 1)),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeeAllCategory(
                                    repository: widget.authRepository,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              IconSubWithProduct(repository: widget.authRepository),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    //trending categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      //text category see all
                      child: Row(
                        children: [
                          Text(
                            ' Popular Products',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Expanded(child: SizedBox(width: 1)),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeeAllCategory(
                                    repository: widget.authRepository,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    isLoadingCategory
                        ? const Center(
                            child: SpinKitCircle(color: Colors.grey, size: 20),
                          )
                        : DefaultTabController(
                            length: categories.length + 1, // +1 for "All" tab
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

                                  tabs: [
                                    const Tab(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),

                                        child: Text(
                                          "All",

                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    ...categories.map((category) {
                                      return Tab(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              // Category Icon
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.4),
                                                ),
                                                child: Image.network(
                                                  category.icon?? '',
                                                  width: 25,
                                                  height: 25,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Icon(
                                                          Icons.category,
                                                          size: 25,
                                                        );
                                                      },
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              Text(
                                                category.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                                        // All selected
                                        selectedCategory = null;
                                        debugPrint("CATEGORY FILTER ID: ALL");
                                      } else {
                                        selectedCategory =
                                            categories[index - 1];

                                        debugPrint(
                                          "CATEGORY FILTER ID: ${selectedCategory!.id}",
                                        );
                                      }
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                    SizedBox(height: 15),
                  ],
                ),
              ),

              SubcategoryWithProduct(
                // categoryId: selectedCategory?.id,
                categoryName: selectedCategory?.name,
                repository: widget.authRepository,
              ),

              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ],
    );
  }
}
