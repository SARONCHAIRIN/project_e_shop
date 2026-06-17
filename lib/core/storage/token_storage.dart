import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage using FlutterSecureStorage for tokens
/// and SharedPreferences for non-sensitive user data.
///
/// Production-ready implementation following clean architecture patterns.
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  static const _keyToken = 'ACCESS_TOKEN';
  static const _keyRefresh = 'REFRESH_TOKEN';
  static const _keyUserId = 'USER_ID';
  static const String _usernameKey = 'username';
  static const String _userEmailKey = 'email';
  static const String _fullnameKey = 'full_name';

  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ========== SECURE TOKEN METHODS (FlutterSecureStorage) ==========

  /// Write access token to secure storage.
  Future<void> writeToken(String token) =>
      _secureStorage.write(key: _keyToken, value: token);

  /// Read access token from secure storage.
  Future<String?> readToken() => _secureStorage.read(key: _keyToken);

  /// Delete access token from secure storage.
  Future<void> deleteToken() => _secureStorage.delete(key: _keyToken);

  /// Write refresh token to secure storage.
  Future<void> writeRefreshToken(String refreshToken) =>
      _secureStorage.write(key: _keyRefresh, value: refreshToken);

  /// Read refresh token from secure storage.
  Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _keyRefresh);

  /// Delete refresh token from secure storage.
  Future<void> deleteRefreshToken() =>
      _secureStorage.delete(key: _keyRefresh);

  /// Check if access token exists.
  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  // PASSWORD — secure
  Future<void> writePassword(String password) async {
    await _secureStorage.write(key: 'password', value: password);
    print('Password saved securely ');
  }

  Future<String?> readPassword() async {
    return await _secureStorage.read(key: 'password');
  }
  Future<void> deletePassword() async {
    await _secureStorage.delete(key: 'password');
  }


  // ========== USER DATA METHODS (SharedPreferences) ==========
  Future<void> writeUserId(int userId) async {

    await _secureStorage.write(

      key: _keyUserId,

      value: userId.toString(),

    );

  }

  Future<int?> readUserId() async {

    final value = await _secureStorage.read(key: _keyUserId);

    return value == null ? null : int.tryParse(value);

  }

  Future<void> deleteUserId() async {

    await _secureStorage.delete(key: _keyUserId);

  }

  /// Write username to SharedPreferences.
  Future<void> writeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  /// Read username from SharedPreferences.
  Future<String?> readUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Write email to SharedPreferences.
  Future<void> writeUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  /// Read email from SharedPreferences.
  Future<String?> readUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Write full name to SharedPreferences.
  Future<void> writeFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullnameKey, fullName);
  }

  /// Read full name from SharedPreferences.
  Future<String?> readFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullnameKey);
  }

  /// Write user image URL to SharedPreferences.
  Future<void> writeUserImage(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', url);
  }

  /// Read user image URL from SharedPreferences.
  Future<String?> readUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image');
  }

  /// Delete user image URL from SharedPreferences.
  Future<void> deleteUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
  }

  // ========== BULK OPERATIONS ==========

  /// Save all user data at once (tokens + metadata).
  Future<void> saveUserData({
    required String token,
    required String refreshToken,
    required int userId,
    required String username,
    required String email,
    required String fullName,
  }) async {
    await writeToken(token);
    await writeRefreshToken(refreshToken);
    await writeUserId(userId);
    await writeUsername(username);
    await writeUserEmail(email);
    await writeFullName(fullName);
  }

  /// Retrieve all stored user info.
  Future<Map<String, dynamic>> getAllUserInfo() async {
    return {
      'token': await readToken(),
      'refresh_token': await readRefreshToken(),
      'userId': await readUserId(),
      'username': await readUsername(),
      'email': await readUserEmail(),
      'full_name': await readFullName(),
      'user_image': await readUserImage(),
    };
  }

  /// Clear all tokens and user data (logout).
  Future<void> clearAll() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUserId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_fullnameKey);
    await prefs.remove('user_image');
  }

  /// Clear all data from SharedPreferences (legacy cleanup).
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== LEGACY COMPATIBILITY METHODS ==========
  // These methods are kept for backward compatibility

  Future<void> saveToken(String token) => writeToken(token);
  Future<String?> getToken() => readToken();
  Future<void> clearToken() => deleteToken();

  Future<void> saveRefreshToken(String refreshToken) => writeRefreshToken(refreshToken);

  Future<void> saveUsername(String username) => writeUsername(username);
  Future<String?> getUsername() => readUsername();

  Future<void> deleteUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      print(' Username deleted');
    } catch (e) {
      print(' Error deleting username: $e');
    }
  }


  Future<void> saveUserEmail(String email) => writeUserEmail(email);

  Future<void> saveUserId(int userId) => writeUserId(userId);
  Future<int?> readUserIdAsInt() async {
    return await readUserId();
  }

  Future<int?> getUserId() => readUserIdAsInt();

  Future<void> saveFullName(String fullName) => writeFullName(fullName);
}
