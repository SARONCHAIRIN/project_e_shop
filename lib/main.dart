import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/order/order_history_screen.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/device_profile_gate.dart';
import 'package:e_shop/core/constants/otp_flow.dart';
import 'package:e_shop/features/auth/presentation/screens/new_password.dart';
import 'package:e_shop/features/auth/presentation/screens/otp_screen.dart';
import 'package:e_shop/features/auth/presentation/screens/register_screen.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_localization/easy_localization.dart';

// Auth
import 'Presentation/screen/order/trackOrder.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'data/datasources/user_auth_service.dart';
import 'data/repositories/user_auth_repository.dart';

// Screens
import 'Presentation/screen/Splash_Screen_Page/slpash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //call dotenv
  await dotenv.load(fileName: ".env");

  // Initialize token storage & read token
  final tokenStorage = TokenStorage();
  final token = await tokenStorage.readToken();

  // Initialize API & Auth
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final authRepository = User_AuthRepository(
    service: authService,
    storage: tokenStorage,
  );
  // Initialize Cart Service & Repository

  runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('km'),
        ],
        path: 'assets/translations',

        fallbackLocale: const Locale('en'),

        // First language

        startLocale: const Locale('en'),

        child: ProviderScope(
          child: MyApp(
            authRepository: authRepository,
            initialScreen: token == null ? 'splashscreen' : 'home',
          ),
        ),

      ),
      );
  }

class MyApp extends StatelessWidget {
  final User_AuthRepository authRepository;
  final String initialScreen;

  // String get _otpCode => _controllers.map((c) => c.text).join();
  //
  // bool get _isComplete => _otpCode.length == _otpLength;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // EasyLocalization configuration

      localizationsDelegates: context.localizationDelegates,

      supportedLocales: context.supportedLocales,

      locale: context.locale,

      title: 'E-Shop',

      theme: ThemeData(

        primarySwatch: Colors.green,

      ),

      onGenerateRoute: (settings) {
        if (settings.name == '/homemainppage') {
          return MaterialPageRoute(
            builder: (_) => DivicesNav(authRepository: authRepository),
          );
        }

        if (settings.name == '/divicenav') {
          return MaterialPageRoute(
            builder: (_) => DivicesNav(authRepository: authRepository),
          );
        }

        if (settings.name == '/otp-verify') {
          final email = settings.arguments as String;

          return MaterialPageRoute(
            builder: (_) => OtpScreen(email: email, flow: OtpFlow.register),
          );
        }

        if (settings.name == '/newPassword') {
          final args = settings.arguments as Map<String, dynamic>;
          final email = args['email'] as String;
          final code = args['code'] as String? ?? '';

          return MaterialPageRoute(
            builder: (_) => NewPasswordScreen(email: email, code: code),
          );
        }

        // if (settings.name == '/login') {
        //   return MaterialPageRoute(
        //     builder: (_) => LoginScreen(authRepository: authRepository),
        //   );
        // }

        if (settings.name == '/register') {
          return MaterialPageRoute(builder: (_) => RegisterScreen());
        }
        if (settings.name == '/resetpassword') {
          return MaterialPageRoute(builder: (_) => ResetPasswordScreen());
        }

        if (settings.name == '/orderHistory') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) =>
                OrderHistoryScreen(
                  userId: args['userId'] as int,
                  token: args['token'] as String,
                ),
          );
        }

        if (settings.name == '/deviceProfile') {
          return MaterialPageRoute(
            builder: (_) => DeviceProfileGate(repository: authRepository),
          );
        }

        if (settings.name == '/trackMyOrder') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            return MaterialPageRoute(
              builder: (_) =>
              const Scaffold(
                body: Center(child: Text('Missing route arguments')),
              ),
            );
          }

          final orderId = args['orderId'];
          final userId = args['userId'];
          final token = args['token'];

          if (orderId == null || userId == null || token == null) {
            return MaterialPageRoute(
              builder: (_) =>
              const Scaffold(
                body: Center(child: Text('Invalid order data')),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) =>
                TrackOrderPage(
                  orderId: orderId as int,
                  userId: userId as int,
                  token: token as String,
                ),
          );
        }
        return null;
      },

      // title: 'E-Shop',
      // theme: ThemeData(primarySwatch: Colors.green),
      home: Builder(
        builder: (context) {
          // Decide initial screen
          switch (initialScreen) {
            case 'splashscreen':
              return SplashScreen(authRepository: authRepository);
            case 'home':
              return SplashScreen(authRepository: authRepository);
            default:
              return const Scaffold(
                body: Center(child: Text('Unknown initial screen')),
              );
          }
        },
      ),
    );
  }
}
