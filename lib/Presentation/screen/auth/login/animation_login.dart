/*

import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:flutter/material.dart';

import '../../../../data/repositories/user_auth_repository.dart';

class AnimationLogin extends StatelessWidget {
  final AuthRepository  authRepository;
  const AnimationLogin({
    super.key,
    required this.authRepository
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        textSelectionTheme:
        const TextSelectionThemeData(cursorColor: Colors.orange),
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          displaySmall: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45,
            // fontWeight: FontWeight.w400,
            color: Colors.orange,
          ),
          labelLarge: const TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          bodySmall: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurple[300],
          ),
          displayLarge: const TextStyle(fontFamily: 'Quicksand'),
          displayMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineSmall: const TextStyle(fontFamily: 'NotoSans'),
          titleLarge: const TextStyle(fontFamily: 'NotoSans'),
          titleMedium: const TextStyle(fontFamily: 'NotoSans'),
          bodyLarge: const TextStyle(fontFamily: 'NotoSans'),
          bodyMedium: const TextStyle(fontFamily: 'NotoSans'),
          titleSmall: const TextStyle(fontFamily: 'NotoSans'),
          labelSmall: const TextStyle(fontFamily: 'NotoSans'),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.orange),
      ),
      // navigatorObservers: [],

      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(authRepository:  authRepository ),
        DivicesNav.routeName: (context) => DivicesNav(authRepository: authRepository),
      },

    );
  }
}
*/
