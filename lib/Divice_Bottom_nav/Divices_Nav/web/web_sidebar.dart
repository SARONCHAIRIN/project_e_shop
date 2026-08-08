import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../Presentation/screen/profile_main_page/setting_page.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/repositories/user_auth_repository.dart';
import '../models/navigation_item.dart';
import '../nav_divices.dart';

class WebSidebar extends StatefulWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final User_AuthRepository authRepository;
  final ValueChanged<int> onTap;

  const WebSidebar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.authRepository,
    required this.onTap,
  });

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> {
  bool _isExpanded = true;

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isExpanded ? 210 : 80,
      // Expanded width vs Collapsed width
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F2),
        border: Border(right: BorderSide(color: Color(0xFFEFE5DC), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Brand / Logo Header Section with Toggle Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 20 : 16,
              vertical: 28,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/eshop_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "E-Shop Central",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Manager Dashboard",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Collapse / Expand Toggle Button Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 20 : 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _toggleSidebar,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: _isExpanded
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.center,
                  children: [
                    if (_isExpanded) ...[
                      const Text(
                        "Collapse",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      _isExpanded
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: Color(0xFFEADCCF)),
          ),

          // Section Title (Only shown when expanded)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'MAIN MENU',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // 2. Navigation Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: Tooltip(
                      message: _isExpanded ? '' : item.label,
                      child: InkWell(
                        onTap: () => widget.onTap(index),
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: Colors.orange.withOpacity(.08),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: _isExpanded ? 16 : 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.orangeAccent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: _isExpanded
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                              if (_isExpanded) ...[
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // === Settings
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 16 : 8,
              vertical: 6,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: Tooltip(
                message: _isExpanded ? '' : 'Settings',
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(authRepository: null),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(_isExpanded ? 12 : 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEFE5DC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: Colors.orange,
                          ),
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'App preferences',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === Logout
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isExpanded ? 12 : 8,
              vertical: 6,
            ),
            child: Tooltip(
              message: _isExpanded ? '' : 'logout'.tr(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),

                  // IMPORTANT: use onTap directly
                  onTap: () async {
                    debugPrint('========== LOGOUT CLICK ==========');

                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      barrierDismissible: true,
                      builder: (dialogContext) {
                        debugPrint('========== DIALOG CREATED ==========');

                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),

                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'logout_title'.tr(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          content: Text(
                            'logout_description'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          actionsPadding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            20,
                          ),

                          actions: [
                            OutlinedButton(
                              onPressed: () {
                                debugPrint('LOGOUT CANCEL');
                                Navigator.of(dialogContext).pop(false);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(110, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('cancel'.tr()),
                            ),

                            const SizedBox(width: 8),

                            ElevatedButton.icon(
                              onPressed: () {
                                debugPrint('LOGOUT CONFIRMED');
                                Navigator.of(dialogContext).pop(true);
                              },
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: Text('logout'.tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(120, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    debugPrint('DIALOG RESULT = $confirm');

                    if (confirm != true) {
                      debugPrint('LOGOUT CANCELLED');
                      return;
                    }

                    // Clear login data ONLY ONCE
                    debugPrint('CLEARING TOKEN...');

                    await TokenStorage().clearAll();

                    if (!mounted) return;

                    debugPrint('TOKEN CLEARED');
                    debugPrint('GOING TO GUEST NAVIGATION');

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DivicesNav(authRepository: widget.authRepository),
                      ),
                      (route) => false,
                    );
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(_isExpanded ? 12 : 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.055),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.12)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),

                        if (_isExpanded) ...[
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'logout'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  'logout_subtitle'.tr(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 6),

                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
