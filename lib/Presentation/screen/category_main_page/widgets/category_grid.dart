import 'package:flutter/material.dart';

class CategoryGridCard extends StatelessWidget {
  final String name;

  final String image;

  final VoidCallback? onTap;

  const CategoryGridCard({
    super.key,

    required this.name,

    required this.image,

    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),

        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),

                child: Image.network(
                  image,

                  fit: BoxFit.cover,

                  width: double.infinity,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),

              child: Text(
                name,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight: FontWeight.w700,

                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
