
import 'package:e_shop/Presentation/screen/profile_main_page/sub_profile.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:flutter/material.dart';

class ProfileMain extends StatefulWidget {
  final authRepository;
  const ProfileMain({
    super.key,
    required this.authRepository,
  });

  @override
  State<ProfileMain> createState() => _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {

  // call post address
  final service = AddressService();
  // late final repo = AddressRepository(service,);
  final storage = TokenStorage();

  @override
  void initState() {
    super.initState();
      // Profile page show in console
    print('|=================================================|');
    print('|              Profile Page Loads                 |');
    print('|=================================================|');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Profilepage(
        authRepository: widget.authRepository,
      ),
      // body: MapScreen(),
    );
  }
}
