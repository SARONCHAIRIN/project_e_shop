import 'package:flutter/material.dart';

import 'menu_tile.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onOrders;

  final VoidCallback onWishlist;

  final VoidCallback onAddress;

  final VoidCallback onSetting;

  final VoidCallback onLogout;

  const ProfileMenu({
    super.key,

    required this.onOrders,

    required this.onWishlist,

    required this.onAddress,

    required this.onSetting,

    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuTile(
          icon: Icons.shopping_bag_outlined,

          iconBg: const Color(0xFFE6F1FB),

          iconColor: const Color(0xFF185FA5),

          title: "My Orders",

          subtitle: "View your order history",

          onTap: onOrders,
        ),

        const SizedBox(height: 8),

        MenuTile(
          icon: Icons.favorite_border,

          iconBg: const Color(0xFFFFE8EE),

          iconColor: Colors.red,

          title: "Wishlist",

          subtitle: "Saved products",

          onTap: onWishlist,
        ),

        const SizedBox(height: 8),

        MenuTile(
          icon: Icons.location_on_outlined,

          iconBg: const Color(0xFFE1F5EE),

          iconColor: const Color(0xFF0F6E56),

          title: "Address",

          subtitle: "Manage shipping address",

          onTap: onAddress,
        ),

        const SizedBox(height: 8),

        MenuTile(
          icon: Icons.settings_outlined,

          iconBg: Colors.grey.shade200,

          iconColor: Colors.grey,

          title: "Settings",

          subtitle: "Account settings",

          onTap: onSetting,
        ),

        const SizedBox(height: 8),

        MenuTile(
          icon: Icons.logout,

          iconBg: const Color(0xFFFFEEEE),

          iconColor: Colors.red,

          title: "Logout",

          subtitle: "Sign out account",

          onTap: onLogout,
        ),
      ],
    );
  }
}
