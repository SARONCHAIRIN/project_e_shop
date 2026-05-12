
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_in_Product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../core/storage/token_storage.dart' show TokenStorage;
import '../../../data/models/product_model_eshop.dart';
import '../../controllers/cart/cart_controller.dart';


class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int? subcategoryId;
  final String? subcategoryName;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.subcategoryId,
    this.subcategoryName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  ProductSku? selectedSku;
  bool isPressed = false;
  bool isPressed1 = false;
  bool pressed1 = false;
  bool pressed2 = false;

  int selectIndex = 0;
  final List<String> sizeOption = ['S' , 'M' , 'L' ,'X' ,'XL'] ;

  int selectColorIndex = 0;
  final List<Color> colorOption =
  [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,

  ];
  bool isExpandedText = false;


  @override
  void initState() {
    super.initState();
    if (widget.product.skus.isNotEmpty) {
      selectedSku = widget.product.skus.last;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(

        title: Text(product.name,style: TextStyle(fontSize: 18),),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),

        slivers: [

          SliverToBoxAdapter(
            child:  Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //image of product
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child:
                      product.mainImage == null || product.mainImage.isEmpty
                          ? Image.asset(
                        'assets/images/default_image.png',
                      )
                          : Image.network(
                        product.mainImage,
                        height: 350,
                        // fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default_image.png',
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),

                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      // Product Name and price
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),

                      // Price
                      Text(
                        selectedSku != null
                            ? "\$${selectedSku!.price.toStringAsFixed(2)}"
                            : "\$${product.lowestPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 25),


                      //available option
                      Text('Available Option',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          // fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 20,),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //select Size
                            Text('Select Size',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 20,),

                            //size of product
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(sizeOption.length, (index) {
                                bool isSelected = selectIndex == index;
                                bool isAvailable = widget.product.skus.any((sku) => sku.size == sizeOption[index]);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectIndex = index;
                                      selectedSku = widget.product.skus.firstWhere(
                                            (sku) => sku.size == sizeOption[index],
                                        orElse: () => selectedSku!,
                                      );
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 150),
                                    transform: Matrix4.identity()
                                      ..scale(isAvailable ? 0.95 : 1.0),

                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.blue : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: isAvailable ? 5 : 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        sizeOption[index],
                                        style: TextStyle(
                                          color: isAvailable ? Colors.white : Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),


                            SizedBox(height: 35,),

                            // select color
                            Text('Select Colors',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),),
                            const SizedBox(height: 15),

                            //row of color
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(colorOption.length, (index) {
                                bool isselected = selectColorIndex == index;
                                bool isAvailable = widget.product.skus.any((sku) => sku.color == colorOption[index]);

                                return GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectColorIndex = index;

                                      selectedSku = widget.product.skus.firstWhere(
                                            (sku) => sku.color == colorOption[index].toString(),
                                        orElse: ()=> selectedSku!,
                                      );
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 150),
                                    padding: EdgeInsets.all(3),
                                    transform: Matrix4.identity()
                                      ..scale(isselected ? 1.10 : 1.0),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorOption[index],
                                      border: Border.all(
                                        color: isselected ? Colors.redAccent : Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: isselected ? 5 : 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );

                              }),
                            ),
                            SizedBox(height: 10,),

                          ],
                        ),
                      ),
                      SizedBox(height: 25,),

                      //description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2,
                        ),
                        child: Text('Description',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ),
                      SizedBox(height: 10,),

                      // Product Description
                      Text(
                        widget.product.description,
                        maxLines: isExpandedText ? null : 6,
                        overflow: isExpandedText
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                      TextButton(
                        onPressed: (){
                          setState(() {
                            isExpandedText = !isExpandedText;
                          });
                        },
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 50),
                          curve: Curves.easeInOut,
                          child: Text(
                            isExpandedText
                                ? 'Show Less  '
                                :  'Show More...  ',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(height: 10,),


                      // Avaibility of product
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child:Row(
                            children: [
                              Text('Availability : ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10,),


                              Container(
                                alignment: Alignment.center,
                                width: 100,
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                      blurStyle: BlurStyle.outer,
                                    ),
                                  ],
                                ),
                                child: Text(

                                  '${product.isActive ? "In Stock" : "Out of Stock"}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ),
                            ],
                          )

                      ),
                      SizedBox(height: 10,),

                      //delivery info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                pressed1 = !pressed1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed1 ? 1.0: 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                              decoration: BoxDecoration(
                                color: pressed1 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed1 ?Colors.blue.withOpacity(0.2): Colors.grey.withOpacity(0.2),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.star,
                                      color: pressed1 ? Colors.blueGrey : Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 5,),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10,),

                                      Text('WARRANTY',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text('2 Years',
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),


                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          //delivery info
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                pressed2 = !pressed2;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed2 ? 1.0: 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                              decoration: BoxDecoration(
                                color: pressed2 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed2 ?Colors.blue.withOpacity(0.2): Colors.grey.withOpacity(0.2),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                    blurStyle: BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.5),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.local_shipping_outlined,
                                        color: pressed2 ? Colors.blueGrey : Colors.redAccent,
                                      )),
                                  SizedBox(width: 5,),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10,),
                                      Text('Shipping',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text('Free Express',
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20,),
                    ],
                  ),
                ],
              ),
            ),
          ),



          // More Products Section (Related Products from same subcategory)
          if (widget.subcategoryId != null && widget.subcategoryName != null) ...[

            SliverToBoxAdapter(
              child: Column(
                children: [
                  Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                    thickness: 1,
                  ),
                  SizedBox(height: 10,),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Text('More From ${widget.subcategoryName}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Container(
                    // height: double.infinity,
                    height: 260,
                    child: ProductInProductDetail(
                      subcategoryId: widget.subcategoryId!,
                      subcategoryName: widget.subcategoryName!,
                    ),
                  ),

                  SizedBox(height: 60,),
                ],
              ),
            ),


          ]
        ],
      ),
      bottomNavigationBar: _buildnav(),
    );
  }

  Widget _buildnav() =>  GestureDetector(
    onTap: () async {
      final product = widget.product;
      try {
        final storage = TokenStorage();
        final int? userId = await storage.readUserId();
        final String? token = await storage.readToken();

        if (userId == null || token == null) {
          //  to login screen

          Navigator.pushNamed(context, LoginScreen.routeName);
          return;
        }


        final int productId = product.id; // assume product.id is int
        final cartController = Provider.of<CartController>(context, listen: false);

        // Show loader
        cartController.isLoading = true;
        cartController.notifyListeners();

        // Call addItem
        await cartController.addItem(productId, 1,); // quantity = 1

        Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(userId: userId, token: token)));
      } catch (e) {

      } finally {
        // Stop loader
        final cartController = Provider.of<CartController>(context, listen: false);
        cartController.isLoading = false;
        cartController.notifyListeners();
      }
    },
    child: Container(
      margin: const EdgeInsets.only(
        top: 2,
        right: 20,
        left: 20,
        bottom: 18
      ),
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Consumer<CartController>(
        builder: (context, cartController, child) {
          return cartController.isLoading
              ? const SpinKitCircle(
            color: Colors.blue,size: 40,)
              : const Text(
            "Add to Cart",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    ),
  );

}

