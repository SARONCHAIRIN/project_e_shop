
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

import '../../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../../data/models/subcategory_model_eshop.dart';


class IconSubWithProduct extends StatefulWidget {
  const IconSubWithProduct({super.key});

  @override
  State<IconSubWithProduct> createState() => _IconSubWithProductState();
}

class _IconSubWithProductState extends State<IconSubWithProduct> {
  final ApiService apiService = ApiService();
  late Future<List<SubcategoryData>> _futureSubcategories;


  @override
  void initState() {
    super.initState();
    _futureSubcategories = apiService.fetchSubcategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureSubcategories = apiService.fetchSubcategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubcategoryData>>(
      future: _futureSubcategories,
      builder: (context, snapshot) {
        // store
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(
              child: SpinKitFadingCircle(color: Colors.grey, size: 40),
            ),
          );
        }


        // error
        else if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 70,
                    right: 70,
                    top: 10
                  ),
                  child: Lottie.asset(
                    'assets/animations/Error_404.json',
                    // width: 180,
                    // height: 180,
                    repeat: true,// loop the animation

                  ),
                ),


                Text(
                  "Something went wrong",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                TextButton(
                  onPressed: _refresh,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          spreadRadius: 1,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,

                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    vertical: 5
                    ),
                    child: Text(
                    "Please try again",
                    style: TextStyle(color: Colors.redAccent,fontSize: 18),
                                        ),
                  ),
                ),
                SizedBox(height: 50,),
              ],
            ),
          );
        }

        // no data
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return  SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 70,
                      right: 70,
                      top: 10
                  ),
                  child: Lottie.asset(
                    'assets/animations/empty.json',
                    repeat: true,// loop the animation
                    animate: true,
                  ),
                ),
            ),
          );
        }

        // have data show Grid
        final subcategories = snapshot.data!;

        return SliverToBoxAdapter(
          child: Column(
            children: [

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),

                padding: const EdgeInsets.symmetric(vertical: 15),

                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(25),

                  // BACKGROUND GRADIENT
                  gradient: LinearGradient(

                    colors: [

                      Color(0xffFF8A00),

                      Color(0xffFF6A00),

                      Color(0xffFF4D6D),

                    ],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                  ),

                  //image background
                  image: DecorationImage(image: AssetImage('assets/images/background_product.png',),
                  fit: BoxFit.fill),

                  // SHADOW
                  boxShadow: [

                    BoxShadow(

                      color: Colors.orange.withOpacity(0.25),

                      blurRadius: 20,

                      offset: const Offset(0, 8),

                    ),

                  ],

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    //new user
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Text(
                        'New user exclusive',style:TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),


                    Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                      ),
                      child: Row(
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10,),
                        Text('\$4 off Shipping Discount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                        ),
                      ],
                    ),
                    ),
                    SizedBox(height: 10,),
                    //product
                    SizedBox(
                    height: 120,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 0.4,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                      ),
                      items: subcategories.map((sub) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductScreen_sub(
                                  subcategoryId: sub.id ?? 0,
                                  subcategoryName: sub.name ?? "No Name",
                                ),
                              ),
                            );
                          },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [

                                Container(
                                  margin:  EdgeInsets.only(top: 5),
                                  // width: 150,
                                  color: Colors.transparent,

                                  child: Column(
                                    children: [

                                      // IMAGE
                                      Container(

                                        padding: EdgeInsets.only(right: 5),
                                        height: 80,
                                        width: 90,
                                        decoration:  BoxDecoration(
                                          // shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(15),
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.white,
                                          //     blurRadius: 1,
                                          //     spreadRadius: 1,
                                          //     blurStyle: BlurStyle.outer,
                                          //   ),
                                          // ],
                                        ),
                                        child: (sub.image?.isEmpty ?? true)
                                            ? Image.asset('assets/images/default_image.png', fit: BoxFit.fill)
                                            : Image.network(sub.image!, ),

                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        sub.name ?? "No Name",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white,fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        );
                      }).toList(),
                    ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20,),
            ],
          ),
        );


      },
    );
  }
}