import 'package:e_shop/Presentation/screen/address/add_address_checkout.dart';
import 'package:e_shop/Presentation/screen/order/checkoutStepIndicator_page.dart';
import 'package:e_shop/Presentation/screen/payment/payment_method_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/cart_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final AddressRepository repo;
  final TokenStorage storage;

  const CheckoutPage({
    super.key,
    required this.repo,
    required this.storage,
    required this.userId,
    required this.token,
    required this.addressId,
  });

  final int userId;
  final String token;
  final int addressId;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int currentStep = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
  }

  void nextStep() {
    if (currentStep < pages.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cartState = ref.watch(cartControllerProvider);
    final total = cartState.cart?.totalPrice ?? 0;





    final pages = [

      AddAddressCheckout(storage: widget.storage, repo: widget.repo),

      PaymentMethodScreen(

        addressId: widget.addressId,

        totalPrice: total,

      ),

    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 50),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
              Spacer(),

              const Text(
                "Checkout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 30,),
              Spacer(),
            ],
          ),
          SizedBox(height: 5),

          // Step Indicator
          Padding(
            padding: EdgeInsets.only(left: width * 0.20),
            child: CheckoutStepIndicator(
              currentStep: currentStep,
              onStepTap: (step) {
                setState(() {
                  currentStep = step;
                });
              },
            ),
          ),

          SizedBox(height: 10),

          //  Page Content
          Expanded(child: pages[currentStep]),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
