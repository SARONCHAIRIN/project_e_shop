import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';

class SeeAllCategory extends StatefulWidget {
  final User_AuthRepository repository;
  const SeeAllCategory({super.key, required this.repository});

  @override
  State<SeeAllCategory> createState() => _SeeAllCategoryState();
}

class _SeeAllCategoryState extends State<SeeAllCategory> {
  List<String> categories = [
    'All',
    'Laptop',
    'Electronics',
    'Drone',
    'shose',
    'Clothing',
    'Sports',
    'Beauty',
  ];
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Product',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // choice chip category
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 110),

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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
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

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Your grid
          SubcategoryWithProduct(categoryName: selectedCategory,repository: widget.repository,),
        ],
      ),
    );
  }
}
