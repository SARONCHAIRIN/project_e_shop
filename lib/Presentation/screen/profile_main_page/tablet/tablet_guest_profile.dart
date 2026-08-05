import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:e_shop/features/auth/presentation/providers/auth_providers.dart';
import 'package:e_shop/core/storage/token_storage.dart';

import '../../../../features/auth/data/models/auth_models.dart';

/// Shared brand tokens — matches RegisterScreen / WebGuestProfile /
/// DesktopGuestProfile so the whole auth flow reads as one product.
class _Palette {
  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);

  static const glass = Color(0x14FFFFFF); // white @ ~8%
  static const glassBorder = Color(0x2EFFFFFF); // white @ ~18%

  static const coral = Color(0xFFFF6B6B);

  static const bg = Color(0xFF0B1120);
}

class TabletGuestProfile extends ConsumerStatefulWidget {
  final User_AuthRepository repository;

  const TabletGuestProfile({super.key, required this.repository});

  @override
  ConsumerState<TabletGuestProfile> createState() => _TabletGuestProfileState();
}

class _TabletGuestProfileState extends ConsumerState<TabletGuestProfile>
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

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isSignUpMode = !_isSignUpMode;
        _animController
          ..reset()
          ..forward();
      });
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
      backgroundColor: _Palette.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back1_orange.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useSideBySide = constraints.maxWidth >= 760;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: useSideBySide ? 900 : 480,
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(20),
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
                                  // FIX: Wrapped the side-by-side Row children in Expanded
                                  // so they properly bound their layout constraints inside
                                  // the unconstrained height of SingleChildScrollView + Column.
                                  child: useSideBySide
                                      ? IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: _panels(isLoading, compact: false),
                                    ),
                                  )
                                      : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _panels(isLoading, compact: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _panels(bool isLoading, {required bool compact}) {
    final info = _infoPanel(
      title: _isSignUpMode ? 'Welcome Back!' : 'Hello, Friend!',
      subtitle: _isSignUpMode
          ? 'To keep connected with us please login with your personal info'
          : 'Enter your personal details and start your journey with us',
      buttonLabel: _isSignUpMode ? 'SIGN IN' : 'SIGN UP',
      onPressed: _toggleMode,
      compact: compact,
    );
    final form = _isSignUpMode ? _registerPanel(isLoading, compact: compact) : _loginPanel(isLoading, compact: compact);

    if (compact) {
      return [info, form];
    }
    return _isSignUpMode ? [info, form] : [form, info];
  }

  Widget _infoPanel({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
    required bool compact,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 48 : 60,
          height: compact ? 48 : 60,
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
          child: Icon(Icons.shopping_bag_outlined, color: _Palette.goldText, size: compact ? 22 : 28),
        ),
        SizedBox(height: compact ? 14 : 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: compact ? 22 : 30, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: compact ? 13 : 14.5, height: 1.5),
        ),
        SizedBox(height: compact ? 18 : 32),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: _Palette.gold,
            side: const BorderSide(color: _Palette.gold, width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: compact ? 36 : 48, vertical: compact ? 12 : 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ],
    );

    final decoratedBox = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2A4A), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: compact
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : null,
      ),
      padding: EdgeInsets.all(compact ? 28 : 48),
      child: content,
    );

    // FIX: Wrapped in Expanded so it correctly fills available space inside IntrinsicHeight + Row
    return compact ? decoratedBox : Expanded(flex: 5, child: decoratedBox);
  }

  Widget _loginPanel(bool isLoading, {required bool compact}) {
    final form = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 28 : 48, vertical: compact ? 28 : 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'STEP 1 OF 1 · SIGN IN',
              style: TextStyle(color: _Palette.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in to E-Shop',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Welcome back — we kept your cart just as you left it.',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                _socialIcon(Icons.facebook),
                const SizedBox(width: 12),
                _socialIcon(Icons.g_mobiledata),
                const SizedBox(width: 12),
                _socialIcon(Icons.work_outline),
              ],
            ),
            const SizedBox(height: 14),
            Text('or use your email account:', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.5)),
            const SizedBox(height: 20),

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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen()));
                },
                child: Text('Forgot your password?', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
              ),
            ),
            const SizedBox(height: 8),

            _goldButton(label: 'SIGN IN', isLoading: isLoading, onTap: _handleLogin),

            if (compact) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    onPressed: _toggleMode,
                    child: const Text('Sign up', style: TextStyle(color: _Palette.gold, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    // FIX: Wrapped in Expanded so it correctly fills available space inside IntrinsicHeight + Row
    return compact ? form : Expanded(flex: 6, child: Center(child: SingleChildScrollView(child: form)));
  }

  Widget _registerPanel(bool isLoading, {required bool compact}) {
    final form = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 28 : 48, vertical: compact ? 28 : 24),
      child: Form(
        key: _regFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'STEP 1 OF 2 · CREATE ACCOUNT',
              style: TextStyle(color: _Palette.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your account',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Save items, track orders, and check out faster.',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                _socialIcon(Icons.facebook),
                const SizedBox(width: 12),
                _socialIcon(Icons.g_mobiledata),
                const SizedBox(width: 12),
                _socialIcon(Icons.work_outline),
              ],
            ),
            const SizedBox(height: 14),
            Text('or use your email for registration:', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12.5)),
            const SizedBox(height: 20),

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
            const SizedBox(height: 22),

            _goldButton(label: 'SIGN UP', isLoading: isLoading, onTap: _handleRegister),

            if (compact) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    onPressed: _toggleMode,
                    child: const Text('Log in', style: TextStyle(color: _Palette.gold, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

    // FIX: Wrapped in Expanded so it correctly fills available space inside IntrinsicHeight + Row
    return compact ? form : Expanded(flex: 6, child: Center(child: SingleChildScrollView(child: form)));
  }

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