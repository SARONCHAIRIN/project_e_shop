import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../../data/models/subcategory_model_eshop.dart';

/// Central place that turns a screen width into every size this widget needs.
enum DeviceType { mobile, tablet, desktop, wide }

class _ResponsiveSizes {
  final DeviceType type;
  final double maxContentWidth;
  final double carouselHeight;
  final double viewportFraction;
  final double avatarSize;
  final double titleFontSize;
  final double subFontSize;
  final double horizontalMargin;
  final double innerPadding;

  const _ResponsiveSizes({
    required this.type,
    required this.maxContentWidth,
    required this.carouselHeight,
    required this.viewportFraction,
    required this.avatarSize,
    required this.titleFontSize,
    required this.subFontSize,
    required this.horizontalMargin,
    required this.innerPadding,
  });

  factory _ResponsiveSizes.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) {
      // MOBILE (phones)
      return const _ResponsiveSizes(
        type: DeviceType.mobile,
        maxContentWidth: double.infinity,
        carouselHeight: 200,
        viewportFraction: 0.4,
        avatarSize: 80,
        titleFontSize: 20,
        subFontSize: 15,
        horizontalMargin: 12,
        innerPadding: 15,
      );
    } else if (width < 1024) {
      // TABLET
      return const _ResponsiveSizes(
        type: DeviceType.tablet,
        maxContentWidth: 900,
        carouselHeight: 220,
        viewportFraction: 0.22,
        avatarSize: 96,
        titleFontSize: 22,
        subFontSize: 16,
        horizontalMargin: 24,
        innerPadding: 20,
      );
    } else if (width < 1440) {
      // DESKTOP
      return const _ResponsiveSizes(
        type: DeviceType.desktop,
        maxContentWidth: 1200,
        carouselHeight: 240,
        viewportFraction: 0.14,
        avatarSize: 104,
        titleFontSize: 24,
        subFontSize: 17,
        horizontalMargin: 32,
        innerPadding: 24,
      );
    } else {
      // WIDE / large web monitors
      return const _ResponsiveSizes(
        type: DeviceType.wide,
        maxContentWidth: 1440,
        carouselHeight: 260,
        viewportFraction: 0.1,
        avatarSize: 110,
        titleFontSize: 26,
        subFontSize: 18,
        horizontalMargin: 40,
        innerPadding: 28,
      );
    }
  }

  bool get isCompact => type == DeviceType.mobile;
}

class IconSubWithProduct extends StatefulWidget {
  final User_AuthRepository repository;

  const IconSubWithProduct({super.key, required this.repository});

  @override
  State<IconSubWithProduct> createState() => _IconSubWithProductState();
}

class _IconSubWithProductState extends State<IconSubWithProduct> {
  final ApiService apiService = ApiService();
  late Future<List<SubcategoryData>> _futureSubcategories;

  @override
  void initState() {
    super.initState();
    _futureSubcategories = apiService.fetchSubcategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSubcategories = apiService.fetchSubcategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _ResponsiveSizes.of(context);

    return FutureBuilder<List<SubcategoryData>>(
      future: _futureSubcategories,
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildCarouselShimmer(sizes);
        }
        // error
        else if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.isCompact ? 70 : 140,
                  ).copyWith(top: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Lottie.asset(
                      'assets/animations/Error_404.json',
                      repeat: true,
                    ),
                  ),
                ),
                Text(
                  "Something went wrong",
                  style: TextStyle(
                    fontSize: sizes.isCompact ? 16 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: _refresh,
                  child: Container(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      "Please try again",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: sizes.isCompact ? 18 : 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        }
        // empty
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.isCompact ? 70 : 140,
                ).copyWith(top: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Lottie.asset(
                    'assets/animations/empty.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
              ),
            ),
          );
        }

        // data loaded
        final subcategories = snapshot.data!;

        return SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sizes.maxContentWidth),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: sizes.horizontalMargin,
                    ),
                    padding: EdgeInsets.symmetric(vertical: sizes.innerPadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffFF8A00),
                          Color(0xffFF6A00),
                          Color(0xffFF4D6D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/background_product.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'New user exclusive',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizes.titleFontSize,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            children: [
                              Icon(
                                Icons.discount_outlined,
                                size: sizes.subFontSize + 5,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '\$4 off Shipping Discount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sizes.subFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: sizes.avatarSize + 48,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: sizes.carouselHeight,
                              viewportFraction: sizes.viewportFraction,
                              // enlargeCenterPage: true,
                              enlargeStrategy: CenterPageEnlargeStrategy.scale,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                            ),
                            items: subcategories.map((sub) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductScreen_sub(
                                        subcategoryId: sub.id,
                                        subcategoryName: sub.name,
                                        repository: widget.repository,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      color: Colors.transparent,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              height: sizes.avatarSize,
                                              width: sizes.avatarSize * 0.9,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade200,
                                                    blurStyle: BlurStyle.outer,
                                                    blurRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              clipBehavior: Clip.hardEdge,
                                              child: (sub.image?.isEmpty ?? true)
                                                  ? Image.asset(
                                                'assets/images/default_image.png',
                                                fit: BoxFit.cover,
                                              )
                                                  : Image.network(
                                                sub.image!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                    ) {
                                                  return Image.asset(
                                                    'assets/images/default_image.png',
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              sub.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: sizes.subFontSize + 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget buildCarouselShimmer(_ResponsiveSizes sizes) {
  return SliverToBoxAdapter(
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.maxContentWidth),
        child: Container(
          height: sizes.carouselHeight + 50,
          margin: EdgeInsets.symmetric(
            horizontal: sizes.horizontalMargin,
            vertical: 10,
          ),
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  height: 10,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: sizes.avatarSize,
                              height: sizes.avatarSize,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 60,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}