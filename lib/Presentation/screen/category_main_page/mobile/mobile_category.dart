import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mobile_category_body.dart';

class MobileCategory extends ConsumerStatefulWidget {
  final dynamic authRepository;

  const MobileCategory({super.key, required this.authRepository});

  @override
  ConsumerState<MobileCategory> createState() => _MobileCategoryState();
}

class _MobileCategoryState extends ConsumerState<MobileCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileCategoryBody(authRepository: widget.authRepository),
    );
  }
}
