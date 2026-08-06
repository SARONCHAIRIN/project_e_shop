import 'package:flutter/material.dart';

class DesktopShell extends StatelessWidget {
  final Widget sidebar;

  final Widget child;

  const DesktopShell({super.key, required this.sidebar, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          sidebar,

          const VerticalDivider(width: 1),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),

                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
