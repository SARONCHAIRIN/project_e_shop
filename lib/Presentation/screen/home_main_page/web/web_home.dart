import 'package:flutter/material.dart';

import '../home_view_args.dart';

import 'web_home_body.dart';

class WebHome extends StatelessWidget {
  final HomeViewArgs args;

  const WebHome({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebHomeBody(args: args));
  }
}
