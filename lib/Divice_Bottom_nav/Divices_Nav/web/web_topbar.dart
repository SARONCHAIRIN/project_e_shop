import 'package:e_shop/Presentation/screen/search/product_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;

class WebTopBar extends StatelessWidget {
  final bool showBars;
  final dynamic authRepository;

  const WebTopBar({
    super.key,
    required this.showBars,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.orangeAccent,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            children: [
              // ==================
              // LOGO
              // ==================
              Text(
                "E Shop",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

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
                      if (authRepository != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchProductpage(
                              repository: authRepository,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Authentication repository not initialized'),
                          ),
                        );
                      }
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

              const SizedBox(width: 30),

              // ==================
              // CART
              // ==================
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
              ),

              // ==================
              // PROFILE
              // ==================
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person),
              ),
            ],
          ),
        ),
      ),
    );
  }
}