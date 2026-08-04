
import 'package:flutter/material.dart';

import '../widgets/profile_avatar.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_menu.dart';
import '../widgets/profile_top_bar.dart';

class MobileProfileBody extends StatelessWidget {
  final dynamic authRepository;

  const MobileProfileBody({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),

      child: Column(
        children: [
          ProfileTopBar(title: "Profile", onSettingPressed: () {}),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: ProfileCard(
              child: Column(
                children: [
                  const ProfileAvatar(),

                  const SizedBox(height: 15),

                  const ProfileInfo(username: "User", email: "user@email.com"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: ProfileMenu(
              onOrders: () {},

              onWishlist: () {},

              onAddress: () {},

              onSetting: () {},

              onLogout: () {},
            ),
          ),
        ],
      ),
    );
  }
}
