import 'package:flutter/material.dart';

class WebTopHeader extends StatelessWidget {
  const WebTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,

      padding: const EdgeInsets.symmetric(horizontal: 40),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),

      child: Row(
        children: [
          Image.asset('assets/images/eshop_logo.png', width: 50),

          const SizedBox(width: 20),

          const Text(
            "E-Shop",

            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const Spacer(),

          TextButton(onPressed: null, child: Text("Home")),

          TextButton(onPressed: null, child: Text("Category")),

          IconButton(onPressed: null, icon: Icon(Icons.shopping_cart)),

          IconButton(onPressed: null, icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
