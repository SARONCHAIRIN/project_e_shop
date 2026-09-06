
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_in_Product_detail.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/storage/token_storage.dart' show TokenStorage;
import '../../../data/models/product_model_eshop.dart';
import '../../../provider/cart_provider.dart';

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
  bool isExpandedText = false;
  int currentIndex = 0;
  late PageController _controller;

  int getSkuStock(ProductSku sku) {
    return sku.quantity ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.product.skus.isNotEmpty) {
      selectedSku = widget.product.skus.first;
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

  List<String> getDisplayImages() {
    if (selectedSku != null &&
        selectedSku!.images != null &&
        selectedSku!.images!.isNotEmpty) {
      return selectedSku!.images!;
    }
    if (widget.product.mainImage.isNotEmpty) {
      return widget.product.mainImage;
    }
    return ['assets/images/default_image.png'];
  }
  Widget _buildSkuSelector() {
    final skus = widget.product.skus;
    if (skus.isEmpty) return const SizedBox.shrink();

    // ប្រើ LayoutBuilder ដើម្បីចាប់យកប្រវែង (width) ដែលមាននៅលើអេក្រង់ជាក់ស្តែង
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Variant",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: skus.map((sku) {
                final isSelected = selectedSku?.id == sku.id;
                final String attrNameText = sku.attributes
                    .map(
                      (attr) =>
                  attr.values.isNotEmpty ? attr.values.first.value : '',
                )
                    .where((text) => text.isNotEmpty)
                    .join(" / ");

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedSku = sku;
                      currentIndex = 0;
                    });
                    if (_controller.hasClients) {
                      _controller.jumpToPage(0);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    // កំណត់ maxWidth កុំឲ្យ Item មួយនេះធំជាងទំហំដែល Parent មាន
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            attrNameText.isEmpty ? "Standard" : attrNameText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.blue.shade700 : Colors.black87,
                            ),
                            maxLines: 2, // អនុញ្ញាតឲ្យចុះបន្ទាត់អតិបរមា ២ ជួរ
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "\$${sku.price.toStringAsFixed(2)}",

                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.red : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = getDisplayImages();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(


        title: Text(
          product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                  child: isDesktop
                      ? _buildDesktopLayout(images, product)
                      : _buildMobileTabletLayout(images, product),
                ),
              ),
              if (widget.subcategoryId != null &&
                  widget.subcategoryName != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, thickness: 1, color: Color(0xFFE9ECEF)),
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32.0 : 16.0,
                          ),
                          child: Text(
                            'More From ${widget.subcategoryName}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: ProductInProductDetail(
                            subcategoryId: widget.subcategoryId!,
                            subcategoryName: widget.subcategoryName!,
                            repository: widget.repository,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildBottomNavBar(),
    );
  }

  // --- MOBILE / TABLET LAYOUT ---
  Widget _buildMobileTabletLayout(List<String> images, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageGallery(images, height: 340),
        const SizedBox(height: 20),
        _buildProductDetailsContent(product),
      ],
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(List<String> images, Product product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildImageGallery(images, height: 480),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductDetailsContent(product),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 20),
                _buildDesktopActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- COMMON IMAGE GALLERY ---
  Widget _buildImageGallery(List<String> images, {required double height}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final image = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image.startsWith('http')
                      ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(image, fit: BoxFit.contain),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SmoothPageIndicator(
            controller: _controller,
            count: images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: Colors.blue.shade600,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // --- CORE PRODUCT DETAILS CONTENT ---
  Widget _buildProductDetailsContent(Product product) {
    final bool isInStock = selectedSku != null && (selectedSku!.quantity ?? 0) > 0;
    final stockCount = selectedSku != null ? getSkuStock(selectedSku!) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isInStock ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isInStock ? "$stockCount in stock" : "Out of Stock",
                style: TextStyle(
                  color: isInStock ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          selectedSku != null
              ? "\$${selectedSku!.price.toStringAsFixed(2)}"
              : "\$${widget.product.lowestPrice.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2B8A3E),
          ),
        ),
        const SizedBox(height: 20),
        _buildSkuSelector(),
        const SizedBox(height: 20),

        _buildAttributesSection(),
        const SizedBox(height: 24),


        const Text(
          "Description",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          widget.product.description,
          maxLines: isExpandedText ? null : 3,
          overflow: isExpandedText ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),

        const SizedBox(height: 4),

        InkWell(
          onTap: () {
            setState(() {
              isExpandedText = !isExpandedText;
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpandedText ? 'Show Less' : 'Show More',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: isExpandedText ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        _buildFeatureBadges(),
      ],
    );
  }

  Widget _buildAttributesSection() {
    if (selectedSku == null || selectedSku!.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ...selectedSku!.attributes.map((attribute) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    attribute.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: attribute.values.map((value) {
                      return Text(
                        value.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureBadges() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_outlined, color: Colors.blue.shade600, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WARRANTY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '2 Years Official',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: Colors.blue.shade600, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Free Express',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- DESKTOP ACTION BUTTONS ---
  Widget _buildDesktopActions() {
    final bool isInStock = selectedSku != null && (selectedSku!.quantity ?? 0) > 0;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isInStock ? () => _handleAddToCart() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1B140),
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            label: const Text(
              "Add to Cart",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isInStock ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE56A5D),
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.bolt, size: 20),
            label: const Text(
              "Buy Now",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // --- MOBILE BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavBar() {
    final bool isInStock = selectedSku != null && (selectedSku!.quantity ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isInStock ? () => _handleAddToCart() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1B140),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isInStock ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE56A5D),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.bolt, size: 18),
                label: const Text(
                  "Buy Now",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    if (selectedSku == null) return;
    final storage = TokenStorage();
    final userId = await storage.readUserId();
    final token = await storage.readToken();

    if (userId == null || token == null) {
      if (mounted) _showLoginSheet(context);
      return;
    }

    final cartController = ref.read(cartControllerProvider.notifier);
    try {
      await cartController.addItem(selectedSku!.id, 1);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(userId: userId, token: token),
        ),
      );
    } catch (e) {
      debugPrint("Add to cart failed: $e");
    }
  }
}
