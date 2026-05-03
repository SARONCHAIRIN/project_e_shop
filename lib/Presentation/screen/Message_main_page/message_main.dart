import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageMain extends StatefulWidget {
  const MessageMain({super.key});

  @override
  State<MessageMain> createState() => _MessageMainState();
}

class _MessageMainState extends State<MessageMain> {
  final String telegramUsername = "https://t.me/contact/1777776159:KLGkumcFEo4vzzuz";
  final String username = "chairin312007";

  Future<void> _openTelegram() async {
    final Uri appUrl = Uri.parse("tg://resolve?domain=$username");
    final Uri webUrl = Uri.parse("https://t.me/$username");

    // Try open Telegram app
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    }
    // fallback to browser
    else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openTelegram() async {
    final Uri url = Uri.parse("https://t.me/chairin312007");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> openWhatsAppWithMessage() async {
    const phone = "85590901943";
    const message = "Hello, I need support";

    final Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void openSupportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.telegram, color: Colors.blue),
              title: const Text("Telegram"),
              onTap: openTelegram,
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("WhatsApp"),
              onTap: openWhatsAppWithMessage,
            ),
          ],
        );
      },
    );
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

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 110, right: 15),
          child: FloatingActionButton(


            onPressed: () => openSupportMenu(context),

            child: const Icon(Icons.support_agent),

          ),
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

              "How can we help you?",

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

            ),

            const SizedBox(height: 10),

            const Text(

              "Contact our support team via Telegram or WhatsApp",

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey),

            ),

            const SizedBox(height: 30),

            ListTile(

              leading: const Icon(Icons.telegram, color: Colors.blue),

              title: const Text("Chat on Telegram"),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: openTelegram,

            ),

            ListTile(

              leading: const Icon(Icons.chat, color: Colors.green),

              title: const Text("Chat on WhatsApp"),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: openWhatsAppWithMessage,

            ),
            SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openTelegram,
                icon: const Icon(Icons.telegram,size: 30,),
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
