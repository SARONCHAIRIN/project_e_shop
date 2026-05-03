import 'package:e_shop/Presentation/screen/address/add_address_page.dart';
import 'package:e_shop/Presentation/screen/order/checkoutStepIndicator_page.dart';
import 'package:e_shop/Presentation/screen/order/paymentScreen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:e_shop/data/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';


class CheckoutPage extends StatefulWidget {
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
  State<CheckoutPage> createState() => _CheckoutPageState();
}


class _CheckoutPageState extends State<CheckoutPage> {
  int currentStep = 0;


  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      AddAddressPage(
        storage: widget.storage,
        repo: widget.repo,
      ),
      PaymentScreen(
          userId: widget.userId,
          token: widget.token,
          addressId: widget.addressId,
      ),
      ReviewPage(),
    ];
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
              SizedBox(width: 100,),
              Center(
                child: Text(
                  "Checkout",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 5,),

          // Step Indicator
          Padding(
            padding: const EdgeInsets.only(
              left: 50,
            ),
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
          Expanded(
            child: pages[currentStep],
          ),

           // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: prevStep,
                  child: Text("Back"),
                ),
                ElevatedButton(
                  onPressed: nextStep,
                  child: Text("Next"),
                ),
              ],
            ),
          ),



          SizedBox(height: 50,),
        ],
      ),
    );
  }
}

class AddressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Address Page"));
  }
}
class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
        body: Center(child: Text("Payment Page")));
  }
}
class ReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Review Page"));
  }
}