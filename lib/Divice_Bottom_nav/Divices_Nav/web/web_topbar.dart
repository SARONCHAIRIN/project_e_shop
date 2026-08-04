import 'package:flutter/material.dart';

class WebTopBar extends StatelessWidget {
  const WebTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,

      padding: const EdgeInsets.symmetric(horizontal: 32),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),

      child: Row(
        children: [
          Text("E Shop", style: Theme.of(context).textTheme.headlineSmall),

          const SizedBox(width: 40),

          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",

                prefixIcon: Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          const SizedBox(width: 30),

          IconButton(onPressed: () {}, icon: Icon(Icons.shopping_cart)),

          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
