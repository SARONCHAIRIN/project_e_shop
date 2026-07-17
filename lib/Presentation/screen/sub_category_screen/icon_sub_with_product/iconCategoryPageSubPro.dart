import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/datasources/sub_with_product/sub_product_service.dart';
import '../../../../data/models/subcategory_model_eshop.dart';
import '../../../../provider/auth_provider1.dart';
import '../product_screen_eshop.dart';


class SubcategoryIconPage extends ConsumerStatefulWidget {
  final String? categoryName;

  const SubcategoryIconPage({
    super.key,
    required this.categoryName,
  });

  @override
  ConsumerState<SubcategoryIconPage> createState() =>
      _SubcategoryIconPageState();
}


class _SubcategoryIconPageState
    extends ConsumerState<SubcategoryIconPage> {

  final ApiService apiService = ApiService();

  late Future<List<SubcategoryData>> future;


  @override
  void initState() {
    super.initState();
    _load();
  }


  @override
  void didUpdateWidget(covariant SubcategoryIconPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryName != widget.categoryName) {
      _load();
      setState(() {});
    }
  }


  void _load() {

    if(widget.categoryName == null){
      future = apiService.fetchSubcategories();
    }else{
      future = apiService.fetchSubcategoriesByCategoryName(
        widget.categoryName!,
      );
    }

  }



  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<SubcategoryData>>(

      future: future,

      builder: (context,snapshot){


        // Loading shimmer
        if(snapshot.connectionState == ConnectionState.waiting){

          return _buildShimmer();

        }



        if(snapshot.hasError || !snapshot.hasData){

          return const SliverToBoxAdapter(
            child: SizedBox(),
          );

        }



        final subcategories = snapshot.data!;



        return SliverPadding(

          padding: const EdgeInsets.symmetric(horizontal:12),

          sliver: SliverGrid(

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount:4,
              mainAxisSpacing:16,
              crossAxisSpacing:12,
              childAspectRatio:.75,
              mainAxisExtent: 100

            ),


            delegate: SliverChildBuilderDelegate(

                  (context,index){

                final sub = subcategories[index];


                return GestureDetector(

                  onTap: (){

                    final repository =
                    ref.read(userAuthRepositoryProvider);


                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context)=>
                            ProductScreen_sub(
                              subcategoryId: sub.id,
                              repository: repository,
                              subcategoryName: sub.name,
                            ),
                      ),
                    );

                  },


                  child: Column(

                    children: [


                      Container(

                        width:58,
                        height:58,

                        decoration: BoxDecoration(
                          shape:BoxShape.circle,
                          color:Colors.blue.shade50,
                        ),


                        child: ClipOval(

                          child: Image.network(
                            sub.image ?? "",
                            fit:BoxFit.cover,

                            loadingBuilder:
                                (context,child,loading){

                              if(loading == null){
                                return child;
                              }

                              return _circleShimmer();

                            },


                            errorBuilder:
                                (_,__,___)=>
                            const Icon(Icons.category),

                          ),

                        ),

                      ),


                      const SizedBox(height:6),


                      Text(
                        sub.name,

                        maxLines:1,
                        overflow:
                        TextOverflow.ellipsis,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(
                          fontSize:11,
                          fontWeight:
                          FontWeight.w600,
                        ),

                      )

                    ],

                  ),

                );

              },


              childCount:subcategories.length,

            ),

          ),

        );


      },

    );

  }





  // Whole grid shimmer
  Widget _buildShimmer(){


    return SliverPadding(

      padding:
      const EdgeInsets.symmetric(horizontal:12),


      sliver: SliverGrid(

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount:4,
          mainAxisSpacing:16,
          crossAxisSpacing:12,
          childAspectRatio:.75,

        ),


        delegate:
        SliverChildBuilderDelegate(

              (_,index){

            return Column(

              children:[


                _circleShimmer(),


                const SizedBox(height:8),


                Shimmer.fromColors(

                  baseColor:
                  Colors.grey.shade300,

                  highlightColor:
                  Colors.grey.shade100,


                  child: Container(

                    height:10,
                    width:45,

                    decoration:
                    BoxDecoration(

                      color:Colors.white,

                      borderRadius:
                      BorderRadius.circular(5),

                    ),

                  ),

                )

              ],

            );

          },


          childCount:8,

        ),

      ),

    );

  }




  Widget _circleShimmer(){

    return Shimmer.fromColors(

      baseColor:Colors.grey.shade300,

      highlightColor:Colors.grey.shade100,


      child:Container(

        width:58,
        height:58,


        decoration:
        const BoxDecoration(

          shape:BoxShape.circle,

          color:Colors.white,

        ),

      ),

    );

  }


}