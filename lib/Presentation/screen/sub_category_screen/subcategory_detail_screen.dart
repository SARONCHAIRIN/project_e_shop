import 'package:flutter/material.dart';

import '../../../../data/models/subcategory_model_eshop.dart';

class SubcategoryDetailScreen extends StatelessWidget {
  final SubcategoryData subcategory;

  const SubcategoryDetailScreen({
    super.key,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subcategory.name),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            //  image
            Container(
              width: double.infinity,
              height: 300,
              child: Image.network(
                subcategory.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subcategory.categoryName,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    subcategory.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ID
                  Text(
                    'ID: ${subcategory.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description label
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description content
                  Text(
                    subcategory.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}