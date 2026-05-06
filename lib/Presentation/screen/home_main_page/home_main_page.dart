import 'package:e_shop/Presentation/screen/category_main_page/see_all_category.dart';
import 'package:e_shop/Presentation/screen/home_main_page/page_carousel_slide/home_carousel_slider.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/icon_sub_with_product/icon_sub_with_product.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../data/models/user_model.dart';

class HomeMainPage extends StatefulWidget {
  final UserModel? user;
  final authRepository;
  // final bool showBars;


  const HomeMainPage({
    super.key,
      this.user,
    required this.authRepository,
    // required this.showBars,

  });

  @override
  State<HomeMainPage> createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;
  bool _isAnimationLoaded = false;

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


    //Home page show in console
    print('|=================================================|');
    print('|              HomeMainPage loaded                |');
    print('|=================================================|');
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(

      children:[

        Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: CustomScrollView(
          // physics: PageScrollPhysics(),
         physics:  ClampingScrollPhysics(),
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

                  //text Trending Categories
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15),
                  //   child: Row(
                  //     children: [
                  //       Text('DiscountForYou',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
                  //
                  //       Expanded(child: SizedBox(width: 1,)),
                  //
                  //       TextButton(
                  //           onPressed: (){
                  //             Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllCategory()));
                  //           },
                  //           child: Text("See All",style: TextStyle(color: Colors.redAccent,fontSize: 15,fontStyle: FontStyle.italic),)
                  //       ),
                  //     ],
                  //
                  //   ),
                  // ),
                  SizedBox(height: 4,),

                  //carousel slider of home page
                  HomeCarouselSlider(),
                  const SizedBox(height: 20,),

                  //Trending Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    //text category see all
                    child: Row(
                      children: [
                        Text('Trending Categories',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w600),),

                        Expanded(child: SizedBox(width: 1,)),

                        TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllCategory()));
                            },
                            child: Text("See All",style: TextStyle(color: Colors.redAccent,fontSize: 15,fontStyle: FontStyle.italic),)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const IconSubWithProduct(),

            SliverToBoxAdapter(
              child: Column(
                children: [

                  //trending categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    //text category see all
                    child: Row(
                      children: [
                        Text(' Popular Products',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.w600),),

                        Expanded(child: SizedBox(width: 1,)),

                        TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllCategory()));
                            },
                            child: Text("See All",style: TextStyle(color: Colors.redAccent,fontSize: 15,fontStyle: FontStyle.italic),)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15,),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
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
                  SizedBox(height: 15,),
                ],
              ),
            ),

             SubcategoryWithProduct(
              categoryName: selectedCategory,
            ),

          ],

        ),
      ),
    ],
    );

  }
}

