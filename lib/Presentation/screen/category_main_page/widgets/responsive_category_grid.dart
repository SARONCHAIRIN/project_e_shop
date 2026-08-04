import 'package:flutter/material.dart';

class ResponsiveCategoryGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveCategoryGrid({super.key, required this.children});

  int _columns(double width) {
    if (width >= 1600) return 6;

    if (width >= 1200) return 5;

    if (width >= 900) return 4;

    if (width >= 600) return 3;

    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.all(16),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns(width),

        crossAxisSpacing: 16,

        mainAxisSpacing: 16,

        childAspectRatio: 0.75,
      ),

      itemCount: children.length,

      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
