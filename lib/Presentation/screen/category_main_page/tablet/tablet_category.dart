import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tablet_category_body.dart';

class TabletCategory extends ConsumerStatefulWidget {
  final dynamic authRepository;

  const TabletCategory({super.key, required this.authRepository});

  @override
  ConsumerState<TabletCategory> createState() => _TabletCategoryState();
}

class _TabletCategoryState extends ConsumerState<TabletCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabletCategoryBody(authRepository: widget.authRepository),
    );
  }
}
