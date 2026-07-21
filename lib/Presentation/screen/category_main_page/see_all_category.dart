import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../data/models/category /category_model.dart';
import '../../../provider/category_provider.dart';

class SeeAllCategory extends ConsumerStatefulWidget {
  final User_AuthRepository repository;

  const SeeAllCategory({super.key, required this.repository});

  @override
  ConsumerState<SeeAllCategory> createState() => _SeeAllCategoryState();
}

class _SeeAllCategoryState extends ConsumerState<SeeAllCategory> {
  CategoryModel? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "All Branch",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: categoriesAsync.when(
        loading: () =>
            const Center(child: SpinKitCircle(color: Colors.grey, size: 20)),

        error: (error, stack) => Center(child: Text(error.toString())),

        data: (categories) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DefaultTabController(
                  length: categories.length + 1,
                  child: Column(
                    children: [
                      Material(
                        color: Colors.white,
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            const Tab(text: "All"),
                            ...categories.map((e) => Tab(text: e.name)),
                          ],
                          onTap: (index) {
                            setState(() {
                              if (index == 0) {
                                selectedCategory = null;
                              } else {
                                selectedCategory = categories[index - 1];
                              }
                            });
                          },
                        ),
                      ),


                    ],
                  ),
                ),
              ),

              SubcategoryWithProduct(
                categoryName: selectedCategory?.name,
                repository: widget.repository,
              ),

              SliverToBoxAdapter(child: SizedBox(height: 200)),

            ],
          );
        },
      ),
    );
  }
}
