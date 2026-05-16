import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/storage/token_storage.dart';
import '../auth/login/login_screen.dart';
import '../auth/signup/signup_screen.dart';

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

      return  Scaffold(
        backgroundColor: Colors.grey.shade50,

        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text('Cart',style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),),
        ),
        body: _buildEmptyCart(),

      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CartScreen(
          userId: userId!,   //  non-nullable now
          token: token!,     //
          // non-nullable now
        ),
    );
  }

//userid && token =  null = empty
  Widget _buildEmptyCart() => Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          _buildlogiregister(),
          SizedBox(height: 20,),

          Center(
            child: Lottie.asset(
              'assets/animations/empty.json',
              width: 200,
              height: 200,
              repeat: true,
              animate: true,
            ),
          ),
          SizedBox(height: 20,),

          Text("Cart is empty",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),),
          SizedBox(height: 30,),
        ],
      ));

  Widget _buildlogiregister() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    margin: EdgeInsets.symmetric(
        horizontal: 20
    ),
    padding:  EdgeInsets.fromLTRB(24, 40, 24, 32),
    child: Column(
      children: [
        const Text('Sign in to your account',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Access your orders, wishlist,\nand exclusive deals',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:  Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login',(route) => false),
            child: const Text('Sign in',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/register',(route) => false),
            child: const Text('Create account', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    ),
  );

}