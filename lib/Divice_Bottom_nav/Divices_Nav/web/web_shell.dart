import 'package:flutter/material.dart';

class WebShell extends StatelessWidget {
  final Widget topBar;

  final Widget sidebar;

  final Widget child;

  const WebShell({
    super.key,

    required this.topBar,

    required this.sidebar,

    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          topBar,

          Expanded(
            child: Row(
              children: [
                sidebar,

                const VerticalDivider(width: 1),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),

                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
