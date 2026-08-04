import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';

import 'mobile/mobile_category.dart';
import 'tablet/tablet_category.dart';
import 'desktop/desktop_category.dart';
import 'web/web_category.dart';

class CategoryMain extends StatelessWidget {
  final dynamic authRepository;

  const CategoryMain({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileCategory(authRepository: authRepository);
    }

    if (Responsive.isTablet(context)) {
      return TabletCategory(authRepository: authRepository);
    }

    if (Responsive.isDesktop(context)) {
      return DesktopCategory(authRepository: authRepository);
    }

    return WebCategory(authRepository: authRepository);
  }
}
