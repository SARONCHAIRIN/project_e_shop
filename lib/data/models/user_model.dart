class UserModel {
  final int id;
  final String email;
  final String? name;
  final String username;
  final String token;
  final String? refreshToken;
  final String? fullName;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.username,
    required this.token,
    this.refreshToken,
    this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? loginUsername}) {
    final map = (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : Map<String, dynamic>.from(json);
    final fallback = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : {};
    final merged = {...map, ...fallback};

    print('Merged JSON in UserModel: $merged'); // Debug

    int id = int.tryParse((merged['id'] ?? merged['_id'] ?? '0').toString()) ?? 0;
    String email = (merged['email'] ?? '').toString();
    String? name = merged['username']?.toString();
    String username = loginUsername ?? merged['username'] ?? '';

    String token = (json['access_token'] ?? merged['access_token'] ?? json['token'] ?? '').toString();
    String? refreshToken = json['refresh_token']?.toString();

    String? fullName = (merged['fullName'] ?? merged['full_name'])?.toString();
    print('FullName parsed: $fullName'); // Debug

    return UserModel(
      id: id,
      email: email,
      name: name,
      username: username,
      token: token,
      refreshToken: refreshToken,
      fullName: fullName,
    );
  }
}