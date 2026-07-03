import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_in_Product_detail.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/storage/token_storage.dart' show TokenStorage;
import '../../../data/models/product_model_eshop.dart';
import '../../../provider/cart_provider.dart';
import '../../controllers/cart/cart_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  final int? subcategoryId;
  final String? subcategoryName;
  final User_AuthRepository repository;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.subcategoryId,
    this.subcategoryName,
    required this.repository,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductSku? selectedSku;
  bool isPressed = false;
  bool isPressed1 = false;
  bool pressed1 = false;
  bool pressed2 = false;

  int selectIndex = 0;
  final List<String> sizeOption = ['S', 'M', 'L', 'X', 'XL'];

  int selectColorIndex = 0;
  final List<Color> colorOption = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];
  bool isExpandedText = false;

  int currentIndex = 0;

  late PageController _controller;


  @override
  void initState() {
    super.initState();

    _controller = PageController(); //  MUST HAVE THIS
    if (widget.product.skus.isNotEmpty) {
      selectedSku = widget.product.skus.last;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginBottomSheet(authRepository: widget.repository),
    );
  }

  Map<String, String> selectedAttributes = {};
  Widget _buildAttributes() {
    final sku = selectedSku;

    if (sku == null || sku.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(sku.attributes.length, (index) {
        final attribute = sku.attributes[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: _buildAttributeGroup(attribute),
        );
      }),
    );
  }

  Widget _buildAttributeGroup(dynamic attribute) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              attribute.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10,),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: attribute.values.map<Widget>((value) {
                final isSelected =
                    selectedAttributes[attribute.name] == value.value;

                return ChoiceChip(
                  label: Text(value.value),
                  selected: isSelected,
                  selectedColor: Colors.black,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedAttributes[attribute.name] = value.value;
                    });
                  },
                );
              }).toList(),
            ),

          ],
        ),
        const SizedBox(height: 12),


      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(product.name, style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),

        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //image
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: product.mainImage.isEmpty
                          ? 1
                          : product.mainImage.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        if (product.mainImage.isEmpty) {
                          return Image.asset(
                            'assets/images/default_image.png',
                            // fit: BoxFit.fill,
                          );
                        }

                        return Image.network(
                          product.mainImage[index],
                          // fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/default_image.png',
                              // fit: BoxFit.fill,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  Center(
                    child: product.mainImage.isEmpty
                        ? const SizedBox.shrink()
                        : SmoothPageIndicator(
                      controller: _controller,
                      count: product.mainImage.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${currentIndex + 1} / ${product.mainImage.length}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

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

                      SizedBox(height: 10),

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

                     /* //available option
                      Text(
                        'Available Option',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          // fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
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
                            Text(
                              'Select Size',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 20),

                            //size of product
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(sizeOption.length, (
                                index,
                              ) {
                                bool isSelected = selectIndex == index;
                                bool isAvailable = widget.product.skus.any(
                                  (sku) => sku.size == sizeOption[index],
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectIndex = index;
                                      selectedSku = widget.product.skus
                                          .firstWhere(
                                            (sku) =>
                                                sku.size == sizeOption[index],
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
                                      color: isAvailable
                                          ? Colors.blue
                                          : Colors.white,
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
                                          color: isAvailable
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            SizedBox(height: 35),

                            // select color
                            Text(
                              'Select Colors',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 15),

                            //row of color
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(colorOption.length, (
                                index,
                              ) {
                                bool isselected = selectColorIndex == index;
                                bool isAvailable = widget.product.skus.any(
                                  (sku) => sku.color == colorOption[index],
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectColorIndex = index;

                                      selectedSku = widget.product.skus
                                          .firstWhere(
                                            (sku) =>
                                                sku.color ==
                                                colorOption[index].toString(),
                                            orElse: () => selectedSku!,
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
                                        color: isselected
                                            ? Colors.redAccent
                                            : Colors.white,
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
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),*/

                      const Text(
                        "Available Options",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildAttributes(),

                      //description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Product Description
                      Text(
                        widget.product.description,
                        maxLines: isExpandedText ? null : 6,
                        overflow: isExpandedText
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpandedText = !isExpandedText;
                          });
                        },
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 50),
                          curve: Curves.easeInOut,
                          child: Text(
                            isExpandedText ? 'Show Less  ' : 'Show More...  ',
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
                      SizedBox(height: 10),

                      // image
                      Column(
                        children: List.generate(product.mainImage.length, (
                          index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.mainImage[index],
                                height: 250,
                                width: double.infinity,
                                // fit: BoxFit.fill,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/default_image.png',
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 20),

                      // Avaibility of product
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            Text(
                              'Availability : ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),

                            Container(
                              alignment: Alignment.center,
                              width: 140,
                              height: 30,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
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
                        ),
                      ),
                      SizedBox(height: 10),

                      //delivery info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                pressed1 = !pressed1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed1 ? 1.0 : 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: pressed1 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed1
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
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
                                    child: Icon(
                                      Icons.star,
                                      color: pressed1
                                          ? Colors.blueGrey
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 5),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),

                                      Text(
                                        'WARRANTY',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text(
                                          '2 Years',
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
                            onTap: () {
                              setState(() {
                                pressed2 = !pressed2;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              curve: Curves.bounceInOut,
                              transform: Matrix4.identity()
                                ..scale(pressed2 ? 1.0 : 1.02),
                              alignment: Alignment.center,
                              width: 160,
                              height: 100,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: pressed2 ? Colors.white : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: pressed2
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
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
                                      color: pressed2
                                          ? Colors.blueGrey
                                          : Colors.redAccent,
                                    ),
                                  ),
                                  SizedBox(width: 5),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Shipping',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(
                                        child: Text(
                                          'Free Express',
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

                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // More Products Section (Related Products from same subcategory)
          if (widget.subcategoryId != null &&
              widget.subcategoryName != null) ...[
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
                  SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'More From ${widget.subcategoryName}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Container(
                    // height: double.infinity,
                    height: 260,
                    child: ProductInProductDetail(
                      subcategoryId: widget.subcategoryId!,
                      subcategoryName: widget.subcategoryName!,
                      repository: widget.repository,
                    ),
                  ),

                  SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: _buildnav(),

    );
  }

  Widget _buildnav() {
    final product = widget.product;
    final bool isInStock = product.isActive;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            // Stock Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isInStock ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isInStock ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                isInStock ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: isInStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Add to Cart Button
            Expanded(
              child: GestureDetector(
                onTap: isInStock
                    ? () async {
                  final storage = TokenStorage();
                  final userId = await storage.readUserId();
                  final token = await storage.readToken();

                  if (userId == null || token == null) {
                    _showLoginSheet(context);
                    return;
                  }

                  final cartController =
                  ref.read(cartControllerProvider.notifier);

                  await cartController.addItem(product.id, 1);

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        userId: userId,
                        token: token,
                      ),
                    ),
                  );
                }
                    : null,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isInStock ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ref.watch(cartControllerProvider).isLoading
                      ? const SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20,
                  )
                      : Text(
                    isInStock ? "Add to Cart" : "Out of Stock",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
