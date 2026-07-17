import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../data/datasources/product_service_eshop.dart';
import '../../../data/models/product_model_eshop.dart';
import '../../../data/repositories/user_auth_repository.dart';
import '../sub_category_screen/product_detail_screen_eshop.dart';

class ProductScreenAll extends StatelessWidget {
  final String? categoryName;
  final User_AuthRepository repository;

  const ProductScreenAll({
    super.key,
    this.categoryName,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();

    return FutureBuilder<List<Product>>(
      future: productService.fetchAll_Products(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: SpinKitCircle(color: Colors.blueAccent, size: 20),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No products found")),
          );
        }

        final products = snapshot.data!;

        return SliverPadding(
          padding: const EdgeInsets.all(12),

          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,

              crossAxisSpacing: 8,

              mainAxisSpacing: 8,

              childAspectRatio: .65,
            ),

            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: product,
                        subcategoryId: 0,
                        subcategoryName: categoryName ?? "",
                        repository: repository,
                      ),
                    ),
                  );
                },

                child: Card(
                  elevation: 1,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      SizedBox(height: 5,),
                      Expanded(
                        child: product.mainImage.isNotEmpty
                            ? Image.network(
                                product.mainImage.first,
                                width: double.infinity,
                              )
                            : Image.asset(
                                "assets/images/default_image.png",
                                fit: BoxFit.cover,
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              product.name,

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "\$${product.lowestPrice.toStringAsFixed(2)}",

                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: products.length),
          ),
        );
      },
    );
  }
}
