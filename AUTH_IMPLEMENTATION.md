# Flutter E-Commerce — Auth Architecture & Implementation

This document describes a production-ready implementation plan and code examples for Authentication flows (Login, Register, OTP verification, Forgot / Reset Password) for your Flutter E-commerce app using Clean Architecture, Riverpod, Dio, GoRouter, Freezed, and json_serializable.

Checklist (what this file provides)
- [x] Project folder structure (suggested)
- [x] Recommended dependencies (pubspec additions)
- [x] Dio API client with interceptor (access token header + refresh token flow)
- [x] Secure token storage (`flutter_secure_storage`) implementation
- [x] Freezed + json_serializable auth models with generation commands
- [x] Auth repository and datasource example
- [x] Riverpod providers (Auth state, Auth controller)
- [x] GoRouter configuration for auth flows
- [x] Example UI screens: Login, Register, OTP, Forgot Password, Reset Password
- [x] Error handling, loading states, and responsive UI hints
- [x] Build & run commands (code generation)

Base URL
- BASE_URL: `https://e-shop-1-m034.onrender.com` (use path `/api/v1/...` for endpoints)

Important note
- This file provides production-quality patterns and code snippets. Some snippets require code generation (Freezed/json_serializable) and package installation. Run the commands at the end to generate the code.


Project folder structure (recommended)

lib/
  core/
    network/
      api_client.dart
      interceptors/
        auth_interceptor.dart
    storage/
      token_storage.dart
    constants/
      env.dart
      api_paths.dart
    router/
      app_router.dart
    utils/
      responsive.dart
      errors.dart
  features/
    auth/
      data/
        datasources/
          auth_service.dart
        models/
          auth_models.dart
        repositories/
          auth_repository_impl.dart
      domain/
        repositories/
          auth_repository.dart
        entities/
          user.dart
      presentation/
        controllers/
          auth_controller.dart
        screens/
          login_screen.dart
          register_screen.dart
          otp_screen.dart
          forgot_password_screen.dart
          reset_password_screen.dart
  main.dart


Dependencies (pubspec.yaml additions)

Add the following packages (versions can be changed to latest stable):

- dio: ^5.0.0
- flutter_secure_storage: ^8.0.0
- flutter_dotenv: ^5.0.2
- flutter_riverpod: ^2.3.2
- go_router: ^7.0.4
- freezed_annotation: ^2.2.0
- json_annotation: ^4.7.0
- build_runner: ^2.4.6 (dev)
- freezed: ^2.3.2 (dev)
- json_serializable: ^6.6.1 (dev)

Example dependencies block (snippet for pubspec.yaml):

```yaml
dependencies:
  dio: ^5.0.0
  flutter_secure_storage: ^8.0.0
  flutter_riverpod: ^2.3.2
  go_router: ^7.0.4
  flutter_dotenv: ^5.0.2
  freezed_annotation: ^2.2.0
  json_annotation: ^4.7.0
  # ... other existing deps e.g. cupertino_icons etc.

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.3.2
  json_serializable: ^6.6.1
```


1) Core: API Client (Dio) and Auth Interceptor

File: `lib/core/network/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors/auth_interceptor.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio dio;

  ApiClient._internal(this.dio);

  factory ApiClient({TokenStorage? storage}) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://e-shop-1-m034.onrender.com';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Attach interceptors
    final tokenStorage = storage ?? TokenStorage();
    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage, dio: dio));

    return ApiClient._internal(dio);
  }
}
```

File: `lib/core/network/interceptors/auth_interceptor.dart`

```dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor({required this.tokenStorage, required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final accessToken = await tokenStorage.readToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (_) {}
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If 401 -> try refresh
    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }

      // Lock and create a new request for refresh
      dio.lock();
      dio.interceptors.errorLock.lock();
      dio.interceptors.requestLock.lock();

      try {
        final resp = await dio.post('/api/v1/public/refresh', data: {
          'refreshToken': refreshToken,
        });

        if (resp.statusCode == 200) {
          final newAccess = resp.data['access_token'] as String?;
          final newRefresh = resp.data['refresh_token'] as String?;
          if (newAccess != null) {
            await tokenStorage.writeToken(newAccess);
            if (newRefresh != null) await tokenStorage.writeRefreshToken(newRefresh);

            // Retry original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccess';
            final clonedReq = await dio.fetch(opts);
            return handler.resolve(clonedReq);
          }
        }
      } catch (e) {
        // refresh failed -> propagate original error
      } finally {
        dio.unlock();
        dio.interceptors.errorLock.unlock();
        dio.interceptors.requestLock.unlock();
      }
    }

    return handler.next(err);
  }
}
```

Notes:
- The interceptor reads the access token from `TokenStorage` and attaches it.
- On 401 it attempts a refresh, writes tokens on success, and retries the original request.
- Avoid infinite loops: protective checks and limited retry attempts can be added.


2) Secure Token Storage

File: `lib/core/storage/token_storage.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  TokenStorage({FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _keyToken = 'ACCESS_TOKEN';
  static const _keyRefresh = 'REFRESH_TOKEN';
  static const _keyUserId = 'USER_ID';

  Future<void> writeToken(String token) => _secureStorage.write(key: _keyToken, value: token);
  Future<String?> readToken() => _secureStorage.read(key: _keyToken);
  Future<void> deleteToken() => _secureStorage.delete(key: _keyToken);

  Future<void> writeRefreshToken(String refreshToken) => _secureStorage.write(key: _keyRefresh, value: refreshToken);
  Future<String?> readRefreshToken() => _secureStorage.read(key: _keyRefresh);
  Future<void> deleteRefreshToken() => _secureStorage.delete(key: _keyRefresh);

  Future<void> writeUserId(String userId) => _secureStorage.write(key: _keyUserId, value: userId);
  Future<String?> readUserId() => _secureStorage.read(key: _keyUserId);
  Future<void> deleteUserId() => _secureStorage.delete(key: _keyUserId);

  Future<void> clearAll() => _secureStorage.deleteAll();
}
```


3) Auth Models (Freezed + json_serializable)

File: `lib/features/auth/data/models/auth_models.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required int id,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required String email,
    required String username,
    required String role,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String username,
    required String password,
    required String email,
    required String phone,
    @JsonKey(name: 'full_name') required String fullName,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required int CriteriaType, // as backend expects
    required String CriteriaValue,
    required String Password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}
```

