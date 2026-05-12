import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/product_model_eshop.dart';

class ProductInProductDetail extends StatefulWidget {

  final int subcategoryId;
  final String subcategoryName;

  const ProductInProductDetail({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  State<ProductInProductDetail> createState() =>
      _ProductInProductDetailState();
}

class _ProductInProductDetailState
    extends State<ProductInProductDetail> {

  final ApiService apiService = ApiService();

  ProductSku? selectedSku;

  bool heart = false;

  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Product>>(

      future: apiService.fetchProductsBySubcategoryId(
        widget.subcategoryId,
      ),

      builder: (context, snapshot) {

        /// ================= LOADING =================
        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const SizedBox(
            height: 300,

            child: Center(
              child: SpinKitFadingCircle(
                color: Colors.black,
                size: 40,
              ),
            ),
          );
        }

        /// ================= ERROR =================
        if (snapshot.hasError) {

          return SizedBox(
            height: 350,

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                  ),

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

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        /// ================= EMPTY =================
        if (!snapshot.hasData ||
            snapshot.data!.isEmpty) {

          return SizedBox(
            height: 350,

            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                  ),

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

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Try a different keyword",

                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        /// ================= SUCCESS =================

        final products = snapshot.data!;

        return SizedBox(

          height: 320,

          child: CarouselSlider.builder(

            itemCount: products.length,

            options: CarouselOptions(

              height: 320,

              viewportFraction: 0.50,

              enlargeCenterPage: false,

              enableInfiniteScroll: true,

              autoPlay: true,

              autoPlayInterval:
              const Duration(seconds: 3),

              scrollDirection: Axis.horizontal,
            ),

            itemBuilder:
                (context, index, realIndex) {

              final product = products[index];

              return GestureDetector(

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(

                            product: product,

                            subcategoryId:
                            widget.subcategoryId,

                            subcategoryName:
                            widget.subcategoryName,
                          ),
                    ),
                  );
                },

                child: Container(

                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(15),
                  ),

                  child: Card(

                    color: Colors.white,

                    elevation: 0.5,

                    shadowColor:
                    Colors.grey.shade300,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),

                    child: Padding(

                      padding: const EdgeInsets.only(
                        top: 15,
                        left: 10,
                        right: 10,
                        bottom: 10,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          /// IMAGE
                          Expanded(
                            child: ClipRRect(

                              borderRadius:
                              BorderRadius.circular(10),

                              child: product.mainImage.isEmpty

                                  ? Image.asset(
                                'assets/images/default_image.png',
                                width: double.infinity,
                              )

                                  : Image.network(

                                product.mainImage,


                                width: double.infinity,

                                loadingBuilder:
                                    (
                                    context,
                                    child,
                                    loadingProgress,
                                    ) {

                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return Container(
                                    color:
                                    Colors.grey.shade200,

                                    child: const Center(
                                      child:
                                      CircularProgressIndicator(),
                                    ),
                                  );
                                },

                                errorBuilder:
                                    (
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
                          ),

                          const SizedBox(height: 10),

                          /// PRODUCT NAME
                          Text(

                            product.name,

                            maxLines: 2,

                            overflow:
                            TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// PRICE
                          Text(

                            "\$${product.lowestPrice.toStringAsFixed(2)}",

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}