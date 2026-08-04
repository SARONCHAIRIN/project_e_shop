import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String username;
  final String email;

  const ProfileInfo({super.key, required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          username,

          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 5),

        Text(
          email,

          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