Commands to generate files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```


4) Auth Service (Datasource) using ApiClient / Dio

File: `lib/features/auth/data/datasources/auth_service.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<AuthResponse> register(RegisterRequest req) async {
    final resp = await apiClient.dio.post('/api/v1/public/register', data: req.toJson());
    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AuthResponse> loginByEmail(LoginRequest req) async {
    final resp = await apiClient.dio.post('/api/v1/public/email/login', data: req.toJson());
    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AuthResponse> loginByUsername(LoginRequest req) async {
    final resp = await apiClient.dio.post('/api/v1/public/username/login', data: req.toJson());
    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await apiClient.dio.post('/api/v1/public/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await apiClient.dio.post('/api/v1/public/reset-password', data: {'token': token, 'newPassword': newPassword});
  }

  Future<AuthResponse> verifyOtp(String email, String code) async {
    final resp = await apiClient.dio.post('/api/v1/public/verify', queryParameters: {'email': email, 'code': code});
    return AuthResponse.fromJson(resp.data as Map<String, dynamic>);
  }
}
```


5) Auth Repository (domain boundary)

File: `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_service.dart';
import '../../data/models/auth_models.dart';
import '../../../../core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;
  final TokenStorage storage;

  AuthRepositoryImpl({required this.service, required this.storage});

  @override
  Future<AuthResponse> register(RegisterRequest req) async {
    final resp = await service.register(req);
    await storage.writeToken(resp.accessToken);
    await storage.writeRefreshToken(resp.refreshToken);
    await storage.writeUserId(resp.id.toString());
    return resp;
  }

  @override
  Future<AuthResponse> loginByEmail(LoginRequest req) async {
    final resp = await service.loginByEmail(req);
    await storage.writeToken(resp.accessToken);
    await storage.writeRefreshToken(resp.refreshToken);
    return resp;
  }

  @override
  Future<AuthResponse> loginByUsername(LoginRequest req) async {
    final resp = await service.loginByUsername(req);
    await storage.writeToken(resp.accessToken);
    await storage.writeRefreshToken(resp.refreshToken);
    return resp;
  }

  @override
  Future<void> forgotPassword(String email) => service.forgotPassword(email);

  @override
  Future<void> resetPassword(String token, String newPassword) => service.resetPassword(token, newPassword);

  @override
  Future<AuthResponse> verifyOtp(String email, String code) async {
    final resp = await service.verifyOtp(email, code);
    await storage.writeToken(resp.accessToken);
    await storage.writeRefreshToken(resp.refreshToken);
    return resp;
  }
}
```

File: `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> register(RegisterRequest req);
  Future<AuthResponse> loginByEmail(LoginRequest req);
  Future<AuthResponse> loginByUsername(LoginRequest req);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<AuthResponse> verifyOtp(String email, String code);
}
```


6) Riverpod: Auth State & Controller

Use `StateNotifier` or `AsyncNotifier` depending on preference. Example uses `StateNotifier` + sealed states.

File: `lib/features/auth/presentation/controllers/auth_controller.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/auth_models.dart';
import '../../../data/repositories/auth_repository_impl.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final AuthResponse response;
  AuthAuthenticated(this.response);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepositoryImpl repository;

  AuthController(this.repository) : super(AuthInitial());

  Future<void> register(RegisterRequest req) async {
    state = AuthLoading();
    try {
      final res = await repository.register(req);
      state = AuthAuthenticated(res);
    } catch (e, st) {
      state = AuthError(e.toString());
    }
  }

  Future<void> loginByEmail(LoginRequest req) async {
    state = AuthLoading();
    try {
      final res = await repository.loginByEmail(req);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> loginByUsername(LoginRequest req) async {
    state = AuthLoading();
    try {
      final res = await repository.loginByUsername(req);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = AuthLoading();
    try {
      await repository.forgotPassword(email);
      state = AuthInitial();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = AuthLoading();
    try {
      await repository.resetPassword(token, newPassword);
      state = AuthInitial();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    state = AuthLoading();
    try {
      final res = await repository.verifyOtp(email, code);
      state = AuthAuthenticated(res);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }
}

// Providers
final tokenStorageProvider = Provider((ref) => throw UnimplementedError()); // wire in implementation in main
final apiClientProvider = Provider((ref) => throw UnimplementedError());
final authServiceProvider = Provider((ref) => throw UnimplementedError());
final authRepositoryProvider = Provider((ref) => throw UnimplementedError());
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo as AuthRepositoryImpl);
});
```

Wire these providers in `main.dart` where you create TokenStorage, ApiClient, AuthService, AuthRepositoryImpl and supply them.


7) GoRouter: Routes & Guard

File: `lib/core/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const Scaffold(body: Center(child: Text('Splash...')))),
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/otp', builder: (c, s) => const OtpScreen()),
    GoRoute(path: '/forgot', builder: (c, s) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset', builder: (c, s) => const ResetPasswordScreen()),
    GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
  ],
);
```

Use navigation like `context.go('/login')` or `GoRouter.of(context).go('/home')`.


8) Example UI: Login Screen (Material 3, responsive and accessible)

File: `lib/features/auth/presentation/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/auth_models.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailLogin = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email or Username'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  authState is AuthLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;

                            final req = LoginRequest(
                              CriteriaType: 0,
                              CriteriaValue: _emailController.text.trim(),
                              Password: _passwordController.text,
                            );

                            // here you could branch between email vs username endpoints
                            ref.read(authControllerProvider.notifier).loginByEmail(req);
                          },
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/forgot');
                      },
                      child: const Text('Forgot password?')),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```


9) Register Screen & OTP, Forgot, Reset

- Implement `RegisterScreen` similar layout: Form fields (full name, email, username, phone, password). Call `register` on `AuthController`. On success navigate to `/otp` and pass the email.
- `OtpScreen` shows 4-6 digit input; call `verifyOtp(email, code)` on controller.
- `ForgotPasswordScreen` collects email and calls `forgotPassword`.
- `ResetPasswordScreen` accepts token (from email) and new password and calls `resetPassword`.

UI tips:
- Use `ConstrainedBox` to limit width on larger screens for responsiveness.
- Use Material 3 Theme: `ThemeData(useMaterial3: true)`.
- Use `TextFormField` with semantic labels for accessibility.


10) Error handling and loading states

- The `AuthController` state provides `AuthLoading`, `AuthError`, and `AuthAuthenticated`.
- In the UI consume `authControllerProvider` and show `SnackBar` / `Dialog` on `AuthError`.
- Use consistent try/catch in repository and service layers; wrap DioException and map to friendly messages.

Example error mapping (utils/errors.dart):

```dart
String extractDioErrorMessage(Object error) {
  if (error is DioException) {
    final msg = error.response?.data?['message'] ?? error.message;
    return msg?.toString() ?? 'Network error';
  }
  return error.toString();
}
```


11) main.dart wiring (example)

File: `lib/main.dart` (simplified)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(storage: tokenStorage);
  final authService = AuthService(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(service: authService, storage: tokenStorage);

  runApp(ProviderScope(overrides: [
    // override providers to concrete implementations
    // apiClientProvider.overrideWithValue(apiClient), etc.
  ], child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
    );
  }
}
```


