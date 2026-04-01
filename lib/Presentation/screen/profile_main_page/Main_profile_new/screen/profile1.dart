import 'package:e_shop/Presentation/screen/profile_main_page/Main_profile_new/widget/upload_image_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:flutter/material.dart';

class Profile1 extends StatefulWidget {
  final  authRepository ; // Add this
  const Profile1({
    super.key,
    required this.authRepository,
  });

  @override
  State<Profile1> createState() => _Profile1State();
}

class _Profile1State extends State<Profile1> {
  String? username;
  String? email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final storage = TokenStorage();

      // Add delay to ensure storage is ready
      await Future.delayed(const Duration(milliseconds: 100));

      final name = await storage.readUsername();
      final userEmail = await storage.readUserEmail();

      // Debug prints
      print('===== PROFILE LOADING =====');
      print('Raw username from storage: $name');
      print('Raw email from storage: $userEmail');

      // Get all info to verify
      final allInfo = await storage.getAllUserInfo();
      print('All storage info: $allInfo');

      if (mounted) {
        setState(() {
          username = name;
          email = userEmail;
          _isLoading = false;
        });
      }

      print('Final username: $username');
      print('Final email: $email');
      print('===========================');
    } catch (e) {
      print('Error loading user: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // _buildMainProfile(),

            UploadImageScreen(),
          //
          ],
        ),
      ),
    );
  }

  Widget _buildMainProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [


          Row(
            children: [
              const SizedBox(width: 15),

              // Profile image
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      username?.isNotEmpty == true ? username! : 'User',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      email?.isNotEmpty == true ? email! : 'User@gmail.com',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}