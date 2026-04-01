import 'package:flutter/material.dart';

class CartBadge extends StatelessWidget {

  final int count;

  const CartBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [

        const Icon(Icons.shopping_cart),

        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}