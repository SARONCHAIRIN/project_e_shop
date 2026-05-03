import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/sub_category_controller.dart';

class SubCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubCategoryController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text("Error: ${controller.error}"));
        }

        if (controller.subCategories.isEmpty) {
          return const Center(child: Text("not found subcategories"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.subCategories.length,
          itemBuilder: (context, index) {
            final sub = controller.subCategories[index];
            return ListTile(
              title: Text(sub.name), // make sure SubCategory has 'name'
            );
          },
        );
      },
    );
  }
}