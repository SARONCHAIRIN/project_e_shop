import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../data/repositories/user_auth_repository.dart';
import '../../../features/auth/data/models/auth_models.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/auth/presentation/screens/forgot_password_screen.dart';

class _Palette {
  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);

  static const glass = Color(0x14FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);

  static const coral = Color(0xFFFF6B6B);

  static const bg = Color(0xFF0B1120);
}

class WebGuestOrder extends ConsumerStatefulWidget {
  final User_AuthRepository repository;
  final VoidCallback? onLoginSuccess;

  const WebGuestOrder({
    super.key,
    required this.repository,
    this.onLoginSuccess,
  });

  @override
  ConsumerState<WebGuestOrder> createState() => _WebGuestOrderState();
}

class _WebGuestOrderState extends ConsumerState<WebGuestOrder>
    with SingleTickerProviderStateMixin {
  bool _isSignUpMode = false;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regUsernameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const _slideDuration = Duration(milliseconds: 650);
  static const _contentFadeDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();

    _animationController.dispose();

    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
  }

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

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);

    await controller.login(
      LoginRequest(
        identifier: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      ),
    );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    if (state.error == null && state.data != null) {
      final userId = state.data!.userId;

      if (userId != null) {
        await TokenStorage().saveUserId(userId);
      }

      if (!mounted) return;

      // Tell DesktopNav that login succeeded.
      widget.onLoginSuccess?.call();

      _showSnack('login_success'.tr());
    } else {
      _showSnack(state.error ?? 'invalid_credentials'.tr(), isError: true);
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) {
      return;
    }

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .register(
            RegisterRequest(
              username: _regUsernameController.text.trim(),
              email: _regEmailController.text.trim(),
              phone: _regPhoneController.text.trim(),
              password: _regPasswordController.text.trim(),
            ),
          );

      if (!mounted) return;

      if (success) {
        Navigator.pushNamed(
          context,
          '/otp-verify',
          arguments: _regEmailController.text.trim(),
        );
      } else {
        final error =
            ref.read(authControllerProvider).error ??
            'registration_failed'.tr();

        _showSnack(error, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString(), isError: true);
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: _Palette.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back1_orange.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const SizedBox.shrink();
              },
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
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                      minHeight: 650,
                      maxHeight: 700,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _Palette.glass,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: _Palette.glassBorder,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 34,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;

                                final overlayWidth = totalWidth * (5 / 11);

                                final formWidth = totalWidth - overlayWidth;

                                return Stack(
                                  children: [
                                    // ==================================================
                                    // FORM
                                    // ==================================================
                                    AnimatedPositioned(
                                      duration: _slideDuration,
                                      curve: Curves.easeInOutCubic,
                                      top: 0,
                                      bottom: 0,
                                      left: _isSignUpMode ? overlayWidth : 0,
                                      width: formWidth,
                                      child: ClipRect(
                                        child: AnimatedSwitcher(
                                          duration: _contentFadeDuration,
                                          child: _isSignUpMode
                                              ? KeyedSubtree(
                                                  key: const ValueKey(
                                                    'register',
                                                  ),
                                                  child: _registerPanel(
                                                    isLoading,
                                                  ),
                                                )
                                              : KeyedSubtree(
                                                  key: const ValueKey('login'),
                                                  child: _loginPanel(isLoading),
                                                ),
                                        ),
                                      ),
                                    ),

                                    // ==================================================
                                    // INFO PANEL
                                    // ==================================================
                                    AnimatedPositioned(
                                      duration: _slideDuration,
                                      curve: Curves.easeInOutCubic,
                                      top: 0,
                                      bottom: 0,
                                      left: _isSignUpMode ? 0 : formWidth,
                                      width: overlayWidth,
                                      child: _infoPanel(),
                                    ),
                                  ],
                                );
                              },
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
        ],
      ),
    );
  }

  // ============================================================
  // INFO PANEL
  // ============================================================

  Widget _infoPanel() {
    final title = _isSignUpMode
        ? 'welcome_back'.tr()
        : 'order_guest_title'.tr();

    final subtitle = _isSignUpMode
        ? 'keep_connected'.tr()
        : 'order_guest_description'.tr();

    final buttonLabel = _isSignUpMode ? 'sign_in'.tr() : 'sign_up'.tr();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B2A4A), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_Palette.gold, _Palette.goldDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: _Palette.gold.withOpacity(0.4),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: _Palette.goldText,
              size: 32,
            ),
          ),

          const SizedBox(height: 26),

          AnimatedSwitcher(
            duration: _contentFadeDuration,
            child: Column(
              key: ValueKey(_isSignUpMode),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.5,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 32),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.gold,
                    side: const BorderSide(color: _Palette.gold, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _toggleMode,
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN PANEL
  // ============================================================

  Widget _loginPanel(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'order_guest_step'.tr(),
                  style: const TextStyle(
                    color: _Palette.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'order_login_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'order_login_description'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13.5,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _loginEmailController,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'email_or_username'.tr(),
                    icon: Icons.mail_outline,
                  ),
                  validator: (v) {
                    return v == null || v.trim().isEmpty
                        ? 'required'.tr()
                        : null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: _obscureLoginPassword,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'password'.tr(),
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    return v == null || v.isEmpty ? 'required'.tr() : null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'forgot_password'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                _goldButton(
                  label: 'sign_in'.tr(),
                  isLoading: isLoading,
                  onTap: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REGISTER PANEL
  // ============================================================

  Widget _registerPanel(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _regFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'step_create_account'.tr(),
                  style: const TextStyle(
                    color: _Palette.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'create_account'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'description'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13.5,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _regUsernameController,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'full_name'.tr(),
                    icon: Icons.person_outline,
                  ),
                  validator: (v) {
                    return v == null || v.trim().isEmpty
                        ? 'required'.tr()
                        : null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'email'.tr(),
                    icon: Icons.mail_outline,
                  ),
                  validator: (v) {
                    return v != null && v.contains('@')
                        ? null
                        : 'valid_email'.tr();
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _regPhoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'phone_number'.tr(),
                    icon: Icons.phone_iphone_outlined,
                  ),
                  validator: (v) {
                    return v == null || v.trim().isEmpty
                        ? 'phone_required'.tr()
                        : null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _regPasswordController,
                  obscureText: _obscureRegPassword,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'password'.tr(),
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureRegPassword = !_obscureRegPassword;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    return v != null && v.length >= 6
                        ? null
                        : 'password_min'.tr();
                  },
                ),

                const SizedBox(height: 24),

                _goldButton(
                  label: 'sign_up'.tr(),
                  isLoading: isLoading,
                  onTap: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GOLD BUTTON
  // ============================================================

  Widget _goldButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [_Palette.gold, _Palette.goldDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: _Palette.gold.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? const SpinKitDualRing(
                      color: _Palette.goldText,
                      size: 22,
                      lineWidth: 3,
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: _Palette.goldText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
