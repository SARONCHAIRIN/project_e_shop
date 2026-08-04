import 'package:flutter/material.dart';

import '../home_view_args.dart';

import 'mobile_home_body.dart';

class MobileHome extends StatelessWidget {
  final HomeViewArgs args;

  const MobileHome({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MobileHomeBody(args: args));
  }
}
