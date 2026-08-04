import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Widget child;

  final EdgeInsets padding;

  const ProfileCard({
    super.key,

    required this.child,

    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,

            blurRadius: 10,

            spreadRadius: 1,
          ),
        ],
      ),

      child: child,
    );
  }
}
