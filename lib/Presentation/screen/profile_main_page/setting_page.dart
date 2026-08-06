import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../Divice_Bottom_nav/Divices_Nav/nav_divices.dart';
import '../../../core/storage/token_storage.dart';
import 'language_bottom_sheet.dart';

class SettingPage extends StatefulWidget {
  final authRepository;

  const SettingPage({super.key, required this.authRepository});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool ison_notification = false;
  bool ison_email = false;

  String? _username;
  String? _email;
  String? _imageUrl;

  // TODO: wire to real loyalty data if you have it.
  int _coinBalance = 0;
  String _tierName = "bronze".tr();
  int _tierPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final storage = TokenStorage();
    final name = await storage.readUsername();
    final email = await storage.readUserEmail();
    final image = await storage.readUserImage();

    if (mounted) {
      setState(() {
        _username = name;
        _email = email;
        _imageUrl = image;
      });
    }
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return LanguageBottomSheet(
          currentLocale: context.locale,
          onSelected: (locale) {
            context.setLocale(locale);
            Navigator.pop(sheetContext);
            setState(() {}); // refresh trailingText immediately
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'setting'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),

            //account
            _sectionLabel('account'.tr()),
            _buildCardGroup([
              _settingRow(
                icon: Icons.person_outline,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "editProfile".tr(),
                onTap: () async {
                  try {
                    final tokenStorage = TokenStorage();
                    final token = await tokenStorage.getToken();
                    final username = await tokenStorage.getUsername();
                    final email = await tokenStorage.readUserEmail();

                    if (token != null && username != null && email != null) {
                      // TODO: uncomment and point to your real edit-profile screen
                      // await Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ProfileScreen(
                      //       username: username,
                      //       token: token,
                      //       email: email,
                      //     ),
                      //   ),
                      // );
                    }
                  } catch (e) {
                    debugPrint("Error: $e");
                  }
                },
              ),
              _divider(),
              _settingRow(
                icon: Icons.location_on_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "shippingAddress".tr(),
                onTap: () {
                  // TODO: navigate to shipping address screen
                },
              ),
              _divider(),
              _settingRow(
                icon: Icons.payments_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "paymentMethods".tr(),
                onTap: () {
                  // TODO: navigate to payment methods screen
                },
              ),
            ]),
            const SizedBox(height: 24),

            //notification
            _sectionLabel('notification'.tr()),
            _buildCardGroup([
              _switchRow(
                icon: Icons.notifications_active_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "pushNotifications".tr(),
                subtitle: "pushNotificationsSubtitle".tr(),
                value: ison_notification,
                onChanged: (v) => setState(() => ison_notification = v),
              ),
              _divider(),
              _switchRow(
                icon: Icons.email_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "emailAlerts".tr(),
                subtitle: "emailAlertsSubtitle".tr(),
                value: ison_email,
                onChanged: (v) => setState(() => ison_email = v),
              ),
            ]),
            const SizedBox(height: 24),

            //preferences
            _sectionLabel('preferences'.tr()),
            _buildCardGroup([
              _settingRow(
                icon: Icons.language,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: 'language'.tr(),
                trailingText: "languageEnglishUs".tr(),
                onTap: () => _showLanguageSheet(context),
              ),
              _divider(),
              _settingRow(
                icon: Icons.currency_exchange_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "currency".tr(),
                trailingText: "currencyUsd".tr(),
                onTap: () {
                  // TODO: open currency picker
                },
              ),
            ]),
            const SizedBox(height: 24),

            //legal
            _sectionLabel('legal'.tr()),
            _buildCardGroup([
              _settingRow(
                icon: Icons.privacy_tip_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "privacyPolicy".tr(),
                onTap: () {
                  // TODO: navigate to privacy policy screen
                },
              ),
              _divider(),
              _settingRow(
                icon: Icons.text_snippet_outlined,
                iconBg: Colors.blue.shade50,
                iconColor: Colors.indigoAccent,
                title: "termsOfService".tr(),
                onTap: () {
                  // TODO: navigate to terms of service screen
                },
              ),
            ]),
            const SizedBox(height: 28),

            _buildLogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Profile header card (orange gradient) ──
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade400,
            child: ClipOval(child: _buildAvatar(size: 60)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username?.isNotEmpty == true ? _username! : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _email ?? 'user@email.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _pill(
                      icon: Icons.monetization_on,
                      iconColor: Colors.amber.shade200,
                      label: '$_coinBalance',
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      icon: Icons.military_tech,
                      iconColor: Colors.brown.shade100,
                      label: '$_tierName · $_tierPoints pts',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({double size = 60}) {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _initialAvatar(size),
      );
    }
    return _initialAvatar(size);
  }

  Widget _initialAvatar(double size) {
    final name = _username?.isNotEmpty == true ? _username! : 'U';
    return Center(
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Section label (grey caps) ──
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  // ── White rounded card wrapping a list of rows ──
  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.shade100,
    indent: 16,
    endIndent: 16,
  );

  // ── Row with chevron / navigation ──
  Widget _settingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? trailingText,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  trailingText,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            if (showChevron)
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Row with a toggle switch (notifications) ──
  Widget _switchRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ── Logout button ──
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: const Icon(
                  Icons.phonelink_lock_outlined,
                  size: 48,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "logoutAccount".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                content: Text(
                  "logoutConfirmation".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "logout".tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          );

          if (confirm != true) return;

          await widget.authRepository.logout();

          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => DivicesNav(authRepository: widget.authRepository),
            ),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'logout'.tr(),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 1,
          shadowColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
