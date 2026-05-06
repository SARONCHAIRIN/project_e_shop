import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/rendering.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../core/network/api_client.dart';

class CategoryMain extends StatefulWidget {
  final authRepository;
  const CategoryMain({
    super.key,
    required this.authRepository,

  });

  @override
  State<CategoryMain> createState() => _CategoryMainState();
}

class _CategoryMainState extends State<CategoryMain> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;

  List<String> categories = ['All','Laptop','Electronics', 'Drone', 'shose','Clothing', 'Books', 'Home', 'Toys', 'Sports', 'Beauty'];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (showBars) setState(() => showBars = false);
        // if(showTextField ) setState(() => showTextField = false);
      }
      else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!showBars) setState(() => showBars = true);
        // if(!showTextField) setState(() => showTextField = true);
      }
    });
    //category page show in console
    print('|=================================================|');
    print('|              Category Page Loads                |');
    print('|=================================================|');
  }
  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [

          // Your app bar - will scroll away
          SliverMainAppBar(
            showBars: showBars,
            authRepository: widget.authRepository,
          ),



          // Category filter - will scroll away
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),

                SingleChildScrollView(

                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),

                          selected: isSelected, // important

                          selectedColor: Colors.blueAccent.shade200,
                          backgroundColor: Colors.white,

                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),

                          onSelected: (value) {
                            setState(() {
                              selectedCategory = category; //  change selected
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Your grid
           SubcategoryWithProduct(
            categoryName: selectedCategory,
          ),
        ],
      ),
    );
  }
}
