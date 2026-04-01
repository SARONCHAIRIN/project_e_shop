
import 'package:e_shop/data/models/user/put_user_model.dart';
import 'package:e_shop/data/repositories/user/put_user_repo.dart';
import 'package:flutter/material.dart';

class ProfileUpdateController {

  final PutUserRepo repository;

  ProfileUpdateController(this.repository);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final birthController = TextEditingController();


  Future<void> updateProfile(int userId) async {

    PutUserModel user = PutUserModel(
      email: emailController.text,
      password: passwordController.text,
      fullName: nameController.text,
      phoneNumber: phoneController.text,
      birthdate: birthController.text,
    );

    bool success = await repository.updateUser(userId, user);

    if (success) {
      print("Update success");
    } else {
      print("Update failed");
    }
  }


}