import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';

/// Brand tokens for the auth flow. Keeping these in one place makes the
/// "frosted glass over a navy-to-violet gradient, single gold accent" look
/// consistent across every auth screen instead of being re-guessed per file.
class _Palette {
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
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
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
    if (s < 0.34) return'weak'.tr();
    if (s < 0.7) return 'fair'.tr();
    return 'strong'.tr();
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
        'agree_terms'.tr(),
        isError: true,
      );
      return;
    }

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .register(
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
            ref.read(authControllerProvider).error ??  'registration_failed'.tr();
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
      backgroundColor: const Color(0xFF0B1120),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine layout breakpoints for cross-platform responsiveness
          final isDesktop = constraints.maxWidth >= 900;

          return Stack(
            children: [
              // Background photo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/back1_orange.jpg',
                  fit: BoxFit.fill,
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

              // Main Responsive Content Area
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 24,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 480 : 440,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                              child: Container(
                                padding: EdgeInsets.all(isDesktop ? 32 : 20),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                color: _Palette.gold
                                                    .withOpacity(0.4),
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
                                      const SizedBox(height: 16),

                                      // Step indicator
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                color: _Palette.gold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                color: Colors.white.withOpacity(
                                                  0.18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                       Text(
                                        'step_create_account'.tr(),
                                        style: TextStyle(
                                          color: _Palette.gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                       Text(
                                         'create_account'.tr(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
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

                                      // Username
                                      TextFormField(
                                        controller: username,
                                        cursorColor: _Palette.gold,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: _decoration(
                                          label:   'full_name'.tr(),
                                          icon: Icons.person_outline,
                                        ),
                                        validator: (v) =>
                                            v != null && v.trim().isNotEmpty
                                            ? null
                                            : 'required'.tr(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Email
                                      TextFormField(
                                        controller: email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        cursorColor: _Palette.gold,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: _decoration(
                                          label: 'email'.tr(),
                                          icon: Icons.mail_outline,
                                        ),
                                        validator: (v) =>
                                            v != null && v.contains('@')
                                            ? null
                                            : 'valid_email'.tr(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Phone
                                      TextFormField(
                                        controller: phone,
                                        keyboardType: TextInputType.phone,
                                        cursorColor: _Palette.gold,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: _decoration(
                                          label: 'phone_number'.tr(),
                                          icon: Icons.phone_iphone_outlined,
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'phone_required'.tr();
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Password
                                      TextFormField(
                                        controller: password,
                                        obscureText: _obscurePassword,
                                        cursorColor: _Palette.gold,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: _decoration(
                                          label:  'password'.tr(),
                                          icon: Icons.lock_outline,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
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
                                            :'password_min'.tr(),
                                      ),

                                      // Strength meter
                                      AnimatedBuilder(
                                        animation: password,
                                        builder: (context, _) {
                                          if (password.text.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          final strength = _passwordStrength(
                                            password.text,
                                          );
                                          return Padding(
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
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                    child: LinearProgressIndicator(
                                                      value: strength,
                                                      minHeight: 4,
                                                      backgroundColor: Colors
                                                          .white
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
                                                    color: _strengthColor(
                                                      strength,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm password
                                      TextFormField(
                                        controller: confirmPassword,
                                        obscureText: _obscureConfirm,
                                        cursorColor: _Palette.gold,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: _decoration(
                                          label: 'confirm_password'.tr(),
                                          icon: Icons.lock_outline,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirm
                                                  ? Icons
                                                        .visibility_off_outlined
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
                                        validator: (v) => v == password.text
                                            ? null
                                            :  'password_match'.tr(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Terms checkbox
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Checkbox(
                                              value: _agreedToTerms,
                                              onChanged: (v) => setState(
                                                () =>
                                                    _agreedToTerms = v ?? false,
                                              ),
                                              checkColor: _Palette.goldText,
                                              activeColor: _Palette.gold,
                                              side: BorderSide(
                                                color: Colors.white.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                              ),
                                              child: Text.rich(
                                                TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.65),
                                                    fontSize: 12.5,
                                                    height: 1.4,
                                                  ),
                                                  children:  [
                                                    TextSpan(
                                                      text: 'terms_message'.tr(),
                                                    ),
                                                    TextSpan(
                                                      text: 'terms_of_service'.tr(),
                                                      style: TextStyle(
                                                        color: _Palette.gold,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    TextSpan(text: ' and '),
                                                    TextSpan(
                                                      text: 'privacy_policy'.tr(),
                                                      style: TextStyle(
                                                        color: _Palette.gold,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                      const SizedBox(height: 24),

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
                                                color: _Palette.gold
                                                    .withOpacity(0.35),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: isLoading
                                                  ? null
                                                  : _handleRegister,
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
                                                    'create_account'.tr(),
                                                          style: TextStyle(
                                                            color: _Palette
                                                                .goldText,
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
                                      const SizedBox(height: 20),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'already_have_account'.tr(),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            onPressed: () {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child:  Text(
                                              'login'.tr(),
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

              // Back button — adaptive positioning for web/desktop bounds
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
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
          );
        },
      ),
    );
  }
}
