import 'package:flutter/material.dart';

import '../Search_in_App_Bar/button_search_in_app_bar.dart';

class TabletAppBar extends StatelessWidget {
  final bool showBars;

  final dynamic authRepository;

  const TabletAppBar({
    super.key,

    required this.showBars,

    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,

      floating: true,

      expandedHeight: 60,

      elevation: 0,

      backgroundColor: Colors.orangeAccent,

      bottom: ButtonInAppBar(showBars: showBars, repository: authRepository),
    );
  }
}
