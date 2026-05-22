import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/subcategory_model_eshop.dart';

class SubcategoryWithProduct extends StatefulWidget {
  final String categoryName;
  final User_AuthRepository repository;

  const SubcategoryWithProduct({
    super.key,
    required this.categoryName,
    required this.repository,
  });

  @override
  State<SubcategoryWithProduct> createState() => _SubcategoryWithProductState();
}

class _SubcategoryWithProductState extends State<SubcategoryWithProduct> {
  final ApiService apiService = ApiService();
  late Future<List<SubcategoryData>> _futureSubcategories;

  bool ispressed = false;

  @override
  void initState() {
    super.initState();
    _loadData(); // load data for the initial category
    _futureSubcategories = apiService.fetchSubcategories();
  }

  @override
  void didUpdateWidget(SubcategoryWithProduct oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryName != widget.categoryName) {
      _loadData(); // reload when category changes
      setState(() {});
    }
  }

  void _loadData() {
    _futureSubcategories = apiService.fetchSubcategoriesByCategoryName(
      widget.categoryName,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubcategoryData>>(
      future: _futureSubcategories,
      builder: (context, snapshot) {
        // store
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerPopular();
        }
        // error
        else if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,

            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 70,
                      right: 70,
                      top: 10,
                    ),
                    child: Lottie.asset(
                      'assets/animations/Error_404.json',
                      repeat: true,
                      animate: true,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Something went wrong",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  TextButton(
                    onPressed: () {
                      _refresh();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            spreadRadius: 1,
                            blurRadius: 1,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                      child: Text(
                        "Please try again",
                        style: TextStyle(color: Colors.redAccent, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          );
        }
        // no data
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 70, right: 70, top: 10),
                  child: Lottie.asset(
                    'assets/animations/empty.json',
                    repeat: true,
                    animate: true,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "No products found",

                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: 6),

                Text(
                  "Try a different keyword",

                  style: TextStyle(color: Colors.grey),
                ),

                SizedBox(height: 20),
              ],
            ),
          );
        }

        // have data show grid
        final subcategories = snapshot.data!;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childCount: subcategories.length,
            itemBuilder: (context, index) {
              final sub = subcategories[index];

              return Padding(
                padding: EdgeInsets.only(
                  top: index % 2 == 0 ? 0 : 30,
                  bottom: index % 2 == 0 ? 20 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen_sub(
                          subcategoryId: sub.id,
                          repository: widget.repository,
                          subcategoryName: sub.name,
                        ),
                      ),
                    );
                  },

                  child: Stack(
                    children: [
                      ///main contain
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),

                              /// IMAGE
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: index % 1 == 0 ? 130 : 150,
                                  width: double.infinity,
                                  child: Image.network(
                                    sub.image ?? '',
                                    // fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return Image.asset(
                                        'assets/images/default_image.png',
                                        // fit: BoxFit.,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              /// NAME
                              Text(
                                sub.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// DESCRIPTION
                              Text(
                                sub.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),

                      /// CATEGORY
                      Positioned(
                        top: 5,
                        left: 4,

                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue,
                                blurRadius: 1,
                                blurStyle: BlurStyle.outer,
                              ),
                            ],
                          ),
                          child: Text(
                            sub.categoryName,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // return _buildShimmerPopular();
      },
    );
  }

  Widget _buildShimmerPopular() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    sliver: SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            top: index % 2 == 0 ? 0 : 30,
            bottom: index % 2 == 0 ? 20 : 0,
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade50,

                  child: Container(
                    // margin: EdgeInsets.only(bottom: 30),
                    constraints: const BoxConstraints(minHeight: 200),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Container(
                    height: 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),

                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    ),
  );
}
