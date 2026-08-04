import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/responsive/responsive.dart';

class MessageMain extends StatefulWidget {
  const MessageMain({super.key});

  @override
  State<MessageMain> createState() => _MessageMainState();
}

class _MessageMainState extends State<MessageMain> {
  final String telegramUsername =
      "https://t.me/contact/1777776159:KLGkumcFEo4vzzuz";
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
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Message page show in console
    print('|=================================================|');
    print('|              MessageMain loaded                 |');
    print('|=================================================|');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "support_center".tr(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: Responsive.isMobile(context)
                ? double.infinity
                : 700,

            padding: EdgeInsets.all(
              Responsive.isMobile(context) ? 20 : 40,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: EdgeInsets.all(
                    Responsive.isMobile(context) ? 25 : 35,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.support_agent,
                    size: Responsive.isMobile(context) ? 60 : 80,
                    color: Colors.blueAccent,
                  ),
                ),


                const SizedBox(height: 30),


                Text(
                  "how_can_we_help".tr(),
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: Responsive.isMobile(context)
                        ? 20
                        : 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 10),


                Text(
                  "contact_support_telegram".tr(),
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: Responsive.isMobile(context)
                        ? 14
                        : 18,

                    color: Colors.grey,
                  ),
                ),


                const SizedBox(height: 30),


                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.telegram,
                      color: Colors.blue,
                    ),

                    title: Text(
                      "chat_on_telegram".tr(),
                    ),

                    trailing:
                    const Icon(Icons.arrow_forward_ios),

                    onTap: openTelegram,
                  ),
                ),


                const SizedBox(height: 20),


                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton.icon(
                    onPressed: _openTelegram,

                    icon: const Icon(
                      Icons.telegram,
                      color: Colors.white,
                    ),

                    label: Text(
                      "contact_via_telegram".tr(),

                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
