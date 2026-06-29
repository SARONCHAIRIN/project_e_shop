


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';

/// Brand tokens for the auth flow. Keeping these in one place makes the
/// "frosted glass over a navy-to-violet gradient, single gold accent" look
/// consistent across every auth screen instead of being re-guessed per file.
class _Palette {
  static const bgTop = Color(0xFF0B1120);
  static const bgMid = Color(0xFF182447);
  static const bgBottom = Color(0xFF2D1B4E);

  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);

  static const glass = Color(0x14FFFFFF); // white @ ~8%
  static const glassBorder = Color(0x2EFFFFFF); // white @ ~18%

  static const coral = Color(0xFFFF6B6B);
  static const mint = Color(0xFF35D07F);
  static const amber = Color(0xFFFFB020);
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    _animController.dispose();
    super.dispose();
  }

  // --- Password strength: a quick, honest signal, not a security claim ---
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
    if (s < 0.34) return 'Weak';
    if (s < 0.7) return 'Fair';
    return 'Strong';
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack(
        'Please agree to the Terms of Service and Privacy Policy to continue.',
        isError: true,
      );
      return;
    }

    try {
      final success =
      await ref.read(authControllerProvider.notifier).register(
        RegisterRequest(
          username: username.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
          password: password.text.trim(),
        ),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushNamed(
          context,
          '/otp-verify',
          arguments: email.text.trim(),
        );
      } else {
        final error =
            ref.read(authControllerProvider).error ??
                'Registration failed';

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
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14.5, fontWeight: FontWeight.w500),
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
      backgroundColor: const Color(0xFF0B1120),
      body: Stack(
        children: [
          // Background photo
          Positioned.fill(
            child: Image.asset('assets/images/back_image.png', fit: BoxFit.fill),
          ),

          // Brand-tinted scrim so the glass card always has consistent
          // contrast, regardless of the underlying photo.
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

          SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                            decoration: BoxDecoration(
                              color: _Palette.glass,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: _Palette.glassBorder, width: 1.2),
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
                              // autovalidateMode: AutovalidateMode.onUserInteraction,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge
                                    Center(
                                      child: Container(
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
                                            BoxShadow(
                                              color: _Palette.gold.withOpacity(0.4),
                                              blurRadius: 18,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: _Palette.goldText,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Step indicator — there really are two steps
                                    // (register, then verify), so this carries
                                    // real information rather than decoration.
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: _Palette.gold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 1),
                                        Expanded(
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: Colors.white.withOpacity(0.18),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Save items, track orders, and check out faster.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Username
                                    TextFormField(
                                      controller: username,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: _decoration(
                                        label: 'Full name',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (v) =>
                                      v != null && v.trim().isNotEmpty ? null : 'Required',
                                    ),
                                    const SizedBox(height: 12),

                                    // Email
                                    TextFormField(
                                      controller: email,
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: _decoration(
                                        label: 'Email',
                                        icon: Icons.mail_outline,
                                      ),
                                      validator: (v) =>
                                      v != null && v.contains('@') ? null : 'Enter a valid email',
                                    ),
                                    const SizedBox(height: 12),

                                    // Phone
                                    TextFormField(
                                      controller: phone,
                                      keyboardType: TextInputType.phone,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: _decoration(
                                        label: 'Phone number',
                                        icon: Icons.phone_iphone_outlined,
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Phone number is required';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Password
                                    TextFormField(
                                      controller: password,
                                      obscureText: _obscurePassword,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: _decoration(
                                        label: 'Password',
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white60,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      validator: (v) =>
                                      v != null && v.length >= 6 ? null : 'Use at least 6 characters',
                                    ),

                                    // Strength meter — only shown once typing starts
                                    AnimatedBuilder(
                                      animation: password,
                                      builder: (context, _) {
                                        if (password.text.isEmpty) {
                                          return const SizedBox(height: 6);
                                        }
                                        final strength = _passwordStrength(password.text);
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(3),
                                                  child: LinearProgressIndicator(
                                                    value: strength,
                                                    minHeight: 4,
                                                    backgroundColor: Colors.white.withOpacity(0.12),
                                                    valueColor: AlwaysStoppedAnimation(
                                                      _strengthColor(strength),
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
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Confirm password
                                    TextFormField(
                                      controller: confirmPassword,
                                      obscureText: _obscureConfirm,
                                      cursorColor: _Palette.gold,
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                      decoration: _decoration(
                                        label: 'Confirm password',
                                        icon: Icons.lock_outline,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirm
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: Colors.white60,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              setState(() => _obscureConfirm = !_obscureConfirm),
                                        ),
                                      ),
                                      validator: (v) =>
                                      v == password.text ? null : 'Passwords do not match',
                                    ),
                                    const SizedBox(height: 14),

                                    // Terms checkbox
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _agreedToTerms,
                                            onChanged: (v) =>
                                                setState(() => _agreedToTerms = v ?? false),
                                            checkColor: _Palette.goldText,
                                            activeColor: _Palette.gold,
                                            side: BorderSide(color: Colors.white.withOpacity(0.4)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text.rich(
                                              TextSpan(
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.65),
                                                  fontSize: 12.5,
                                                  height: 1.4,
                                                ),
                                                children: const [
                                                  TextSpan(text: 'I agree to the '),
                                                  TextSpan(
                                                    text: 'Terms of Service',
                                                    style: TextStyle(
                                                      color: _Palette.gold,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextSpan(text: ' and '),
                                                  TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                      color: _Palette.gold,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  TextSpan(text: '.'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Submit button
                                    SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: const LinearGradient(
                                            colors: [_Palette.gold, _Palette.goldDeep],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
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
                                            onTap: isLoading ? null : _handleRegister,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 15),
                                              child: Center(
                                                child: isLoading
                                                    ? const SpinKitDualRing(
                                                  color: _Palette.goldText,
                                                  size: 22,
                                                  lineWidth: 3,
                                                )
                                                    : const Text(
                                                  'Create account',
                                                  style: TextStyle(
                                                    color: _Palette.goldText,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            } else {
                                              // Navigator.pushReplacement(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (_) =>  LoginScreen(),
                                              //   ),
                                              // );
                                            }
                                          },
                                          child: const Text(
                                            'Log in',
                                            style: TextStyle(
                                              color: _Palette.gold,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
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

          // Back button — glass pill, matches the card language
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