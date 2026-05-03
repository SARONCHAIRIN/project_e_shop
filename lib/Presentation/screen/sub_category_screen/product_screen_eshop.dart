
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/data/datasources/product_service_eshop.dart';
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
                               ],
                             ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
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
