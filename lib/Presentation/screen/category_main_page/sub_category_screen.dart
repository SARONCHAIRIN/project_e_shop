// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../controllers/sub_category_controller.dart';
//
// class SubCategoryPage extends StatefulWidget {
//   const SubCategoryPage({super.key});
//
//   @override
//   State<SubCategoryPage> createState() =>
//       _SubCategoryPageState();
// }
//
// class _SubCategoryPageState
//     extends State<SubCategoryPage> {
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() =>
//         context.read<SubCategoryController>()
//             .fetchSubCategories());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text("Sub Categories")),
//
//
//       body: Consumer<SubCategoryController>(
//         builder: (context, controller, child) {
//
//           if (controller.isLoading) {
//             return const Center(
//                 child: CircularProgressIndicator());
//           }
//
//           if (controller.error != null) {
//             return Center(
//                 child: Text(controller.error!));
//           }
//
//           return ListView.builder(
//             itemCount: controller.subCategories.length,
//             itemBuilder: (context, index) {
//
//               final item =
//               controller.subCategories[index];
//
//               return Card(
//                 color: Colors.blue,
//                 child: ListTile(
//                   leading: Image.network(item.image),
//                   title: Text("Name${item.name}"),
//                   subtitle: Text(item.categoryName),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

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