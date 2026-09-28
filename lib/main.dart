

import 'package:e_shop/Presentation/screen/Splash_Screen_Page/slpash_screen.dart';

import 'package:e_shop/Presentation/screen/order/order_history_screen.dart';
import 'package:e_shop/Presentation/screen/order/trackOrder.dart';
import 'package:e_shop/core/constants/otp_flow.dart';

import 'package:e_shop/features/auth/presentation/screens/new_password.dart';
import 'package:e_shop/features/auth/presentation/screens/otp_screen.dart';
import 'package:e_shop/features/auth/presentation/screens/register_screen.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';

import 'package:e_shop/core/network/api_client.dart';
import 'package:e_shop/core/storage/token_storage.dart';

import 'package:e_shop/data/datasources/user_auth_service.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'Divice_Bottom_nav/Divices_Nav/nav_divices.dart';
import 'Presentation/screen/profile_main_page/profile_gate.dart';
import 'core/firebase/firebase_notification_service.dart';
import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================
  // FIREBASE
  // ============================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM Notification
  await FirebaseNotificationService().initialize();

  // ============================
  // WEB URL STRATEGY
  // ============================
  usePathUrlStrategy();

  // ============================
  // ENV
  // ============================
  await dotenv.load(fileName: ".env");

  // ============================
  // STORAGE
  // ============================
  final tokenStorage = TokenStorage();
  final token = await tokenStorage.readToken();

  // ============================
  // API
  // ============================
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);

  final authRepository = User_AuthRepository(
    service: authService,
    storage: tokenStorage,
  );

  // ============================
  // APP
  // ============================
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('km'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
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

  const MyApp({
    super.key,

    required this.authRepository,

    required this.initialScreen,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "E-Shop",

      // Localization
      localizationsDelegates: context.localizationDelegates,

      supportedLocales: context.supportedLocales,

      locale: context.locale,

      // Material 3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),

        useMaterial3: true,
      ),

      // Desktop/Web mouse support
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,

          PointerDeviceKind.touch,

          PointerDeviceKind.trackpad,
        },
      ),

      onGenerateRoute: (settings) {
        switch (settings.name) {
          // ======================
          // MAIN APP
          // ======================

          case '/divicenav':
          case '/homemainppage':
            return MaterialPageRoute(
              builder: (_) => DivicesNav(authRepository: authRepository),
            );

          // ======================
          // AUTH
          // ======================

          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());

          case '/resetpassword':
            return MaterialPageRoute(builder: (_) => ResetPasswordScreen());

          case '/otp-verify':
            final email = settings.arguments as String;

            return MaterialPageRoute(
              builder: (_) => OtpScreen(email: email, flow: OtpFlow.register),
            );

          case '/newPassword':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => NewPasswordScreen(
                email: args['email'],

                code: args['code'] ?? '',
              ),
            );

          // ======================
          // PROFILE
          // ======================

          case '/deviceProfile':
            return MaterialPageRoute(
              // builder: (_) => DeviceProfileGate(repository: authRepository),
              builder: (_) => ProfileGate(repository: authRepository),
            );

          // ======================
          // ORDER HISTORY
          // ======================

          case '/orderHistory':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (_) => OrderHistoryScreen(
                userId: args['userId'],

                token: args['token'],
              ),
            );

          // ======================
          // TRACK ORDER
          // ======================

          case '/trackMyOrder':
            final args = settings.arguments as Map<String, dynamic>?;

            if (args == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("Missing order data")),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (_) => TrackOrderPage(
                orderId: args['orderId'],

                userId: args['userId'],

                token: args['token'],
              ),
            );
        }

        return null;
      },

      // ======================
      // START SCREEN
      // ======================
      home: Builder(
        builder: (context) {
          switch (initialScreen) {
            case 'splashscreen':
              return SplashScreen(authRepository: authRepository);

            case 'home':
              return DivicesNav(authRepository: authRepository);

            default:
              return SplashScreen(authRepository: authRepository);
          }
        },
      ),
    );
  }
}
