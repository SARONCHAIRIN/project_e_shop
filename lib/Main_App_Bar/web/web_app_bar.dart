import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Presentation/screen/cart/cart_screen.dart';
import '../../Presentation/screen/search/product_search.dart';
import '../../core/storage/token_storage.dart';
import '../../provider/cart_provider.dart';

class WebAppBar extends StatefulWidget {
  final bool showBars;
  final dynamic authRepository;

  const WebAppBar({
    super.key,
    required this.showBars,
    required this.authRepository,
  });

  @override
  State<WebAppBar> createState() => _WebAppBarState();
}

class _WebAppBarState extends State<WebAppBar> {
  final GlobalKey _cartIconKey = GlobalKey();

  Widget _translate() {
    final isKhmer = context.locale.languageCode == 'km';
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<Locale>(
        padding: EdgeInsets.zero,
        offset: const Offset(0, 48),
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
        initialValue: context.locale,
        onSelected: (Locale locale) => context.setLocale(locale),
        itemBuilder: (context) => [
          _languageMenuItem(
            context,
            locale: const Locale('en', 'US'),
            flag: '🇬🇧',
            label: 'English',
            isSelected: !isKhmer,
          ),
          _languageMenuItem(
            context,
            locale: const Locale('km', 'KH'),
            flag: '🇰🇭',
            label: 'ខ្មែរ',
            isSelected: isKhmer,
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isKhmer ? '🇰🇭' : '🇬🇧',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                isKhmer ? 'KM' : 'EN',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<Locale> _languageMenuItem(
    BuildContext context, {
    required Locale locale,
    required String flag,
    required String label,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuItem(
      value: locale,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                                repository: widget.authRepository,
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ==================
                  // LANGUAGE (Custom Professional Widget)
                  // ==================
                  _translate(),

                  const SizedBox(width: 10),

                  // ==================
                  // CART (Riverpod + Stack design)
                  // ==================
                  Consumer(
                    builder: (context, ref, _) {
                      final cartState = ref.watch(cartControllerProvider);
                      final itemCount = cartState.cart?.totalItems ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          key: _cartIconKey,
                          onTap: () async {
                            final storage = TokenStorage();
                            final userId = await storage.getUserId();
                            final token = await storage.getToken();

                            if (userId != null && token != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CartScreen(userId: userId, token: token),
                                ),
                              );
                            }
                          },
                          child: Stack(
                            children: [
                              IconButton(
                                onPressed: null,
                                // Handled by outer GestureDetector
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ),
                              if (itemCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        itemCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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
