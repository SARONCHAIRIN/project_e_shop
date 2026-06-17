import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/constants/otp_flow.dart';
import '../controllers/auth_controller.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';

class _Palette {
  static const bgTop = Color(0xFF0B1120);
  static const bgMid = Color(0xFF182447);
  static const bgBottom = Color(0xFF2D1B4E);
  static const gold = Color(0xFFF2B705);
  static const goldDeep = Color(0xFFCB8A00);
  static const goldText = Color(0xFF231A00);
  static const glass = Color(0x14FFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const coral = Color(0xFFFF6B6B);
}

class OtpScreen extends ConsumerStatefulWidget {

  final String email;
  final OtpFlow flow;

  const OtpScreen({
    super.key,
    required this.email,
    required this.flow,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otpCode.length == _otpLength;

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
    // Forward AFTER both animations are assigned
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == _otpLength) {
      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[_otpLength - 1].requestFocus();
      setState(() {});
      return;
    }
    if (value.isNotEmpty) {
      _controllers[index].text = value[value.length - 1];
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      _controllers[index].clear();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
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

  Future<void> _verify(AuthController controller) async {
    if (!_isComplete) return;

    await controller.verifyOtp(
      OtpVerifyRequest(email: widget.email, code: _otpCode),
    );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    if (state.error == null) {
      if (widget.flow == OtpFlow.register) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/divicenav',
              (route) => false,
          arguments: {'verified': true},
        );
      }
      else if (widget.flow == OtpFlow.forgotPassword) {
        Navigator.pushReplacementNamed(
          context,
          '/newPassword',
          arguments: {
            'email': widget.email,
            'code': _otpCode,
          },
        );
      }
    } else {
      _showSnack(state.error ?? 'Invalid OTP', isError: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = state.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background photo
          Positioned.fill(
            child: Image.asset(
              'assets/images/back_image.png',
              fit: BoxFit.cover,
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

          // Main card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 100),
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
                          padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(height: 50),
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
                                        color: _Palette.gold.withOpacity(0.4),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mark_email_read_outlined,
                                    color: _Palette.goldText,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Step indicator — step 2 of 2, both filled
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
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: _Palette.gold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'STEP 2 OF 2 · VERIFY EMAIL',
                                style: TextStyle(
                                  color: _Palette.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 20),

                              const Text(
                                'Verify your email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'We sent a 6-digit code to',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.email,
                                style: const TextStyle(
                                  color: _Palette.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 34),

                              // OTP boxes
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(_otpLength, (index) {
                                  final isFilled =
                                      _controllers[index].text.isNotEmpty;
                                  return SizedBox(
                                    width: 46,
                                    height: 58,
                                    child: KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (e) => _onKeyEvent(index, e),
                                      child: TextFormField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        maxLength: _otpLength,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        cursorColor: _Palette.gold,
                                        decoration: InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: isFilled
                                              ? Colors.white.withOpacity(0.18)
                                              : Colors.white.withOpacity(0.06),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: isFilled
                                                  ? _Palette.gold
                                                  : Colors.white.withOpacity(
                                                      0.14,
                                                    ),
                                              width: isFilled ? 1.6 : 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: _Palette.gold,
                                              width: 1.6,
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (v) =>
                                            _onDigitChanged(index, v),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 34),

                              // Verify button
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _isComplete
                                        ? const LinearGradient(
                                            colors: [
                                              _Palette.gold,
                                              _Palette.goldDeep,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          )
                                        : null,
                                    color: _isComplete
                                        ? null
                                        : Colors.white.withOpacity(0.08),
                                    boxShadow: _isComplete
                                        ? [
                                            BoxShadow(
                                              color: _Palette.gold.withOpacity(
                                                0.35,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: (isLoading || !_isComplete)
                                          ? null
                                          : () => _verify(controller),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        child: Center(
                                          child: isLoading
                                              ? const SpinKitDualRing(
                                                  color: _Palette.goldText,
                                                  size: 22,
                                                  lineWidth: 3,
                                                )
                                              : Text(
                                                  'Verify code',
                                                  style: TextStyle(
                                                    color: _isComplete
                                                        ? _Palette.goldText
                                                        : Colors.white
                                                              .withOpacity(
                                                                0.35,
                                                              ),
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
                              const SizedBox(height: 24),

                              // Resend row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () async {
                                      final success = await ref
                                          .read(authControllerProvider.notifier)
                                          .resendOtp(widget.email);
                                      if (!mounted) return;
                                      _showSnack(
                                        success
                                            ? 'OTP sent successfully'
                                            : 'Failed to resend OTP',
                                        isError: !success,
                                      );
                                    },
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
                              Spacer(),
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
