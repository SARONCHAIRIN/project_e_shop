import 'package:e_shop/Presentation/screen/order/checkout_page.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart/cart_controller.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  final String token;

  const CartScreen({
    super.key,
    required this.userId,
    required this.token,
  });


  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {



  @override

  void initState() {

    super.initState();

    Future.microtask(() {

      context.read<CartController>().fetchCart();

    });

  }
  @override
  Widget build(BuildContext context) {

    final cartController = context.watch<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            backgroundColor: Colors.white,
            centerTitle: true,


            title: const Text("Cart"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                onPressed: () async {
                  await cartController.fetchCart(); // your refresh method
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever,color: Colors.redAccent,),
                onPressed: () => cartController.clearCart(),
              )
            ],
          ),

          if (cartController.isLoading)
            const SliverFillRemaining(
              child: Center(child: SpinKitCircle(color: Colors.blue,)),
            )

          else if (cartController.hasError)
              SliverFillRemaining(

                child: _buildError(

                  message: cartController.errorMessage,

                  onRetry: () => cartController.fetchCart(),

                ),

              )

          else if
            (cartController.cart == null || cartController.cart!.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyCart(),
              )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = cartController.cart!.items[index];

                  return Column(
                    children: [
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                         child:
                         Dismissible(
                           key: Key(item.id.toString()),
                           direction: DismissDirection.endToStart,

                           onDismissed: (direction) {
                             cartController.deleteItem(item.id);
                           },

                           background: LayoutBuilder(
                             builder: (context, constraints) {
                               return Container(
                                 margin: const EdgeInsets.symmetric(vertical: 6),
                                 decoration: BoxDecoration(
                                   color: Colors.redAccent,
                                   borderRadius: BorderRadius.circular(12),
                                 ),
                                 child: Stack(
                                   children: [
                                     //  Slide animation icon
                                     AnimatedPositioned(
                                       duration: const Duration(milliseconds: 300),
                                       curve: Curves.easeOut,
                                       right: 20,
                                       top: 0,
                                       bottom: 0,
                                       child: Row(
                                         children: const [
                                           Icon(Icons.delete, color: Colors.white),
                                           SizedBox(width: 8),
                                           Text(
                                             "Delete",
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ],
                                 ),
                               );
                             },
                           ),

                           child: Card(
                             margin: const EdgeInsets.symmetric(vertical: 6),
                             color: Colors.white,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12),
                             ),
                             elevation: 0.1,

                             child: ListTile(
                               leading: ClipRRect(
                                 borderRadius: BorderRadius.circular(8),
                                 child: Image.network(
                                   item.image,
                                   width: 70,
                                   height: 70,
                                   fit: BoxFit.fill,
                                 ),
                               ),

                               title: Text(
                                 item.name,
                                 maxLines: 1,
                                 style: const TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w500,
                                   fontStyle: FontStyle.italic,
                                 ),
                               ),

                               subtitle: Text("Qty: ${item.quantity} - \$${item.totalPrice}"),

                               trailing: Container(
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   borderRadius: BorderRadius.circular(20),
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.blueAccent.withOpacity(0.5),
                                       spreadRadius: 1,
                                       blurRadius: 1,
                                       blurStyle: BlurStyle.outer,
                                       offset: const Offset(0, 1), // changes position of shadow
                                     ),
                                   ],
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     IconButton(
                                       icon: const Icon(Icons.remove, color: Colors.black,),
                                       onPressed: item.quantity > 1
                                           ? () => cartController.updateItem(
                                         item.id,
                                         item.quantity - 1,
                                       )
                                           : null,
                                     ),

                                     Text(
                                       '${item.quantity}',
                                       style: const TextStyle(
                                         color: Colors.blue,
                                         fontSize: 16,
                                       ),
                                     ),

                                     IconButton(
                                       icon: const Icon(Icons.add,color: Colors.black,),
                                       onPressed: () => cartController.updateItem(
                                         item.id,
                                         item.quantity + 1,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                    ],
                  );
                },
                childCount: cartController.cart?.items.length ?? 0,
              ),
            ),


          SliverToBoxAdapter(
            child:    Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 2,
                        blurStyle: BlurStyle.outer,
                        offset: const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                ),
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Colors.grey),
                        ),

                        Text(
                          "\$${cartController.cart?.totalPrice.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping',
                          style: const TextStyle(fontSize: 18,color: Colors.grey, fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "FREE",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.greenAccent),
                        ),
                      ],
                    ),

                    Divider(
                      color: Colors.grey.withOpacity(0.2),
                      thickness: 1,
                      height: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "\$${cartController.cart?.totalPrice.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),


           SliverToBoxAdapter(
            child: _buildcheckoutButton(context, cartController),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 100,),
          ),
        ],
      ),

    );
  }

  Widget _buildError({
    String message = "Something went wrong",
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Error_404.json',
              width: 220,
              height: 220,
              repeat: true,
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() => Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 200,),
          Center(
            child: Lottie.asset(
              'assets/animations/empty.json',
              width: 200,
              height: 200,
              repeat: true,
              animate: true,
            ),
          ),
          SizedBox(height: 20,),

          Text("Cart is empty",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
        ],
      ));

  Widget _buildcheckoutButton(BuildContext context, CartController cartController) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 130,
        left: 20,
        right: 20,
      ),
      child:
      ElevatedButton(
        onPressed: cartController.cart == null || cartController.cart!.items.isEmpty
            ? null
            : () async {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(
            repo: AddressRepository(AddressService()),
            storage: TokenStorage(),
            userId: widget.userId,
            token: widget.token,
            addressId: 0,
          )));},
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Proceed to Checkout",
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            SizedBox(width: 5,),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}