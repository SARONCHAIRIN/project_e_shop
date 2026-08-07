import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/storage/token_storage.dart';

class CartMain extends StatefulWidget {
  final User_AuthRepository repository;

  const CartMain({super.key, required this.repository});

  @override
  State<CartMain> createState() => _CartMainState();
}

class _CartMainState extends State<CartMain> {
  int? userId;
  String? username;
  String? token;
  final reposotory = User_AuthRepository;

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

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginBottomSheet1(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || token == null) {
      // Wait for userId/token to load

      return Scaffold(
        backgroundColor: Colors.grey.shade50,

        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Text(
            'cart'.tr(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: _buildEmptyCart(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CartScreen(
        userId: userId!, //  non-nullable now
        token: token!, //
        // non-nullable now
      ),
    );
  }

  //userid && token =  null = empty
  Widget _buildEmptyCart() => Center(
    child: SingleChildScrollView(
      child: Container(
        width: Responsive.isMobile(context)
            ? double.infinity
            : 600,

        padding: EdgeInsets.all(
          Responsive.isMobile(context)
              ? 20
              : 40,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildlogiregister(),

            SizedBox(
              height: Responsive.isMobile(context)
                  ? 20
                  : 30,
            ),

            Lottie.asset(
              'assets/animations/empty.json',

              width: Responsive.isMobile(context)
                  ? 200
                  : 280,

              height: Responsive.isMobile(context)
                  ? 200
                  : 280,

              repeat: true,
            ),

            const SizedBox(height: 20),

            Text(
              'cart_empty'.tr(),

              style: TextStyle(
                color: Colors.blueAccent,

                fontSize:
                Responsive.isMobile(context)
                    ? 18
                    : 24,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildlogiregister() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.fromLTRB(24, 40, 24, 32),
    child: Column(
      children: [
         Text(
          'sign_in_account'.tr(),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'access_orders'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => _showLoginSheet(context),

            child:  Text(
              'sign_in_register'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );


}
