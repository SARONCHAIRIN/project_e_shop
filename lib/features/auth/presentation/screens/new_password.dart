import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';

class _Palette {
  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);
  static const glass = Color(0x14FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const coral = Color(0xFFFF6B6B);
  static const mint = Color(0xFF35D07F);
  static const amber = Color(0xFFFFB020);
}

class NewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const NewPasswordScreen({super.key, required this.email, required this.code});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);
  Animation<Offset> _slideAnim = const AlwaysStoppedAnimation(Offset.zero);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
    _password.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _password.removeListener(_onPasswordChanged);
    _password.dispose();
    _confirmPassword.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  double _passwordStrength(String pw) {
    if (pw.isEmpty) return 0;
    double score = 0;
    if (pw.length >= 6) score += 0.34;
    if (pw.length >= 10) score += 0.33;
    if (RegExp(r'[0-9]').hasMatch(pw) && RegExp(r'[A-Za-z]').hasMatch(pw)) {
      score += 0.33;
    }
    return score.clamp(0, 1);
  }

  Color _strengthColor(double s) {
    if (s < 0.34) return _Palette.coral;
    if (s < 0.7) return _Palette.amber;
    return _Palette.mint;
  }

  String _strengthLabel(double s) {
    if (s == 0) return '';
    if (s < 0.34) return 'password_strength_weak'.tr();
    if (s < 0.7) return 'password_strength_fair'.tr();
    return 'password_strength_strong'.tr();
  }

  bool get _lengthOk => _password.text.length >= 6;

  bool get _matchOk =>
      _confirmPassword.text.isNotEmpty &&
      _confirmPassword.text == _password.text;

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? _Palette.coral : const Color(0xFF1B2A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _submit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted)
      return;
    else {
      _showSnack( 'failed_reset_password'.tr(), isError: true);
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white70,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _Palette.gold, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(Colors.white.withOpacity(0.14), 1),
      border: border(Colors.white.withOpacity(0.14), 1),
      focusedBorder: border(_Palette.gold, 1.6),
      errorBorder: border(_Palette.coral, 1.2),
      focusedErrorBorder: border(_Palette.coral, 1.6),
      errorStyle: const TextStyle(color: _Palette.coral, fontSize: 12),
    );
  }

  Widget _checklistRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15,
            color: ok ? _Palette.mint : Colors.white.withOpacity(0.3),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: ok
                  ? Colors.white.withOpacity(0.85)
                  : Colors.white.withOpacity(0.45),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = state.isLoading;
    final strength = _passwordStrength(_password.text);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xE00B1120),
                    Color(0xD2182447),
                    Color(0xE62D1B4E),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 440,
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            10,
                      ),
                      child: SingleChildScrollView(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                26,
                                30,
                                26,
                                26,
                              ),
                              decoration: BoxDecoration(
                                color: _Palette.glass,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: _Palette.glassBorder,
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.28),
                                    blurRadius: 30,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Badge
                                    Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              _Palette.gold,
                                              _Palette.goldDeep,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _Palette.gold.withOpacity(
                                                0.4,
                                              ),
                                              blurRadius: 18,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.vpn_key_outlined,
                                          color: _Palette.goldText,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                     Text(
                                      'set_new_password'.tr(),
                                      style: TextStyle(
                                        color: _Palette.gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                     Text(
                                      'create_new_password'.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'new_password_description'.tr(),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 13.5,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // New password
                                    TextFormField(
                                      controller: _password,
                                      obscureText: _obscurePassword,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: _decoration(
                                        label: 'new_password'.tr(),
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white60,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          v != null && v.length >= 6
                                          ? null
                                          : 'use_at_least_6_characters'.tr(),
                                    ),

                                    // Strength meter
                                    if (_password.text.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 2,
                                          right: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                child: LinearProgressIndicator(
                                                  value: strength,
                                                  minHeight: 4,
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.12),
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        _strengthColor(
                                                          strength,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _strengthLabel(strength),
                                              style: TextStyle(
                                                color: _strengthColor(strength),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 12),

                                    // Confirm password
                                    TextFormField(
                                      controller: _confirmPassword,
                                      obscureText: _obscureConfirm,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: _decoration(
                                        label:  'confirm_password'.tr(),
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirm
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white60,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscureConfirm =
                                                !_obscureConfirm,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => v == _password.text
                                          ? null
                                          : 'passwords_do_not_match'.tr(),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    const SizedBox(height: 16),

                                    // Checklist
                                    _checklistRow(
                                      'at_least_6_characters'.tr(),
                                      _lengthOk,
                                    ),
                                    _checklistRow('passwords_match'.tr(), _matchOk),
                                    const SizedBox(height: 12),

                                    // Submit button
                                    SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          gradient: const LinearGradient(
                                            colors: [
                                              _Palette.gold,
                                              _Palette.goldDeep,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _Palette.gold.withOpacity(
                                                0.35,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            onTap: isLoading
                                                ? null
                                                : () => _submit(controller),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                  ),
                                              child: Center(
                                                child: isLoading
                                                    ? const SpinKitDualRing(
                                                        color:
                                                            _Palette.goldText,
                                                        size: 22,
                                                        lineWidth: 3,
                                                      )
                                                    :  Text(
                                                  'reset_password'.tr(),
                                                        style: TextStyle(
                                                          color:
                                                              _Palette.goldText,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 17,
                        color: Colors.white,
                      ),
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
