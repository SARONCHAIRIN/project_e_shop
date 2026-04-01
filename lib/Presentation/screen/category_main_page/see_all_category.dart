import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/material.dart';

class SeeAllCategory extends StatefulWidget {
  const SeeAllCategory({super.key});

  @override
  State<SeeAllCategory> createState() => _SeeAllCategoryState();
}

class _SeeAllCategoryState extends State<SeeAllCategory> {
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
        // controller: _scrollController,
        slivers: [
          // Your app bar - will scroll away
          // SliverMainAppBar(
          //   showBars: showBars,
          //   authRepository: widget.authRepository,
          // ),


          // Your other slivers...
          SliverToBoxAdapter(
            child: Column(
              children: [

                SizedBox(height: 20,),
                const SizedBox(height: 1),
              ],
            ),
          ),

          // Your grid
          const SubcategoryWithProduct(),
        ],
      ),
    );
  }
}