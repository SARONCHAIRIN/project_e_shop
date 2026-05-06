import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import '../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../data/models/subcategory_model_eshop.dart';

class SubcategoryWithProduct extends StatefulWidget {
  final String categoryName;

  const SubcategoryWithProduct({
    super.key,
    required this.categoryName,
  });

  @override
  State<SubcategoryWithProduct> createState() => _SubcategoryWithProductState();
}

class _SubcategoryWithProductState extends State<SubcategoryWithProduct> {
  final ApiService apiService = ApiService();
  late Future<List<SubcategoryData>> _futureSubcategories;

bool ispressed = false;
  @override
  void initState() {
    super.initState();
    _loadData(); // load data for the initial category
    _futureSubcategories = apiService.fetchSubcategories();
  }

  @override

  void didUpdateWidget(SubcategoryWithProduct oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryName != widget.categoryName) {
      _loadData(); // reload when category changes
      setState(() {
      });
    }
  }
  void _loadData() {
    _futureSubcategories =
        apiService.fetchSubcategoriesByCategoryName(widget.categoryName);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubcategoryData>>(
      future: _futureSubcategories,
      builder: (context, snapshot) {

        // store
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  SliverFillRemaining(
            child: Center(
              child: SpinKitFadingCircle(color: Colors.black,size: 40,),
            ),
          );
        }

        // error
        else if (snapshot.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,

        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
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
                  repeat: true,
                  animate: true,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 5),

              TextButton(onPressed: (){
                _refresh();
              },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
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
                    child: Text("Please try again",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18
                    ),),
                  ),
              ),
              SizedBox(height: 150,),
            ],
          ),
        ),
      );
    }

        // no data
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return  SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 70,
                      right: 70,
                      top: 10
                  ),
                  child: Lottie.asset(
                    'assets/animations/empty.json',
                    repeat: true,
                    animate: true,
                  ),
                ),


                SizedBox(height: 10),

                Text(

                  "No products found",

                  style: TextStyle(

                    fontSize: 18,

                    fontWeight: FontWeight.w600,

                  ),


                ),

                SizedBox(height: 6),

                Text(

                  "Try a different keyword",

                  style: TextStyle(color: Colors.grey),

                ),

                SizedBox(height: 20,)
              ],
            ),

          );
        }

        // have data show grid
        final subcategories = snapshot.data!;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.57,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final sub = subcategories[index];
                return GestureDetector(

                  onTap: () {

                    setState(() {
                      ispressed = false;
                    });
                    //push sub_product screen
                    print('clicked subcategory: ${sub.name} (id: ${sub.id})');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductScreen_sub(
                          subcategoryId: sub.id,
                          subcategoryName: sub.name,
                        ),
                      ),
                    );
                  },

                  onTapDown: (_) {
                      setState(() {
                        ispressed = true;
                    });
                  },

                  onTapCancel: () {
                    // Reset the scale effect if the tap is canceled
                    setState(() {
                      ispressed = false;
                    });
                  },

                  onTapUp: (_) {
                    // Reset the scale effect after the tap is released
                    setState(() {
                      ispressed = false;
                    });
                  },

                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..scale(ispressed ? 0.90 : 1.0), //  Zoom effect
                    width: 200,
                    height: 100,
                    decoration: BoxDecoration(
                      color: ispressed ? Colors.grey.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                      color: Colors.white,
                      blurRadius: ispressed ? 5 : 10,
                      offset: Offset(0, ispressed ? 2 : 6),
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 0.1,
                      shadowColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        child: Column(
                          children: [

                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: sub.image == null || sub.image!.isEmpty
                                    ? Image.asset(
                                  'assets/images/default_image.png',
                                  // fit: BoxFit.fill,
                                  width: double.infinity,
                                )
                                    : Image.network(
                                  sub.image!,
                                  width: double.infinity,
                                  // fit: BoxFit.fill,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_image.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            const Divider(
                              color: Colors.blue,
                              height: 1,
                              thickness: 0.3,
                            ),


                            // text
                            Padding(
                              padding: const EdgeInsets.all(1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  //name
                                  Center(
                                    child: Text(
                                      sub.name,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // description
                                  Text(
                                    sub.description,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // category name
                                  Container(
                                    width: 90,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.transparent,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.lightBlueAccent,
                                          blurStyle: BlurStyle.outer,
                                          blurRadius: 1.5,
                                          spreadRadius: 0.1,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      sub.categoryName,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: subcategories.length,
            ),
          ),
        );
      },
    );
  }
}