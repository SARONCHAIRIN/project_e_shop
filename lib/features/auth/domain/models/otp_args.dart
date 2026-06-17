
import '../../../../core/constants/otp_flow.dart';

class OtpArgs {
  final String email;
  final OtpFlow flow;

  OtpArgs({
    required this.email,
    required this.flow,
  });
}