import 'package:flutter/material.dart';

import 'web_category_body.dart';

class WebCategory extends StatelessWidget {
  final dynamic authRepository;

  const WebCategory({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6F8),

      body: Column(
        children: [
          /// TOP HEADER

          // const WebTopHeader(),
          Expanded(
            child: Row(
              children: [

                /// RIGHT
                Expanded(
                  child: WebCategoryBody(authRepository: authRepository),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
