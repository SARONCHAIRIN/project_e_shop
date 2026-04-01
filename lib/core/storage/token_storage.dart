import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _userEmailKey = 'email';
  static const String _userIdKey = 'user_id';
  static const String _fullnameKey = 'full_name';

  // ========== TOKEN METHODS ==========
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print(' Token saved: $token');
    } catch (e) {
      print(' Error saving token: $e');
    }
  }

  // Future<void> writeToken(String token) => saveToken(token);
  Future<void> writeToken(String? token) async {
    if (token == null || token.isEmpty) {
      print("Token not saved because it is null");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString(_tokenKey, token);  // use consistent key

    print("Token saved: $token");
    saveToken(token);
  }

  Future<String?> readToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print(' Token read: $token');
      return token;
    } catch (e) {
      print(' Error reading token: $e');
      return null;
    }
  }

  Future<String?> getToken() => readToken();

  Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('️ Token deleted');
    } catch (e) {
      print(' Error deleting token: $e');
    }
  }

  Future<void> clearToken() => deleteToken();

  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }



  // ========== USERNAME METHODS ==========
  Future<void> saveUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      print(' Username saved: $username');
    } catch (e) {
      print(' Error saving username: $e');
    }
  }

  //  add method want to  writeUsername
  Future<void> writeUsername(String username) => saveUsername(username);

  Future<String?> readUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_usernameKey);
      print(' Username read: $username');
      return username;
    } catch (e) {
      print(' Error reading username: $e');
      return null;
    }
  }

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

  //==== image =====
  Future<void> writeUserImage(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', url);
  }

  Future<String?> readUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image');
  }

  Future<void> deleteUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_image');
  }


  // ========== USER EMAIL METHODS ==========
  Future<void> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      print(' Email saved: $email');
    } catch (e) {
      print(' Error saving email: $e');
    }
  }

  Future<void> writeUserEmail(String email) => saveUserEmail(email);

  Future<String?> readUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_userEmailKey);
      print(' Email read from storage: $email');

      return email;
    } catch (e) {
      print(' Error reading email: $e');
      return null;
    }
  }



  // ========== USER ID METHODS ==========
  Future<void> saveUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, userId);
      print(' UserId saved: $userId');
    } catch (e) {
      print(' Error saving userId: $e');
    }
  }

  Future<void> writeUserId(int userId) => saveUserId(userId);

  Future<int?> readUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      print(' UserId read: $userId');
      return userId;
    } catch (e) {
      print(' Error reading userId: $e');
      return null;
    }
  }

  Future<int?> getUserId() => readUserId();

  Future<void> deleteUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      print('️ UserId deleted');
    } catch (e) {
      print(' Error deleting userId: $e');
    }
  }

  //==========about method full Name=========
  Future<void> saveFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullnameKey, fullName);
  }

  Future<String?> readFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullnameKey);
  }

  // all data user
  //new
  Future<void> saveUserData({
    required String token,
    required String username,
    required String email,
    required int userId,
    required String fullName,
  })
  async {
    await saveToken(token);
    await saveUsername(username);
    await saveUserEmail(email);
    await saveUserId(userId);
    await saveFullName(fullName);
  }

  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>> getAllUserInfo() async {
    return {
      'token': await readToken(),
      'username': await readUsername(),
      'email': await readUserEmail(),
      'userId': await readUserId(),
      'full_name' : await readFullName(),
    };
  }
}