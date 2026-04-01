/*
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_shop/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:e_shop/main.dart';
// import 'package:e_shop/core/network/api_client.dart';
// import 'package:e_shop/core/storage/token_storage.dart';
// import 'package:e_shop/data/services/user_auth_service.dart';
// import 'package:e_shop/data/repositories/user_auth_repository.dart';
//
// void main() {
//   testWidgets('App loads and displays login screen', (WidgetTester tester) async {
//     // Create fake / test dependencies
//     final apiClient = ApiClient(baseUrl: 'https://e-shop-1-m034.onrender.com');
//     final tokenStorage = TokenStorage();
//     final authService = AuthService(apiClient);
//     final authRepository = AuthRepository(service: authService, storage: tokenStorage);
//
//     // Build our app and trigger a frame
//     await tester.pumpWidget(MyApp(authRepository: authRepository));
//
//     // Verify that the login screen is displayed
//     expect(find.text('Sign in to your Account'), findsOneWidget);
//     expect(find.byType(TextField), findsNWidgets(2)); // Username + Password fields
//     expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
//   });
// }*/



import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_shop/main.dart';
import 'package:e_shop/core/network/api_client.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/user_auth_service.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create dependencies
    final apiClient = ApiClient();
    final tokenStorage = TokenStorage();
    final authService = AuthService(apiClient);
    final authRepository = User_AuthRepository(service: authService, storage: tokenStorage);

    // Pass authRepository and initialScreen (required)
    await tester.pumpWidget(MyApp(
      authRepository: authRepository,
      initialScreen: 'login' // dummy screen to satisfy required parameter
    ));

    // Test counter
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}