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
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [

          // Your app bar - will scroll away
          SliverMainAppBar(
            showBars: showBars,
            authRepository: widget.authRepository,
          ),



          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 10,),


                DefaultTabController(
                  length: categories.length,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: const Color(0xFF1E88E5),
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: const Color(0xFF1E88E5),
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                        tabs: categories.map((category) {
                          return Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        onTap: (index) {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                    ],
                  ),
                ),

                SizedBox(height: 10,),
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
