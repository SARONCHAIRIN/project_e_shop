
import 'package:e_shop/Presentation/screen/sub_category_screen/product_screen_eshop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
              child: SpinKitFadingCircle(color: Colors.blueAccent),
            ),
          );
        }

        // error
        else if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(child: Text('Error ${snapshot.error}')),
          );
        }

        // no data
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No data Subcategory')),
          );
        }

        // have data show Grid
        final subcategories = snapshot.data!;

        return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 30,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final sub = subcategories[index];
              return GestureDetector(
                onTap: () {
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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurStyle: BlurStyle.outer,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 5,
                      right: 5,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [

                        // image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(1),
                            ),
                            child: sub.image == null || sub.image!.isEmpty
                                ? Image.asset(
                              'assets/images/default_image.png',
                              fit: BoxFit.fill,
                              width: 40,
                            )
                                : Image.network(
                              sub.image!,
                              width: 50,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_image.png',
                                  fit: BoxFit.fill,
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


                        //text
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: Text(
                            sub.name,
                            maxLines: 1,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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