import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../data/models/auth_models.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    email =
        ModalRoute.of(context)?.settings.arguments as String? ??
            '';
  }

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.85),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.white.withOpacity(0.7),
      ),
      fillColor: Colors.white.withOpacity(0.1),
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  Future<void> _submit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    await controller.resetPassword(
      ResetPasswordRequest(
        email: email,
        code: otpController.text.trim(),
        newPassword: passwordController.text.trim(),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset successfully',
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller =
    ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back_image.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 50,
            left: 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                alignment: Alignment.center,
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.transparent,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      blurStyle: BlurStyle.outer,
                      spreadRadius: 2,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 10,
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.transparent.withOpacity(0.1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                Colors.white.withOpacity(0.6),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_reset_outlined,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Enter the OTP code sent to your email and create a new password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color:
                              Colors.white.withOpacity(0.75),
                            ),
                          ),

                          const SizedBox(height: 32),

                          TextFormField(
                            initialValue: email,
                            readOnly: true,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: inputDecoration(
                              'Email Address',
                              Icons.email_outlined,
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: otpController,
                            keyboardType:
                            TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: inputDecoration(
                              'OTP Code',
                              Icons.password_outlined,
                            ),
                            validator: (v) {
                              if (v == null ||
                                  v.trim().length != 6) {
                                return 'Enter valid OTP';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: inputDecoration(
                              'New Password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null ||
                                  v.trim().length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller:
                            confirmPasswordController,
                            obscureText: obscureConfirm,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: inputDecoration(
                              'Confirm Password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureConfirm =
                                    !obscureConfirm;
                                  });
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v !=
                                  passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 5,
                                    blurStyle:
                                    BlurStyle.outer,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                state.isLoading
                                    ? null
                                    : () => _submit(
                                  controller,
                                ),
                                style:
                                ElevatedButton.styleFrom(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    vertical: 14,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      18,
                                    ),
                                  ),
                                  backgroundColor:
                                  Colors.transparent,
                                  shadowColor:
                                  Colors.transparent,
                                ),
                                child: state.isLoading
                                    ? const SpinKitDualRing(
                                  color: Colors.white,
                                  size: 25,
                                )
                                    : const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    Colors.white,
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
        ],
      ),
    );
  }
}