import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../data/datasources/subcategory_service_eshop.dart';
import '../../../../data/models/subcategory_model_eshop.dart';

class SubcategoriesScreen extends StatefulWidget {
  const SubcategoriesScreen({super.key});

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<SubcategoryData>> _futureSubcategories;

  @override
  void initState() {
    super.initState();
    _futureSubcategories = _apiService.fetchSubcategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureSubcategories = _apiService.fetchSubcategories();
          });
        },
        child: FutureBuilder<List<SubcategoryData>>(
          future: _futureSubcategories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              
              return const Center(child: SpinKitDualRing(color: Colors.blueAccent));
              
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _futureSubcategories = _apiService.fetchSubcategories();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              
              
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No subcategories found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Data loaded successfully
            List<SubcategoryData> subcategories = snapshot.data!;

            return GridView.builder(

              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
                itemCount: subcategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.60,
                  // mainAxisExtent: 1,
                ),
                itemBuilder: (context, index){
                final sub = subcategories[index];

                 return GestureDetector(

                   onTap: (){
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         // builder: (context) => ProductsScreen(subcategory: sub),),
                         builder: (context) => SubcategoryDetailScreen(subcategory: sub),),
                     );
                   },
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(12),
                       boxShadow: [
                         
                         BoxShadow(
                           color: Colors.lightBlueAccent,
                           blurRadius: 4,
                           blurStyle: BlurStyle.outer,
                         ),
                       ],
                     ),
                     child: Card(
                       color: Colors.white,
                       shadowColor: Colors.blue,
                       shape:  RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Column(
                         children: [


                           //image subcategory
                           Expanded(
                               child:ClipRRect(
                                 borderRadius: BorderRadius.vertical(
                                   top: Radius.circular(10),
                                 ),
                                 child: Image.network(
                                   sub.image,
                                   width: double.infinity,
                                   fit: BoxFit.fill,
                                   errorBuilder: (context, error, stackTrace) {
                                   return Container(
                                    width: 100,
                                     height: 100,
                                     color: Colors.grey[300],
                                     child: const Icon(Icons.broken_image, color: Colors.grey),
                                   );
                                   },
                                   loadingBuilder: (context, child, loadingProgress) {
                                     if (loadingProgress == null) return child;
                                     return Container(
                                       width: 60,
                                       height: 60,
                                       color: Colors.grey[200],
                                       child: const Center(
                                         child: CircularProgressIndicator(strokeWidth: 2),
                                       ),
                                     );
                                     },
                                 ),
                               ),
                           ),

                           //Text name
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [

                                 //name subCategory
                                 Text(
                                     sub.name,
                                   maxLines: 2,
                                   style: TextStyle(
                                     overflow: TextOverflow.ellipsis,
                                     color: Colors.black,
                                     fontSize: 25,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),

                                 SizedBox(height: 10),

                                 //Description
                                 Text(
                                      sub.description,
                                   maxLines: 3,

                                   style: TextStyle(
                                     overflow: TextOverflow.ellipsis,
                                     color: Colors.black,
                                     fontSize: 17,
                                     fontWeight: FontWeight.w400,

                                   ),
                                 ),

                                 SizedBox(height: 6,),

                                 //category name
                                 Container(
                                   width: 100,
                                   height: 30,
                                   alignment: Alignment.center,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(5),
                                     color: Colors.transparent,
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.orange,
                                         blurStyle: BlurStyle.outer,
                                         blurRadius: 3,
                                       ),
                                     ],

                                   ),
                                   child: Text(
                                     sub.categoryName,
                                     style: TextStyle(
                                       color: Colors.pink,
                                       fontSize: 17,
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
                 );
                }
            );
          },
        ),
      ),
    );
  }
}