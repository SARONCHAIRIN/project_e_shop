import 'package:e_shop/Presentation/screen/profile_main_page/setting_page.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';
import '../models/navigation_item.dart';

class DesktopSidebar extends StatefulWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;
  final dynamic authRepository;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.authRepository,
    this.isExpanded = true,
    this.onToggleExpand,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  late bool _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.isExpanded;
  }

  void _toggleSidebar() {
    if (widget.onToggleExpand != null) {
      widget.onToggleExpand!();
    } else {
      setState(() {
        _internalExpanded = !_internalExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expanded = widget.onToggleExpand != null
        ? widget.isExpanded
        : _internalExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: expanded ? 210 : 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F2),
        border: Border(right: BorderSide(color: Color(0xFFEFE5DC), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header & Toggle Button ──────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              expanded ? 22 : 16,
              28,
              expanded ? 22 : 16,
              20,
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (expanded)
                  Expanded(
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
                                color: Colors.orangeAccent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "E-Shop Central",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.2,
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
                    ),
                  )
                else
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
          // Collapse/Expand Toggle Icon Button
          IconButton(
            onPressed: _toggleSidebar,
            icon: Icon(
              expanded ? Icons.menu_open_outlined : Icons.menu_rounded,
              color: const Color(0xFF1A1A2E),
              size: 20,
            ),
            splashRadius: 20,
            tooltip: expanded ? "Collapse Sidebar" : "Expand Sidebar",
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Divider(color: Color(0xFFEADCCF), height: 1),
          ),

          // ── Main Navigation List ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 16 : 10,
                vertical: 12,
              ),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _SidebarDestination(
                  icon: item.icon,
                  label: item.label,
                  selected: index == widget.currentIndex,
                  isExpanded: expanded,
                  onTap: () => widget.onTap(index),
                );
              },
            ),
          ),

          // === Logout Footer Item
          Padding(
            padding: EdgeInsets.fromLTRB(
              expanded ? 16 : 10,
              0,
              expanded ? 16 : 10,
              10,
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  final tokenStorage = TokenStorage();
                  await tokenStorage.clearAll();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(expanded ? 12 : 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE5DC)),
                  ),
                  child: Row(
                    mainAxisAlignment: expanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 20,
                          color: Colors.red,
                        ),
                      ),
                      if (expanded) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sign out from your account',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
        ],
      ),
    );
  }
}

class _SidebarDestination extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_SidebarDestination> createState() => _SidebarDestinationState();
}

class _SidebarDestinationState extends State<_SidebarDestination> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color background;
    if (widget.selected) {
      background = Colors.orangeAccent;
    } else if (_hovering) {
      background = Colors.orange.withOpacity(0.08);
    } else {
      background = Colors.transparent;
    }

    final Color foreground = widget.selected
        ? Colors.white
        : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 14 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: widget.isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 20, color: foreground),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: foreground,
                        fontWeight: widget.selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
