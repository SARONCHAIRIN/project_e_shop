import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/product_model_eshop.dart';
import '../sub_category_screen/product_detail_screen_eshop.dart';

class SearchProductpage extends StatefulWidget {
  const SearchProductpage({super.key});

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
    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://e-shop-1-m034.onrender.com/api/v1/products/search?keyword=$keyword");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        products = (data['content'] as List)
            .map((e) => Product.fromJson(e['data']))
            .toList();
        isLoading = false;
        showDiscover = false;
      });
    } else {
      setState(() => isLoading = false);
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

  /// Discover section
  Widget _buildDiscover() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [

        Row(
          children: [
            Icon(Icons.content_paste_search, size: 25, color: Colors.black,),
            const Text(
              " Trending Search",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 20,
          children: trending
              .map((e) =>
              ActionChip(
                avatar: Icon(
                  Icons.search,
                  size: 22,
                  color: Colors.grey,
                ),
                backgroundColor: Colors.white,
                label: Text(e),
                onPressed: () => selectKeyword(e),
              ))
              .toList(),
        ),
      ],
    );
  }

  /// GridView with shimmer effect
  Widget _buildProductGrid() {
    if (isLoading && products.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, __) =>
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
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

                    )));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 1),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      product.mainImage ?? "",
                      fit: BoxFit.fill,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "\$${product.lowestPrice ?? 0}",
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// Search TextField
  Widget _buildSearchField() =>
      PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: TextField(
            controller: searchController,
            focusNode: searchFocus,
            onChanged: onSearchChanged,
            cursorColor: Colors.grey,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Search product...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            if (history.isNotEmpty)
              _buildRecentSearchHistory(),


            /// MAIN CONTENT
            Expanded(
              child: isLoading
                  ? const Center(child: SpinKitCircle(color: Colors.blue))

                  : searchController.text.isEmpty
                  ? _buildDiscover()

                  : products.isEmpty
                  ? _searchNotfound()
                  : _buildProductGrid(),
            ),
          ],
        ),
      ),);
  }

  Widget _searchNotfound() =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              "No products found",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );

  Widget _buildRecentSearchHistory() =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.history,size: 25,color: Colors.black,),
                const Text(
                  " Recent Search History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(child: SizedBox(width: 1,)),

                TextButton(
                  onPressed: () {
                    setState(() => history.clear());
                  },
                  child: const Text("Clear"),
                )

              ],
            ),
          ),

          //recent search history
              Container(
              height: 60,
              padding: const EdgeInsets.symmetric(

              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 1),
                ],
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: history.map((e) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ActionChip(
                        backgroundColor: Colors.white,
                        pressElevation: 1,
                        avatar: Icon(
                          Icons.search,
                          size: 22,
                          color: Colors.grey,
                        ),
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
                    )).toList(),
              ),
            ),
        ],
      );
}