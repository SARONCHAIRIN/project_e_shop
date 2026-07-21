/*
import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/subcategory_model_eshop.dart';

class SubcategoryWithProduct extends StatefulWidget {
  // final int? categoryId;
  final String? categoryName;
  final User_AuthRepository repository;

  const SubcategoryWithProduct({
    super.key,
    // required this.categoryId,
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
    final id = widget.categoryName;
    if (id != null) {
      _futureSubcategories = apiService.fetchSubcategoriesByCategoryName(
        widget.categoryName ?? 'ALL'
      );
    } else {
      _futureSubcategories = apiService.fetchSubcategories(); // ឬ Future.value([])
    }
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
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 1,
                              blurStyle: BlurStyle.outer,
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
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 1,
                                      color: Colors.grey.shade100,
                                      blurStyle: BlurStyle.outer,
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    height: index % 1 == 0 ? 150 : 150,
                                    width: double.infinity,
                                    child: Image.network(
                                      sub.image,
                                      fit: BoxFit.fill,
                                      errorBuilder: (_, __, ___) {
                                        return Image.asset(
                                          'assets/images/default_image.png',
                                        );
                                      },
                                    ),
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
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// DESCRIPTION
                              Text(
                                sub.description,
                                maxLines: 1,
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
                          // margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
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
                Stack(
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
                    Positioned(
                      top: 10,
                      left: 15,
                      child: Container(
                        height: 25,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 2,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 5,
                          ),
                          width: 20,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
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
*/


import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/subcategory_model_eshop.dart';

class SubcategoryWithProduct extends StatefulWidget {
  final String? categoryName;
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

  static const List<List<Color>> _badgeGradients = [
    [Color(0xFF6C63FF), Color(0xFF4834D4)],
    [Color(0xFFFF6B6B), Color(0xFFEE5253)],
    [Color(0xFF1DD1A1), Color(0xFF10AC84)],
    [Color(0xFFFF9F43), Color(0xFFF97F51)],
    [Color(0xFF54A0FF), Color(0xFF2E86DE)],
    [Color(0xFFEE5A6F), Color(0xFFF368E0)],
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _futureSubcategories = apiService.fetchSubcategories();
  }

  @override
  void didUpdateWidget(SubcategoryWithProduct oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryName != widget.categoryName) {
      _loadData();
      setState(() {});
    }
  }

  void _loadData() {
    final id = widget.categoryName;
    if (id != null) {
      _futureSubcategories =
          apiService.fetchSubcategoriesByCategoryName(widget.categoryName ?? 'ALL');
    } else {
      _futureSubcategories = apiService.fetchSubcategories();
    }
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerPopular();
        } else if (snapshot.hasError) {
          return _buildErrorState();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final subcategories = snapshot.data!;

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 10,
            childCount: subcategories.length,
            itemBuilder: (context, index) {
              final sub = subcategories[index];
              final gradient = _badgeGradients[index % _badgeGradients.length];

              return Padding(
                padding: EdgeInsets.only(top: index.isEven ? 0 : 18),
                child: _SubcategoryCard(
                  sub: sub,
                  gradient: gradient,
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
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
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
              padding: const EdgeInsets.only(left: 70, right: 70, top: 10),
              child: Lottie.asset(
                'assets/animations/Error_404.json',
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Something went wrong",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 4),
            Text(
              "We couldn't load these products",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color(0xFF1E88E5).withOpacity(0.08),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh, size: 18, color: Color(0xFF1E88E5)),
                    SizedBox(width: 6),
                    Text(
                      "Try again",
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 70, right: 70, top: 10),
            child: Lottie.asset(
              'assets/animations/empty.json',
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No products found",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different keyword",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShimmerPopular() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    sliver: SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(top: index.isEven ? 0 : 26),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 13,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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

// ─────────────────────────────────────────────
// Modern subcategory card
// ─────────────────────────────────────────────
class _SubcategoryCard extends StatelessWidget {
  final SubcategoryData sub;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _SubcategoryCard({
    required this.sub,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              blurRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + BADGE
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: Image.network(
                    sub.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // subtle bottom gradient for badge legibility
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.010),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),

                // category badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(colors: gradient),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.last.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      sub.categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // TEXT CONTENT
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: gradient.last,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: gradient.last),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}