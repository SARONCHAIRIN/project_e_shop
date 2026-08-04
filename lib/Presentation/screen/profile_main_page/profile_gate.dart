import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';

import 'profile_main.dart';
import 'guest_profile_main.dart';

class ProfileGate extends StatefulWidget {
  final dynamic repository;

  const ProfileGate({super.key, required this.repository});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  int? userId;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    checkUser();
  }

  Future<void> checkUser() async {
    final id = await TokenStorage().readUserId();

    if (!mounted) return;

    setState(() {
      userId = id;

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userId == null || userId == 0) {
      return GuestProfileMain(repository: widget.repository);
    }

    return ProfileMain(authRepository: widget.repository);
  }
}
