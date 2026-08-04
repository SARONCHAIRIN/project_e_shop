import 'package:flutter/material.dart';

class ProfileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onSettingPressed;

  const ProfileTopBar({
    super.key,
    required this.title,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: onSettingPressed,
            icon: const Icon(
              Icons.settings,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}