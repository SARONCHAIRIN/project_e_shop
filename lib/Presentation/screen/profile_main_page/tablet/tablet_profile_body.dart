import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../widgets/profile_avatar.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_top_bar.dart';

class TabletProfileBody extends StatelessWidget {
  final dynamic authRepository;

  const TabletProfileBody({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),

      child: Column(
        children: [
          ProfileTopBar(title: "profile".tr(), onSettingPressed: () {}),

          const SizedBox(height: 20),

          ProfileCard(
            child: Column(
              children: [
                const ProfileAvatar(size: 100),

                const SizedBox(height: 16),

                const ProfileInfo(username: "User", email: "user@email.com"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ProfileMenu(
            onOrders: () {},

            onWishlist: () {},

            onAddress: () {},

            onSetting: () {},

            onLogout: () {},
          ),
        ],
      ),
    );
  }
}