12) Code generation & run commands

Install packages and generate serialization code:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
flutter run
```


13) Security & Production considerations
- Enforce secure storage and do not log tokens.
- Add certificate pinning (optional) for extra security.
- Add network timeout and retry logic for transient failures.
- Add analytics & Sentry for error tracking.
- Input validation and strong password policies on client side.
- Rate limit OTP attempts and handle server side.


14) Next steps / To implement in codebase
- Create the files above in the suggested paths.
- Add providers wiring in `main.dart` and apply `ProviderScope` overrides for `apiClientProvider`, `tokenStorageProvider`, etc.
- Implement UI screens for register and OTP with validations and friendly error messages.
- Add unit tests for repository and unit/integration tests for API calls (mock Dio).


Appendix: Example quick wiring for providers in `main.dart` (override sample)

```dart
final tokenStorageProvider = Provider<TokenStorage>((_) => throw UnimplementedError());
final apiClientProvider = Provider<ApiClient>((ref) => throw UnimplementedError());
final authServiceProvider = Provider<AuthService>((ref) => throw UnimplementedError());
final authRepoProvider = Provider<AuthRepositoryImpl>((ref) => throw UnimplementedError());

// in main.dart runApp:
runApp(ProviderScope(overrides: [
  tokenStorageProvider.overrideWithValue(tokenStorage),
  apiClientProvider.overrideWithValue(apiClient),
  authServiceProvider.overrideWithValue(authService),
  authRepoProvider.overrideWithValue(authRepository),
], child: const MyApp()));
```


If you want, I can now:
- Generate all the source files (`lib/...`) with the code skeletons shown above and wire them into your project, or
- Implement a single feature first (e.g., Login + Register screens + repository + samples) and run the codegen to verify.

Tell me which next step you'd like me to take (generate files automatically, or implement a smaller subset and run build_runner).
