import 'package:flutter/material.dart';

class CategoryHeader extends StatelessWidget {

  final String title;

  final Widget? action;


  const CategoryHeader({
    super.key,
    this.title = "Categories",
    this.action,
  });


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      child: Row(

        children: [


          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),


          const Spacer(),


          if(action != null)
            action!,


        ],

      ),

    );

  }
}