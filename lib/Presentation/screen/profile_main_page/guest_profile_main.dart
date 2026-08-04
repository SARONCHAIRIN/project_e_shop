import 'package:e_shop/Presentation/screen/profile_main_page/tablet/tablet_guest_profile.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/web/web_guest_profile.dart';
import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../data/repositories/user_auth_repository.dart';
import 'desktop/desktop_guest_profile.dart';
import 'mobile/mobile_guest_profile.dart';

class GuestProfileMain extends StatelessWidget {
  final User_AuthRepository repository;

  const GuestProfileMain({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileGuestProfile(
        repository: repository,
      );
    }

    if (Responsive.isTablet(context)) {
      return TabletGuestProfile(
        repository: repository,
      );
    }

    if (Responsive.isDesktop(context)) {
      return DesktopGuestProfile(
        repository: repository,
      );
    }

    return WebGuestProfile(
      repository: repository,
    );
  }
}