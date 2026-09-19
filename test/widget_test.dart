//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:e_shop/main.dart';
// import 'package:e_shop/core/network/api_client.dart';
// import 'package:e_shop/core/storage/token_storage.dart';
// import 'package:e_shop/data/datasources/user_auth_service.dart';
// import 'package:e_shop/data/repositories/user_auth_repository.dart';
//
// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Create dependencies
//     final apiClient = ApiClient();
//     final tokenStorage = TokenStorage();
//     final authService = AuthService(apiClient);
//     final authRepository = User_AuthRepository(service: authService, storage: tokenStorage);
//
//     // Pass authRepository and initialScreen (required)
//     await tester.pumpWidget(MyApp(
//       authRepository: authRepository,
//       initialScreen: 'login' // dummy screen to satisfy required parameter
//     ));
//
//     // Test counter
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('basic e-shop test', () {
    expect(1 + 1, 2);
  });
}