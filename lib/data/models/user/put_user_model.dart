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
      // if (password != null && password!.isNotEmpty)
        "password": password,
      if (fullName != null && fullName!.isNotEmpty) "fullName": fullName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty) "phoneNumber": phoneNumber,
      if (birthdate != null && birthdate!.isNotEmpty) "birthdate": birthdate,
    };
  }
}
