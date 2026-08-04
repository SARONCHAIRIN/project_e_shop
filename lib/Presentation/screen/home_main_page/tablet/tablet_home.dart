import 'package:flutter/material.dart';

import '../home_view_args.dart';

import 'tablet_home_body.dart';

class TabletHome extends StatelessWidget {
  final HomeViewArgs args;

  const TabletHome({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TabletHomeBody(args: args));
  }
}
