# Auth Implementation Tasks — Flutter E-Shop

Purpose: Create a clear, actionable task list to implement the authentication features (Login, Register, OTP Verification, Forgot/Reset Password) and related infra described in `AUTH_IMPLEMENTATION.md`.

How to use this file
- Follow the checklist items in priority order.
- Each task includes a path (where to create files), acceptance criteria, and estimated effort.
- When a task is completed, check the box and push changes to your repo.

Summary checklist
- [x] Project setup & dependencies
- [x] Core network & storage (**COMPLETED - Task 2**)
- [x] Models & codegen (**COMPLETED - Task 3**)
- [x] Datasource & repository (**COMPLETED - Task 4**)
- [x] Riverpod controllers & providers (** COMPLETED - Task 5**)
- [ ] UI screens (login/register/otp/forgot/reset)
- [ ] Navigation (GoRouter) wiring
- [x] Interceptor & refresh token flow (part of Task 2)
- [ ] Error handling & UX polish
- [ ] Tests (unit & integration)
- [ ] CI & release checklist

Detailed tasks

1) Project setup & dependencies (Priority: High, Est: 30–60m)
- Files to update:
  - `pubspec.yaml` (add dependencies/dev_dependencies)
- Acceptance criteria:
  - `pubspec.yaml` updated with packages listed in `AUTH_IMPLEMENTATION.md`.
  - Run `flutter pub get` successfully.

Commands:
```bash
# from project root
flutter pub get
```


2) Core: TokenStorage and ApiClient (Priority: High, Est: 60–90m)
- Files to create:
  - `lib/core/storage/token_storage.dart`
  - `lib/core/network/api_client.dart`
  - `lib/core/network/interceptors/auth_interceptor.dart`
- Acceptance criteria:
  - Secure storage works on device/emulator.
  - ApiClient is instantiable and has the interceptor attached.
  - Basic smoke test: ApiClient.dio.get('/') (or a safe endpoint) returns expected HTTP behaviour.


3) Models & Code Generation (Priority: High, Est: 45–75m)
- Files to create:
  - `lib/features/auth/data/models/auth_models.dart`
- Steps:
  - Add Freezed and json_serializable annotations and parts.
  - Run build_runner to generate files.
- Acceptance criteria:
  - `auth_models.freezed.dart` and `auth_models.g.dart` generated without errors.

Commands:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```


4) Datasource (AuthService) and Repository (AuthRepositoryImpl) (Priority: High, Est: 60–120m)
- Files to create:
  - `lib/features/auth/data/datasources/auth_service.dart`
  - `lib/features/auth/data/repositories/auth_repository_impl.dart`
  - `lib/features/auth/domain/repositories/auth_repository.dart`
- Acceptance criteria:
  - Methods for register/login/forgot/reset/verify exist and map request/response models.
  - Repository writes tokens to `TokenStorage` on success.


5) Riverpod: Providers & Controllers (Priority: High, Est: 45–90m)
- Files to create:
  - `lib/features/auth/presentation/controllers/auth_controller.dart`
- Steps:
  - Implement StateNotifier or AsyncNotifier for auth states.
  - Create providers for TokenStorage, ApiClient, AuthService, AuthRepository, AuthController.
  - Wire providers in `main.dart` with `ProviderScope(overrides: [...])`.
- Acceptance criteria:
  - AuthController can call repo methods and update state.
  - UI can observe state changes.


6) UI: Login, Register, OTP, Forgot, Reset screens (Priority: High, Est: 4–8h)
- Files to create:
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/features/auth/presentation/screens/register_screen.dart`
  - `lib/features/auth/presentation/screens/otp_screen.dart`
  - `lib/features/auth/presentation/screens/forgot_password_screen.dart`
  - `lib/features/auth/presentation/screens/reset_password_screen.dart`
- Steps:
  - Implement responsive layouts using `ConstrainedBox`.
  - Use Material 3 and input validation.
  - Connect forms to `AuthController` via Riverpod.
  - Navigate between flows using GoRouter.
  - Acceptance criteria:
    - Forms validate locally.
    - On submit, controller methods are invoked and UI shows loading/error/success.


7) Navigation: GoRouter wiring & guards (Priority: Medium, Est: 45–90m)
- Files to create:
  - `lib/core/router/app_router.dart`
- Steps:
  - Define routes for splash/login/register/otp/forgot/reset/home.
  - Implement guard (redirect) depending on auth state (token presence).
- Acceptance criteria:
  - App routes work and navigation occurs correctly.


8) Interceptor: Refresh token flow & retry (Priority: High, Est: 60–120m)
- Files to update:
  - `lib/core/network/interceptors/auth_interceptor.dart`
- Steps:
  - Implement token attachment, refresh flow, request retry.
  - Add guards to prevent infinite retries and concurrent refresh races.
- Acceptance criteria:
  - When access token expired, refresh endpoint is called and original request retried with new token.
  - If refresh fails, tokens cleared and user redirected to login.


9) UX & Error handling (Priority: Medium, Est: 2–4h)
- Files to add/update:
  - `lib/core/utils/errors.dart`
  - SnackBar/Alert dialogs in screens
- Acceptance criteria:
  - Friendly messages for common errors (network, validation, auth).
  - Loading indicators visible during network calls.


10) Testing (Priority: Medium, Est: 3–6h)
- Add unit tests for:
  - TokenStorage (mock secure storage)
  - AuthRepository (mock ApiClient)
  - AuthController (mock repository)
- Add integration tests (optional) for end-to-end flows using mocked HTTP via packages like `mocktail` or `http_mock_adapter`.
- Acceptance criteria:
  - CI passes local tests.


11) CI & Release checklist (Priority: Low, Est: 1–2h)
- Steps:
  - Add a GitHub Actions workflow to run `flutter analyze`, `flutter test`, and `build_runner` generation check.
  - Ensure secrets for release are stored securely.
- Acceptance criteria:
  - PR pipeline runs and fails fast on errors.


Acceptance & Done criteria (project-wide)
- All auth flows pass manual tests on Android & iOS simulators.
- Freezed models and generated files present and up-to-date.
- Tokens stored securely and refresh interceptor works as expected.
- Navigation transitions and guarded routes behave correctly.
- Basic unit tests included and passing.


Quick run commands

```bash
# fetch deps
flutter pub get

# generate code
flutter pub run build_runner build --delete-conflicting-outputs

# run app
flutter run
```


Notes & recommendations
- Start small: implement TokenStorage + ApiClient + Login screen first and verify end-to-end before implementing the rest.
- Use `http_mock_adapter` for Dio when testing repository logic.
- Keep UI simple and accessible; invest in validations and helpful error messages.


If you want I can now:
- Generate the relevant Dart files for the highest-priority tasks automatically (TokenStorage, ApiClient, Auth models, AuthService, AuthRepository, AuthController, Login screen) and run the code generator. This will create files inside `lib/` and run `build_runner` to generate Freezed files.
- Or I can create the full scaffold (all files listed) but skip running codegen.

Tell me which option you want me to execute next.
