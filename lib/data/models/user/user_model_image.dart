class UserModelImage {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String image;


  UserModelImage({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.image,

});

  factory UserModelImage.formJson(Map<String , dynamic> json ){
    return UserModelImage(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        fullName: json['fullName'],
        image: json['image']?? "",
    );
  }
}