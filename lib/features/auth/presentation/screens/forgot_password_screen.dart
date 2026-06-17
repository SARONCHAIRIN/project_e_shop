import 'dart:ui';
import 'package:e_shop/features/auth/presentation/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../controllers/auth_controller.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';

class _Palette {
  static const bgTop    = Color(0xFF0B1120);
  static const bgMid    = Color(0xFF182447);
  static const bgBottom = Color(0xFF2D1B4E);
  static const gold     = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);
  static const glass       = Color(0x14FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const coral = Color(0xFFFF6B6B);
  static const mint  = Color(0xFF35D07F);
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;


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
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
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

  // Future<void> _submit(AuthController controller) async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   final email = _emailController.text.trim();
  //
  //   final success = await controller.forgotPassword(
  //     ForgotPasswordRequest(email: email),
  //   );
  //
  //   if (!mounted) return;
  //
  //   if (success) {
  //     setState(() => _sent = true);
  //   } else {
  //     _showSnack('Something went wrong! Try again.', isError: true);
  //   }
  // }

  Future<void> _submit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    final success = await controller.forgotPassword(
      ForgotPasswordRequest(email: email),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _sent = true);
    } else {
      _showSnack('Something went wrong! Try again.', isError: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.error != null && previous?.error != next.error) {
        _showSnack(next.error!, isError: true);
      }
    });

    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background photo
          Positioned.fill(
            child: Image.asset('assets/images/back_image.png', fit: BoxFit.cover),
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

          // Main card
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 150),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 440,
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            10,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
                            decoration: BoxDecoration(
                              color: _Palette.glass,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: _Palette.glassBorder, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.28),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(opacity: animation, child: child),
                              child: _sent
                                  ? _SuccessView(
                                key: const ValueKey('success'),
                                email: _emailController.text.trim(),
                                onContinue: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtpScreen(
                                      email: _emailController.text.trim(),
                                    ),
                                  ),
                                ),
                                onResend: () async {
                                  final success = await controller
                                      .forgotPassword(ForgotPasswordRequest(
                                      email:
                                      _emailController.text.trim()));
                                  if (!mounted) return;
                                  _showSnack(
                                    success
                                        ? 'Reset code sent again'
                                        : 'Failed to resend code',
                                    isError: !success,
                                  );
                                },
                              )
                                  : _FormView(
                                key: const ValueKey('form'),
                                formKey: _formKey,
                                emailController: _emailController,
                                isLoading: isLoading,
                                onSubmit: () => _submit(controller),
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

// ── Form view ──────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
          color: Colors.white70, fontSize: 14.5, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: _Palette.gold, size: 20),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
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
              Icons.lock_reset_outlined,
              color: _Palette.goldText,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'RESET YOUR PASSWORD',
          style: TextStyle(
            color: _Palette.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),

        const Text(
          'Forgot password?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "No worries! Enter your registered email and we'll send you a reset code.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: _Palette.gold,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: _decoration(
              label: 'Email address',
              icon: Icons.mail_outline,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),

        // Send button
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
                onTap: isLoading ? null : onSubmit,
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
                      'Send reset code',
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
        const SizedBox(height: 18),

        // Back to login
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(Icons.arrow_back_ios, size: 13, color: Colors.white.withOpacity(0.6)),
            label: Text(
              'Back to login',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}

// ── Success view ───────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onContinue;
  final VoidCallback onResend;

  const _SuccessView({
    super.key,
    required this.email,
    required this.onContinue,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Badge
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_Palette.mint, Color(0xFF1E9B5E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _Palette.mint.withOpacity(0.4),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: Color(0xFF062415),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'CODE SENT',
          style: TextStyle(
            color: _Palette.mint,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),

        const Text(
          'Check your email',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We sent a reset code to',
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          email,
          style: const TextStyle(
            color: _Palette.gold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter it on the next screen to reset your password.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        // Continue button
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
                onTap: onContinue,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Enter reset code',
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
        const SizedBox(height: 16),

        // Didn't receive
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive it? ",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            GestureDetector(
              onTap: onResend,
              child: const Text(
                'Resend',
                style: TextStyle(
                  color: _Palette.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const Spacer(),
      ],
    );
  }
}