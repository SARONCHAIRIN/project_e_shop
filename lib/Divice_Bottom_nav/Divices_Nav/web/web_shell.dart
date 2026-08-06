import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/web/web_topbar.dart';
import 'package:flutter/material.dart';

import '../../../Main_App_Bar/web/web_app_bar.dart';
import '../../../data/repositories/auth/auth_repository.dart';

class WebShell extends StatelessWidget {
  final Widget? topBar;
  final Widget sidebar;
  final Widget child;
  final AuthRepository? authRepository;


  const WebShell({
    super.key,
    this.topBar,
    required this.sidebar,
    required this.child,
     this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // if (topBar != null) topBar!,

           // WebTopBar(showBars: true, authRepository: authRepository,),

            Expanded(
              child: Row(
                children: [
                  sidebar,

                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                  ),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1600,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}