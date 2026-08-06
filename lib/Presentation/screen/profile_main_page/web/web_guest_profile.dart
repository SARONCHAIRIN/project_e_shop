import 'dart:ui';
import 'package:e_shop/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/providers/auth_providers.dart';
import 'package:e_shop/core/storage/token_storage.dart';

import '../../../../features/auth/data/models/auth_models.dart';

/// Shared brand tokens — matches RegisterScreen so the whole auth flow reads
/// as one product: frosted glass over a navy-to-violet gradient, single
/// gold accent color, muted supporting colors for state (error/success/warn).
class _Palette {
  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);

  static const glass = Color(0x14FFFFFF); // white @ ~8%
  static const glassBorder = Color(0x2EFFFFFF); // white @ ~18%

  static const coral = Color(0xFFFF6B6B);
  static const mint = Color(0xFF35D07F);
  static const amber = Color(0xFFFFB020);

  static const bg = Color(0xFF0B1120);
}

class WebGuestProfile extends ConsumerStatefulWidget {
  final User_AuthRepository repository;

  const WebGuestProfile({super.key, required this.repository});

  @override
  ConsumerState<WebGuestProfile> createState() => _WebGuestProfileState();
}

class _WebGuestProfileState extends ConsumerState<WebGuestProfile>
    with SingleTickerProviderStateMixin {
  // Toggle true for "Create Account", false for "Sign In"
  bool _isSignUpMode = false;

  // Controllers for Login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Controllers for Register
  final _regUsernameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();

  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;

  // Page-entrance animation (fade + slight rise)
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Tuning for the smooth sliding toggle animation
  static const _slideDuration = Duration(milliseconds: 650);
  static const _slideCurve = Curves.easeInOutCubic;
  static const _contentFadeDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isSignUpMode = !_isSignUpMode);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? _Palette.coral : const Color(0xFFB3C4EA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

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
      await TokenStorage().saveUserId(state.data!.userId!);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/divicenav');
    } else {
      _showSnack(state.error ?? "Invalid credentials", isError: true);
    }
  }

  Future<void> _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;

    try {
      final success = await ref.read(authControllerProvider.notifier).register(
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
        final error = ref.read(authControllerProvider).error ?? 'Registration failed';
        _showSnack(error, isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Stack(
        children: [
          // Background photo
          Positioned.fill(
            child: Image.asset(
              'assets/images/back1_orange.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // Brand-tinted scrim
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
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100, minHeight: 700, maxHeight: 700),
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
                              border: Border.all(color: _Palette.glassBorder, width: 1.2),
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
                                // 5:6 ratio split matching the previous flex setup
                                final overlayWidth = totalWidth * (5 / 11);
                                final formWidth = totalWidth - overlayWidth;

                                return Stack(
                                  children: [
                                    // Sliding form panel container
                                    AnimatedPositioned(
                                      duration: _slideDuration,
                                      curve: _slideCurve,
                                      top: 0,
                                      bottom: 0,
                                      left: _isSignUpMode ? overlayWidth : 0,
                                      width: formWidth,
                                      child: ClipRect(
                                        child: AnimatedSwitcher(
                                          duration: _contentFadeDuration,
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          transitionBuilder: (child, animation) {
                                            final offset = Tween<Offset>(
                                              begin: const Offset(0, 0.06),
                                              end: Offset.zero,
                                            ).animate(animation);
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(position: offset, child: child),
                                            );
                                          },
                                          child: _isSignUpMode
                                              ? KeyedSubtree(
                                            key: const ValueKey('register-form'),
                                            child: _registerPanel(isLoading),
                                          )
                                              : KeyedSubtree(
                                            key: const ValueKey('login-form'),
                                            child: _loginPanel(isLoading),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Sliding Info / brand panel
                                    AnimatedPositioned(
                                      duration: _slideDuration,
                                      curve: _slideCurve,
                                      top: 0,
                                      bottom: 0,
                                      left: _isSignUpMode ? 0 : formWidth,
                                      width: overlayWidth,
                                      child: _infoPanelSliding(),
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

  // ── Sliding Info / brand panel ──
  Widget _infoPanelSliding() {
    final title = _isSignUpMode ? 'Welcome Back!' : 'Hello, Friend!';
    final subtitle = _isSignUpMode
        ? 'To keep connected with us please login with your personal info'
        : 'Enter your personal details and start your journey with us';
    final buttonLabel = _isSignUpMode ? 'SIGN IN' : 'SIGN UP';

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_Palette.gold, _Palette.goldDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: _Palette.gold.withOpacity(0.4), blurRadius: 18, spreadRadius: 1),
              ],
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: _Palette.goldText, size: 28),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: _contentFadeDuration,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: Column(
              key: ValueKey(_isSignUpMode),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14.5, height: 1.55),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.gold,
                    side: const BorderSide(color: _Palette.gold, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _toggleMode,
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign in form ──
  Widget _loginPanel(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'STEP 1 OF 1 · SIGN IN',
                  style: TextStyle(
                    color: _Palette.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to E-Shop',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back — we kept your cart just as you left it.',
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.g_mobiledata),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.work_outline),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'or use your email account:',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.5),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _loginEmailController,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(label: 'Email or Username', icon: Icons.mail_outline),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: _obscureLoginPassword,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _goldButton(
                  label: 'SIGN IN',
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

  // ── Register form ──
  Widget _registerPanel(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _regFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'STEP 1 OF 2 · CREATE ACCOUNT',
                  style: TextStyle(
                    color: _Palette.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create your account',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Save items, track orders, and check out faster.',
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    _socialIcon(Icons.facebook),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.g_mobiledata),
                    const SizedBox(width: 12),
                    _socialIcon(Icons.work_outline),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'or use your email for registration:',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.5),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _regUsernameController,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(label: 'Full name', icon: Icons.person_outline),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(label: 'Email', icon: Icons.mail_outline),
                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regPhoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(label: 'Phone number', icon: Icons.phone_iphone_outlined),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regPasswordController,
                  obscureText: _obscureRegPassword,
                  cursorColor: _Palette.gold,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _decoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white60,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
                    ),
                  ),
                  validator: (v) => v!.length >= 6 ? null : 'Min 6 chars',
                ),
                const SizedBox(height: 24),

                _goldButton(
                  label: 'SIGN UP',
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

  // ── Shared pieces ──
  Widget _goldButton({required String label, required bool isLoading, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [_Palette.gold, _Palette.goldDeep],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: _Palette.gold.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
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
                  ? const SpinKitDualRing(color: _Palette.goldText, size: 22, lineWidth: 3)
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

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Icon(icon, size: 20, color: Colors.white70),
    );
  }
}