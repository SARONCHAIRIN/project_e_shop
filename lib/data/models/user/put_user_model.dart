/*


class PutUserModel {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String birthdate;

  PutUserModel({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.birthdate,
  });

  factory PutUserModel.formJson(Map<String , dynamic> json){
    return PutUserModel(

      email: json['email'],
      password: json['password'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      birthdate: json['birthdate'],
    );
  }


Map<String, dynamic> toJson() {
  return {
    "email": email,
    "password": password,
    "fullName": fullName,
    "phoneNumber": phoneNumber,
    "birthdate": birthdate,
  };
}
}*/

class PutUserModel {
  final String? email;
  final String? password;
  final String? fullName;
  final String? phoneNumber;
  final String? birthdate;

  PutUserModel({
    this.email,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.birthdate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null && email!.isNotEmpty) "email": email,
      if (password != null && password!.isNotEmpty) "password": password,
      if (fullName != null && fullName!.isNotEmpty) "fullName": fullName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) "phoneNumber": phoneNumber,
      if (birthdate != null && birthdate!.isNotEmpty) "birthdate": birthdate,
    };
  }
}
