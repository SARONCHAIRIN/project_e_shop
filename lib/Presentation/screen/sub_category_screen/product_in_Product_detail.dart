import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/product_model_eshop.dart';

/// Breakpoint-driven sizing so the carousel shows a sensible number of
/// cards per view on every platform instead of a fixed 0.50 viewport
/// fraction (which looks fine on a phone but leaves huge gaps on desktop).
class _Responsive {
  final double height;
  final double viewportFraction;
  final double titleFontSize;
  final double priceFontSize;

  const _Responsive({
    required this.height,
    required this.viewportFraction,
    required this.titleFontSize,
    required this.priceFontSize,
  });

  factory _Responsive.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) {
      // mobile — ~2 cards visible
      return const _Responsive(
        height: 320,
        viewportFraction: 0.50,
        titleFontSize: 14,
        priceFontSize: 16,
      );
    } else if (width < 1024) {
      // tablet — ~3 cards visible
      return const _Responsive(
        height: 340,
        viewportFraction: 0.32,
        titleFontSize: 15,
        priceFontSize: 17,
      );
    } else if (width < 1440) {
      // desktop — ~4-5 cards visible
      return const _Responsive(
        height: 360,
        viewportFraction: 0.22,
        titleFontSize: 15,
        priceFontSize: 17,
      );
    } else {
      // wide / web — ~6 cards visible
      return const _Responsive(
        height: 380,
        viewportFraction: 0.16,
        titleFontSize: 16,
        priceFontSize: 18,
      );
    }
  }
}

class ProductInProductDetail extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;
  final User_AuthRepository repository;

  const ProductInProductDetail({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.repository,
  });

  @override
  State<ProductInProductDetail> createState() =>
      _ProductInProductDetailState();
}

class _ProductInProductDetailState extends State<ProductInProductDetail> {
  final ApiService apiService = ApiService();
  late final Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // fetch once — the original called this inside build(), which re-fired
    // the network request on every rebuild (e.g. every setState upstream).
    _productsFuture = apiService.fetchProductsBySubcategoryId(
      widget.subcategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _Responsive.of(context);

    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        /// ================= LOADING =================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerCarousel(sizes);
        }

        /// ================= ERROR =================
        if (snapshot.hasError) {
          return SizedBox(
            height: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Lottie.asset(
                    'assets/animations/Error_404.json',
                    repeat: true,
                    animate: true,
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Something went wrong",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        /// ================= EMPTY =================
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Lottie.asset(
                    'assets/animations/empty.json',
                    repeat: true,
                    animate: true,
                    height: 140,
                    width: 140,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "No products found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Try a different keyword",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        /// ================= SUCCESS =================
        final products = snapshot.data!;

        return SizedBox(
          height: sizes.height,
          child: CarouselSlider.builder(
            itemCount: products.length,
            options: CarouselOptions(
              height: sizes.height,
              viewportFraction: sizes.viewportFraction,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              autoPlay: true,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              autoPlayInterval: const Duration(seconds: 3),
              scrollDirection: Axis.horizontal,
            ),
            itemBuilder: (context, index, realIndex) {
              final product = products[index];
              return _RelatedProductCard(
                product: product,
                sizes: sizes,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: product,
                        subcategoryId: widget.subcategoryId,
                        subcategoryName: widget.subcategoryName,
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerCarousel(_Responsive sizes) {
    return SizedBox(
      height: sizes.height,
      child: CarouselSlider.builder(
        itemCount: 6,
        options: CarouselOptions(
          height: sizes.height,
          viewportFraction: sizes.viewportFraction,
          enlargeCenterPage: false,
          enableInfiniteScroll: false,
          autoPlay: false,
          scrollDirection: Axis.horizontal,
        ),
        itemBuilder: (context, index, realIndex) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: sizes.titleFontSize,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: sizes.priceFontSize,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
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
}

/// Modern card: flat white surface + soft shadow instead of the Material
/// Card's elevation/shadowColor combo, cover-fit image, clean price color.
class _RelatedProductCard extends StatelessWidget {
  final Product product;
  final _Responsive sizes;
  final VoidCallback onTap;

  const _RelatedProductCard({
    required this.product,
    required this.sizes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.mainImage.isEmpty
                      ? Image.asset(
                    'assets/images/default_image.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    product.mainImage.isNotEmpty
                        ? product.mainImage.first
                        : "",
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_image.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// PRODUCT NAME
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: sizes.titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),

              /// PRICE
              Text(
                "\$${product.lowestPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: sizes.priceFontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1FAA59),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}