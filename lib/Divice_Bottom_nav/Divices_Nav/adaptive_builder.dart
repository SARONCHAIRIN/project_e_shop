import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/breakpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget web;

  const AdaptiveBuilder({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.web,
  });

  @override
  Widget build(BuildContext context) {
    // Web platform

    if (kIsWeb) {
      return web;
    }
    final width = MediaQuery.sizeOf(context).width;

    if (width < Breakpoints.mobile) {
      return mobile;
    }

    if (width < Breakpoints.desktop) {
      return tablet;
    }

    return desktop;
  }
}
