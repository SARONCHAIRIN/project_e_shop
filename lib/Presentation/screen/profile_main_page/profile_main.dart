import 'package:flutter/material.dart';
import '../../../core/responsive/responsive.dart';
import 'mobile/mobile_profile.dart';
import 'tablet/tablet_profile.dart';
import 'desktop/desktop_profile.dart';
import 'web/web_profile.dart';

class ProfileMain extends StatelessWidget {
  final dynamic authRepository;

  const ProfileMain({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileProfile(authRepository: authRepository);
    }

    if (Responsive.isTablet(context)) {
      return TabletProfile(authRepository: authRepository);
    }

    if (Responsive.isDesktop(context)) {
      return DesktopProfile(authRepository: authRepository);
    }

    return WebProfile(authRepository: authRepository);
  }
}
