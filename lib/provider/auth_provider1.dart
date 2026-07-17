import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../data/datasources/user_auth_service.dart';
import '../data/repositories/user_auth_repository.dart';

/// ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// TokenStorage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(apiClientProvider),
  );
});

/// Repository
final userAuthRepositoryProvider = Provider<User_AuthRepository>((ref) {
  return User_AuthRepository(
    service: ref.read(authServiceProvider),
    storage: ref.read(tokenStorageProvider),
  );
});