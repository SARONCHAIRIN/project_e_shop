import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'menu_tile.dart';

class GuestMenu extends StatelessWidget {

  final VoidCallback onTrackOrder;
  final VoidCallback onHelp;

  const GuestMenu({
    super.key,
    required this.onTrackOrder,
    required this.onHelp,
  });


  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            blurRadius: 1,
            spreadRadius: 1,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),


      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              8,
            ),

            child: Text(
              'browseAsGuest'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),



          MenuTile(

            icon: Icons.inventory_2_outlined,

            iconBg: const Color(0xFFE6F1FB),

            iconColor: const Color(0xFF185FA5),

            title: 'trackOrder'.tr(),

            subtitle: 'trackOrderSubtitle'.tr(),

            onTap: onTrackOrder,
          ),



          MenuTile(

            icon: Icons.headset_mic_outlined,

            iconBg: const Color(0xFFE1F5EE),

            iconColor: const Color(0xFF0F6E56),

            title: 'helpAndSupport'.tr(),

            subtitle: 'helpAndSupportSubtitle'.tr(),

            onTap: onHelp,
          ),
        ],
      ),
    );
  }
}