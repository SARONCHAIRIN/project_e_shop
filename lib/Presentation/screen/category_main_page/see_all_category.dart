import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/material.dart';

class SeeAllCategory extends StatefulWidget {
  const SeeAllCategory({super.key});

  @override
  State<SeeAllCategory> createState() => _SeeAllCategoryState();
}

class _SeeAllCategoryState extends State<SeeAllCategory> {


  List<String> categories = ['All','Laptop','Electronics', 'Drone', 'shose','Clothing', 'Books', 'Home', 'Toys', 'Sports', 'Beauty'];
  String selectedCategory = 'All';

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.white,
        title: Text('Product',style: TextStyle(color: Colors.black,fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
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