import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model_eshop.dart';
import '../controllers/search_controller.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return  Center(
              child: SpinKitCircle(color: Colors.red,));
        }

        if (controller.results.isEmpty) {
          return const Center(child: Text('No results found',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 25,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),));
        }

        return ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            RefreshIndicator(

            onRefresh: () async {
              await controller.results;
            },
            child: ListView.builder(
              itemCount: controller.results.length,
              itemBuilder: (context, index) {
                Product product = controller.results[index];

                return ListTile(
                  leading: Image.network(
                    product.mainImage,
                    width: 50,
                    height: 50,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),

                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: Text(
                    '\$${product.lowestPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                );
              },
            ),
          ),
          ],
        );
      },
    );
  }


}