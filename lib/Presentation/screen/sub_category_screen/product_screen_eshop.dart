
/*
import 'package:flutter/material.dart';

import '../../../data/datasources/product_service_eshop.dart';
import '../../../data/models/product_model_eshop.dart';
import '../../../data/models/subcategory_model_eshop.dart';

class ProductsScreen extends StatefulWidget {
  // final SubcategoryData subcategory;

  const ProductsScreen({
    super.key,
    // required this.subcategory,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _productService.fetchAllProducts();
    // If you want to filter by category name:
    // _futureProducts = _productService.fetchProductsByCategory(widget.subcategory.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.subcategory.name),
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      //   elevation: 2,
      // ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureProducts = _productService.fetchAllProducts();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<Product> products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to product detail screen (you can create this later)
                    _showProductDetails(product);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12),
                        ),
                        child: Image.network(
                          alignment: Alignment.center,
                          product.mainImage,
                          width: 200,
                          height: 120,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40),
                            );
                          },
                        ),
                      ),


                      SizedBox(height: 5,),

                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Price
                                Text(
                                  '\$${product.lowestPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),

                                // Stock status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.isActive
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.isActive ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: product.isActive
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (product.skus.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${product.skus.length} variation(s) available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.mainImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                // Product Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // SKUs
                const Text(
                  'Available Options:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: product.skus.length,
                    itemBuilder: (context, index) {
                      final sku = product.skus[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('SKU: ${sku.sku}'),
                          subtitle: Text(sku.description),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${sku.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Qty: ${sku.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/



//new
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
import '../../../data/datasources/product_service_eshop.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/product_model_eshop.dart';

class ProductScreen_sub extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  ProductScreen_sub({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,

  });

  @override
  State<ProductScreen_sub> createState() => _ProductScreen_subState();
}

class _ProductScreen_subState extends State<ProductScreen_sub> {
  final ApiService apiService = ApiService();
  ProductSku? selectedSku;
   bool heart = false;
  final ProductService productService = ProductService(); // Use ProductService only


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            widget.subcategoryName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          )),
      body: FutureBuilder<List<Product>>(
        future: apiService.fetchProductsBySubcategoryId(widget.subcategoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;

          return GridView.builder(

            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.60,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProductDetailScreen(product: product,)));
                },
                child: Stack(
                  children:[


                    Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.lightBlueAccent,
                      //     blurRadius: 3,
                      //     blurStyle: BlurStyle.outer,
                      //     spreadRadius: 0.5,
                      //   ),
                      // ],
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 0.3,
                      shadowColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(

                        padding: const EdgeInsets.only(
                          top: 30,
                          left: 10,
                          right: 2,
                          bottom: 5,

                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: product.mainImage == null || product.mainImage.isEmpty
                                    ? Image.asset(
                                  'assets/images/default_image.png',
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                )
                                    : Image.network(
                                  product.mainImage,
                                  width: double.infinity,
                                  // fit: BoxFit.fill,

                                  //  If network fails
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_image.png',
                                      fit: BoxFit.cover,
                                    );
                                  },

                                  //  Loading
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),


                            Padding(padding: EdgeInsets.symmetric(),
                             child: Column(
                               children: [

                                 SizedBox(height: 3,),
                                 Divider(
                                   height: 1,
                                   thickness: 0.9,
                                   color: Colors.grey.shade200,
                                 ),
                                 Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Text(
                                       product.name,
                                       maxLines: 3,
                                       style: const TextStyle(
                                         fontSize: 15,
                                         fontWeight: FontWeight.bold,
                                         overflow: TextOverflow.ellipsis,

                                       )),
                                 ),

                                 /// Price
                                 Padding(
                                   padding: const EdgeInsets.only(
                                     left: 2,
                                     right: 5,

                                   ),

                                   child: Row(
                                     children: [
                                       Text(

                                         selectedSku != null
                                             ? "\$${selectedSku!.price.toStringAsFixed(2)}"
                                             : "\$${product.lowestPrice.toStringAsFixed(2)}",
                                         style: const TextStyle(
                                           fontSize:15,
                                           fontWeight: FontWeight.bold,
                                           color: Colors.green,
                                           shadows: [
                                             BoxShadow(
                                               color: Colors.yellowAccent,
                                               blurStyle: BlurStyle.outer,
                                               blurRadius: 3,
                                               spreadRadius: 0.4,
                                             ),
                                           ],
                                         ),

                                       ),
                                       Expanded(child: SizedBox(width: 1,)),

                                       // add to cart
                                       IconButton(onPressed: (){

                                       },
                                         icon: Icon(CupertinoIcons.cart,
                                           color: Colors.blue,
                                           size: 15,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                 // IconButton(onPressed: (){
                                 //
                                 // },
                                 //   icon: Icon(CupertinoIcons.cart,
                                 //     color: Colors.blue,
                                 //     size: 19,
                                 //   ),
                                 // ),

                                 // //description
                                 // Padding(
                                 //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                 //   child: Text(product.description, maxLines: 2,
                                 //       overflow: TextOverflow.ellipsis),
                                 // ),
                               ],
                             ),
                            ),


                          ],
                        ),
                      ),
                    ),
                    ),

                    // Positioned(
                    //   right: 10,
                    //     top: 3,
                    //     child: IconButton(
                    //         onPressed: (){
                    //           setState(() {
                    //             heart = !heart;
                    //           });
                    //
                    //         },
                    //    icon: Icon(
                    //      heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    //
                    //    ),
                    //       color: heart ? Colors.redAccent : Colors.grey,
                    // ),
                    // ),
                    // IconButton(
                    //   onPressed: () async {
                    //     final newValue = !product.isFavorite;
                    //     setState(() {
                    //       product.isFavorite = newValue; // update UI
                    //     });
                    //
                    //     try {
                    //       print('Favorite clicked: productId=${product.id}, newValue=$newValue');
                    //       await productService.toggleFavorite(
                    //         userId: widget.userId,
                    //         productId: product.id,
                    //         isFavorite: newValue,
                    //         token: widget.userToken,
                    //       );
                    //       print('API success: favorite updated');
                    //     } catch (e) {
                    //       print("API failed or field issue: $e");
                    //       // revert if API fail
                    //       setState(() {
                    //         product.isFavorite = !newValue;
                    //       });
                    //     }
                    //   },
                    //   icon: Icon(
                    //     product.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    //   ),
                    //   color: product.isFavorite ? Colors.redAccent : Colors.grey,
                    // ),


                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
//
// detail page
//
//   void _showProductDetails(Product product) {
//     showModalBottomSheet(
//       context: ,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) =>
//           DraggableScrollableSheet(
//             initialChildSize: 0.9,
//             minChildSize: 0.5,
//             maxChildSize: 0.95,
//             expand: false,
//             builder: (context, scrollController) {
//               return Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Container(
//                         width: 40,
//                         height: 4,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     // Product Image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         product.mainImage,
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Product Name
//                     Text(
//                       product.name,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Description
//                     Text(
//                       product.description,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // SKUs
//                     const Text(
//                       'Available Options:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Expanded(
//                       child: ListView.builder(
//                         controller: scrollController,
//                         itemCount: product.skus.length,
//                         itemBuilder: (context, index) {
//                           final sku = product.skus[index];
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: ListTile(
//                               title: Text('SKU: ${sku.sku}'),
//                               subtitle: Text(sku.description),
//                               trailing: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     '\$${sku.price.toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Qty: ${sku.quantity}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//     );
//   }
// }