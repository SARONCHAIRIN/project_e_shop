import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'platform_type.dart';
import 'breakpoints.dart';

class AdaptiveBuilder extends StatelessWidget {
  final Widget mobile;

  final Widget? tablet;

  final Widget? desktop;

  final Widget? web;

  const AdaptiveBuilder({
    super.key,

    required this.mobile,

    this.tablet,

    this.desktop,

    this.web,
  });

  PlatformType _getPlatform(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Flutter Web

    if (kIsWeb) {
      return PlatformType.web;
    }

    // Desktop app

    if (width >= Breakpoints.desktop) {
      return PlatformType.desktop;
    }

    // Tablet

    if (width >= Breakpoints.tablet) {
      return PlatformType.tablet;
    }

    return PlatformType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final platform = _getPlatform(context);

    switch (platform) {
      case PlatformType.web:
        return web ?? desktop ?? mobile;

      case PlatformType.desktop:
        return desktop ?? mobile;

      case PlatformType.tablet:
        return tablet ?? mobile;

      case PlatformType.mobile:
        return mobile;
    }
  }
}
