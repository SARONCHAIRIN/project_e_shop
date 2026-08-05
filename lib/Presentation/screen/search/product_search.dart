import 'dart:async';
import 'dart:convert';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/responsive/responsive.dart';
import '../../../data/models/product_model_eshop.dart';
import '../sub_category_screen/product_detail_screen_eshop.dart';

class SearchProductpage extends StatefulWidget {
  final User_AuthRepository repository;

  const SearchProductpage({super.key, required this.repository});

  @override
  State<SearchProductpage> createState() => _SearchProductpageState();
}

class _SearchProductpageState extends State<SearchProductpage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  List<Product> products = [];

  List<String> trending = [
    "Laptop",
    "Shoes",
    "Phone",
    "electronic",
    'Drone',
    'iphone',
    'keyboard',
    'Sports',
    'Beauty',
    'Clothing',
  ];
  List<String> history = [];
  bool showDiscover = true;
  bool isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchFocus.addListener(() {
      setState(() {
        showDiscover = searchFocus.hasFocus && searchController.text.isEmpty;
      });
    });
    loadHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  //============HISTORY MANAGEMENT WITH SHARED PREFERENCES================

  //save history
  void saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', history);
  }

  //load history
  void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  void addHistory(String keyword) {
    setState(() {
      history.add(keyword);
    });
  }

  /// Debounce search
  void onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (keyword.isNotEmpty) {
        searchProduct(keyword);
        setState(() {
          searchProduct(keyword);
          history.insert(0, keyword);
          if (history.length > 10) {
            history.removeLast();
          }
          saveHistory();
          showDiscover = false;
        });
      } else {
        setState(() {
          products = [];
          showDiscover = true;
        });
      }
    });
  }

  /// API search
  Future<void> searchProduct(String keyword) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
      "https://e-shop-1-m034.onrender.com/api/v1/products/get/all",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "page": 1,
        "size": 20,
        "criteria_type": 1,
        "criteria_value": keyword.trim(),
      }),
    );

    debugPrint("STATUS: ${response.statusCode}");

    debugPrint("RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List list = json["data"]["payload"] ?? [];

      setState(() {
        products = list.map((e) => Product.fromJson(e)).toList();
        isLoading = false;
        showDiscover = false;
      });
    } else {
      setState(() {
        isLoading = false;
        products = [];
      });

      debugPrint(response.body);
    }
  }

  /// Select keyword from trending/history
  void selectKeyword(String keyword) {
    searchController.text = keyword;

    setState(() {
      history.remove(keyword);
      history.insert(0, keyword);
    });
    saveHistory();

    onSearchChanged(keyword);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: _buildSearchField(),
        centerTitle: true,
        elevation: 0,
        // bottom: _buildSearchField(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (searchController.text.isNotEmpty) {
            await searchProduct(searchController.text);
          }
        },
        child: Column(
          children: [
            ///  HISTORY (ALWAYS SHOW)
            if (history.isNotEmpty) _buildRecentSearchHistory(),

            /// MAIN CONTENT
            Expanded(
              child: isLoading
                  ? _buildLoadingShimmerScreen()
                  : searchController.text.isEmpty
                  ? _buildDiscover()
                  : products.isEmpty
                  ? _searchNotfound()
                  : _buildProductGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchNotfound() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const Icon(Icons.search_off, size: 50, color: Colors.grey),
        const SizedBox(height: 10),
        Lottie.asset(
          'assets/animations/empty.json',
          width: 150,
          height: 150,
          repeat: true,
        ),
        const SizedBox(height: 10),
        Text(
          "No products found",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    ),
  );

  Widget _buildRecentSearchHistory() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(Icons.history, size: 22, color: Colors.black),
            const Text(
              " Recent Search History",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Expanded(child: SizedBox(width: 1)),

            TextButton(
              onPressed: () {
                setState(() => history.clear());
              },
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Colors.redAccent,
                  // fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),

      //recent search history
      Container(
        height: Responsive.isMobile(context) ? 60 : 70,
        padding: const EdgeInsets.symmetric(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: history
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    pressElevation: 1,
                    avatar: Icon(Icons.search, size: 22, color: Colors.grey),
                    label: Text(
                      e,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () => selectKeyword(e),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );

  Widget _buildLoadingShimmerScreen() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.isDesktop(context) || Responsive.isWide(context)
              ? 1600
              : double.infinity,
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          itemCount: Responsive.gridColumns(context) * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.gridColumns(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, __) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Discover section
  Widget _buildDiscover() {
    return ListView(
      padding: EdgeInsets.all(Responsive.pagePadding(context)),
      children: [
        Row(
          children: [
            Icon(Icons.content_paste_search, size: 22, color: Colors.black),
            const Text(
              " Trending Search",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 20,
          children: trending
              .map(
                (e) => ActionChip(
                  avatar: Icon(Icons.search, size: 22, color: Colors.grey),
                  backgroundColor: Colors.white,
                  label: Text(e),
                  onPressed: () => selectKeyword(e),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// GridView with shimmer effect
  Widget _buildProductGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop =
        Responsive.isDesktop(context) || Responsive.isWide(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1600 : double.infinity,
        ),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.gridColumns(context),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.70, // Balanced ratio for image and details
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: product,
                      repository: widget.repository,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Container with Light Background
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFF8F9FA),
                          // Clean modern placeholder background
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  product.mainImage.isNotEmpty
                                      ? product.mainImage.first
                                      : "",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 32,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                              // Optional: Modern floating Wishlist button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border_rounded,
                                    size: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Product Details Section
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 15 : 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${product.lowestPrice}",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      // Uses your app's modern primary color scheme
                                      fontSize: isDesktop ? 17 : 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  // Optional mini add button or rating badge can go here
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Search TextField
  Widget _buildSearchField() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
              vertical: 8,
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocus,
              onChanged: onSearchChanged,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search product...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
