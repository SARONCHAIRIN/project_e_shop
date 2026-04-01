/*

import 'package:e_shop/Presentation/screen/Splash_Screen_Page/slpash_screen.dart';
import 'package:e_shop/Presentation/screen/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/login/login_screen.dart';

class MessageMain extends StatefulWidget {
  final authRepository;
  const MessageMain({super.key,required this.authRepository});

  @override
  State<MessageMain> createState() => _MessageMainState();
}

class _MessageMainState extends State<MessageMain> {

  // final String telegramUrl = "https://t.me/contact/1772433126:NunqbUGYJIMQgkkI";
  final String telegramUrl = "https://t.me/senghour369";

  Future<void> _openTelegram() async {
    final Uri url = Uri.parse(telegramUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Telegram")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(

        title: const Text("Support Center",style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [

         */
/* IconButton(
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                print(" Logging out...");

                // 1. លុបទិន្នន័យទាំងអស់
                await widget.authRepository.logout();

                // 2. ពិនិត្យមើលថាទិន្នន័យត្រូវបានលុប
                final token = await widget.authRepository.storage.readToken();
                print("Token after logout: $token");

                // 3. សម្អាត stack ទាំងស្រុងហើយទៅ AuthWrapper
                if (context.mounted) {
                  // វិធីនេះនឹងលុប route ទាំងអស់ចេញ
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthWrapper(
                        authRepository: widget.authRepository,
                      ),
                    ),
                        (route) => false, // លុប route ទាំងអស់
                  );
                }
              }
            },
            icon: Icon(Icons.logout, size: 25),
          )*//*

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            // Icon
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Need Help?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Our support team is available on Telegram.\nClick the button below to contact us instantly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // Telegram Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openTelegram,
                icon: const Icon(Icons.telegram),
                label: const Text(
                  "Contact via Telegram",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageMain extends StatefulWidget {
  const MessageMain({super.key});

  @override
  State<MessageMain> createState() => _MessageMainState();
}

class _MessageMainState extends State<MessageMain> {
  // final String telegramUsername = "senghour369";
  final String telegramUsername = "senghour369";
/*
  Future<void> _openTelegram() async {
    final Uri appUrl = Uri.parse("tg://resolve?domain=${telegramUsername}");

    // URL for Telegram app
    final Uri appUrl = Uri.parse("tg://resolve?domain=$telegramUsername");
    // Fallback URL for browser
    final Uri webUrl = Uri.parse("https://t.me/$telegramUsername");

    if (await canLaunchUrl(appUrl)) {
      // Open Telegram app if installed
      await launchUrl(appUrl);
    } else if (await canLaunchUrl(webUrl)) {
      // Open browser if app is not installed
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Telegram")),
      );
    }
  }
*/
  Future<void> _openTelegram() async {
    final String username = "senghour369";
    final Uri appUrl = Uri.parse("tg://resolve?domain=$username");
    final Uri webUrl = Uri.parse("https://t.me/$username");

    // Try to open Telegram app
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    }
    // Fallback to browser
    else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
    // If nothing works, show error
    else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Telegram app or browser not available")),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Support Center",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Need Help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Our support team is available on Telegram.\nClick the button below to contact us instantly.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _openTelegram,
                icon: const Icon(Icons.telegram),
                label: const Text(
                  "Contact via Telegram",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
