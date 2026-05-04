import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';

class CartMain extends StatefulWidget {

  const CartMain({super.key});

  @override
  State<CartMain> createState() => _CartMainState();
}

class _CartMainState extends State<CartMain> {
  int? userId;
  String? username;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Cart page show in console
    print('|=================================================|');
    print('|              Cart Page Loads                    |');
    print('|=================================================|');
  }

  Future<void> _loadUserData() async {
    final id = await TokenStorage().readUserId();
    final user_name = await TokenStorage().readUsername();
    final usertoken = await TokenStorage().readToken();

    if (!mounted) return;

    setState(() {
      userId = id;
      username = user_name;
      token = usertoken;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || token == null) {
      // Wait for userId/token to load
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CartScreen(
        userId: userId!,   //  non-nullable now
        token: token!,     //  non-nullable now
      ),
    );
  }
}