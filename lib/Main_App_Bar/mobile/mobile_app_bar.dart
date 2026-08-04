import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Search_in_App_Bar/button_search_in_app_bar.dart';

class MobileAppBar extends StatelessWidget {
  final bool showBars;

  final dynamic authRepository;

  const MobileAppBar({
    super.key,

    required this.showBars,

    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.yellowAccent,

      floating: true,

      centerTitle: false,

      forceMaterialTransparency: true,

      elevation: 1,

      expandedHeight: 40,

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.blue,

        statusBarIconBrightness: Brightness.light,
      ),

      bottom: ButtonInAppBar(showBars: showBars, repository: authRepository),
    );
  }
}
