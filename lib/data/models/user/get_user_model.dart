class GetUserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? image;
  final String? password;

  GetUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.image,
    required this.password,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      image: json['image']??'',
      password: json['password'],
    );
  }
}