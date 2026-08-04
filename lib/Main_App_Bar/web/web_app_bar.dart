import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Presentation/screen/search/product_search.dart';

class WebAppBar extends StatelessWidget {
  final bool showBars;

  final dynamic authRepository;

  const WebAppBar({
    super.key,

    required this.showBars,

    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,

      floating: true,

      expandedHeight: 85,

      backgroundColor: Colors.orangeAccent,

      elevation: 2,

      title: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),

              child: Row(
                children: [
                  // ==================
                  // LOGO
                  // ==================
                  // Image.asset(
                  //   'assets/images/eshop_logo.png',
                  //
                  //   width: 45,
                  //
                  //   height: 45,
                  // ),
                  //
                  // const SizedBox(width: 12),
                  //
                  // const Text(
                  //   "E-Shop",
                  //
                  //   style: TextStyle(
                  //     fontSize: 26,
                  //
                  //     fontWeight: FontWeight.bold,
                  //
                  //     color: Colors.black87,
                  //   ),
                  // ),

                  const SizedBox(width: 40),

                  // ==================
                  // SEARCH
                  // ==================
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchProductpage(
                                repository: authRepository,
                              ),
                            ),
                          );
                        },
                        cursorColor: Colors.grey,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: "search_product".tr(),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 25),

                  // ==================
                  // MENU
                  // ==================
                  TextButton(onPressed: () {}, child: const Text("Home")),

                  TextButton(onPressed: () {}, child: const Text("Category")),

                  TextButton(onPressed: () {}, child: const Text("Orders")),

                  // ==================
                  // LANGUAGE
                  // ==================
                  IconButton(
                    onPressed: () {},

                    icon: const Icon(Icons.language),
                  ),

                  // ==================
                  // CART
                  // ==================
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},

                        icon: const Icon(Icons.shopping_cart),
                      ),

                      Positioned(
                        right: 6,

                        top: 6,

                        child: Container(
                          width: 18,

                          height: 18,

                          decoration: const BoxDecoration(
                            color: Colors.red,

                            shape: BoxShape.circle,
                          ),

                          child: const Center(
                            child: Text(
                              "2",

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ==================
                  // PROFILE
                  // ==================
                  IconButton(
                    onPressed: () {},

                    icon: const Icon(Icons.account_circle, size: 30),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
