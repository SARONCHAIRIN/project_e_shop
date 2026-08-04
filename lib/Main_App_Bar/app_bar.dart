import 'package:flutter/material.dart';
import '../core/responsive/responsive.dart';
import 'mobile/mobile_app_bar.dart';
import 'tablet/tablet_app_bar.dart';
import 'desktop/desktop_app_bar.dart';
import 'web/web_app_bar.dart';

class MainAppBar extends StatelessWidget {
  final bool showBars;
  final dynamic authRepository;

  const MainAppBar({
    super.key,

    required this.showBars,

    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileAppBar(showBars: showBars, authRepository: authRepository);
    } else if (Responsive.isTablet(context)) {
      return TabletAppBar(showBars: showBars, authRepository: authRepository);
    } else if (Responsive.width(context) >= 1600) {
      return WebAppBar(showBars: showBars, authRepository: authRepository);
    } else {
      return DesktopAppBar(showBars: showBars, authRepository: authRepository);
    }
  }
}
