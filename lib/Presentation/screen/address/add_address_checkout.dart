import 'package:e_shop/Presentation/screen/map/map_screen.dart';
import 'package:e_shop/Presentation/screen/payment/payment_method_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/address/address_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../order/paymentScreen.dart';

class AddAddressCheckout extends StatefulWidget {
  final AddressRepository repo;
  final TokenStorage storage;
  const AddAddressCheckout({
    super.key,
    required this.repo,
    required this.storage,
  });

  @override
  State<AddAddressCheckout> createState() => _AddAddressCheckoutState();
}

class _AddAddressCheckoutState extends State<AddAddressCheckout> {
  final citycontroller = TextEditingController();
  final countrycontroller = TextEditingController();
  final addressline1controller = TextEditingController();
  final zipcodecontroller = TextEditingController();
  bool is_loading = false;
  bool _isEditingMode = false;
  int? _existingAddressId;
  FocusNode zipcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  Future<void> _loadExistingAddress() async {
    try {
      final userId = await widget.storage.getUserId();
      final token = await widget.storage.getToken();

      if (userId == null || token == null) return;

      // Fetch user's address
      final address = await widget.repo.getAddressById(
        userId: userId,
        token: token,
      );

      if (address != null) {
        setState(() {
          _isEditingMode = true;
          _existingAddressId = address.id;
          citycontroller.text = address.city ?? '';
          countrycontroller.text = address.country ?? '';
          addressline1controller.text = address.addressline1 ?? '';
          zipcodecontroller.text = address.zipcode ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  @override
  void dispose(){
    citycontroller.dispose();
    countrycontroller.dispose();
    addressline1controller.dispose();
    zipcodecontroller.dispose();
    zipcodeFocusNode.dispose();
    super.dispose();
  }


  void submit() async {
    setState(() => is_loading = true);

    try {
      final userId = await widget.storage.getUserId();
      final token = await widget.storage.getToken();

      if (userId == null || token == null) {
        if (!mounted) return;
        _showSnackBar('Session expired. Please login again.', isError: true);
        return;
      }

      // Validate inputs
      if (addressline1controller.text.isEmpty || 
          countrycontroller.text.isEmpty ||
          citycontroller.text.isEmpty ||
          zipcodecontroller.text.isEmpty) {
        if (!mounted) return;
        _showSnackBar('Please fill all fields', isError: true);
        setState(() => is_loading = false);
        return;
      }

      final address = AddressModel(
        id: _existingAddressId,
        city: citycontroller.text.trim(),
        country: countrycontroller.text.trim(),
        addressline1: addressline1controller.text.trim(),
        zipcode: zipcodecontroller.text.trim(),
        isdefault: true,
      );

      late AddressModel savedAddress;

      if (_isEditingMode && _existingAddressId != null) {
        // Update existing address
        await widget.repo.updateAddress(
          userId: userId,
          token: token,
          addressId: _existingAddressId!,
          address: address,
        );
        savedAddress = address;
        // if (mounted) _showSnackBar('Address updated successfully', isError: false);
      } else {
        // Create new address
        savedAddress = await widget.repo.addAddress(
          userId: userId,
          token: token,
          address: address,
        );
        // if (mounted) _showSnackBar('Address saved successfully', isError: false);
      }

      if (!mounted) return;

      // Navigate to payment screen
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              //     PaymentScreen(
              //   userId: userId,
              //   token: token,
              //   addressId: savedAddress.id!,
              // ),
              PaymentMethodScreen(
                  totalPrice: 10, addressId: savedAddress.id!,
                  addressLine1: 'test', city: 'test', country: 'test', zipCode: 'test001')
            ),
          );
        }
      });

    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      _showSnackBar('Failed!!', isError: true);
    } finally {
      if (mounted) setState(() => is_loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              SizedBox(height: 10,),

              // Title - shows "Update Address" or "New Address" based on mode
              Padding(
                padding: EdgeInsets.only(left: 5,),
                child: Text(
                  _isEditingMode ? 'Update Address' : 'New Address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10,),

              _buildaddressMap(),
              SizedBox(height: 20,),


              //address line 1
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text(
                  'ADDRESS LINE 1 ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 6,),

              //build address line1
              _buildAddressline1(),
              SizedBox(height: 20,),

              // Country
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text(
                  'COUNTRY  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 6,),
              _buildcountry(),
              SizedBox(height: 20,),

              //build city and zip code
              _buildCityandZipcode(),
              SizedBox(height: 25,),

              // Save/Update Address Button
              _BuildSaveAddress(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildaddressMap() => GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen()));
    },
    child: Container(

      width: double.infinity,
      height: 450,
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
            color: Colors.blue.shade200,
          ),
        ],
      ),
      child: MapScreen(),
    ),
  );

  Widget _buildAddressline1 () =>  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
            color: Colors.grey.shade200,
          ),
        ],
      ),

      child: TextFormField(

        controller: addressline1controller,

        decoration: InputDecoration(
          fillColor: Colors.blue,
          hintText : '123 Precision Way',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:BorderSide.none,
          ),
        ),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );

  Widget _buildcountry () =>  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
            color: Colors.grey.shade100,
          ),
        ],
      ),
      child: TextFormField(
        controller: countrycontroller,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),

        decoration: InputDecoration(
          hintText : 'Cambodia',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:BorderSide.none,
          ),
        ),
      ),
    ),
  );

  Widget _buildCityandZipcode () =>  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [

        //city
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //text city
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  'CITY  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 6,),

              //text  field
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer,
                      color: Colors.grey.shade100,
                    ),
                  ],
                ),
                child: TextFormField(
                  // focusNode: zipcodeFocusNode,
                  controller: citycontroller,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText : 'PHNOM PENH',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10,),

        //ZIP CODE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //text zip code
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  'ZIP CODE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 6,),

              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 1,
                      blurStyle: BlurStyle.outer,
                      color: Colors.grey.shade200,
                    ),
                  ],
                ),
                child: TextFormField(
                  focusNode: zipcodeFocusNode,
                  controller: zipcodecontroller,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),

                  decoration: InputDecoration(
                    hintText : '10110',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );


  //====build save address====

  Widget _BuildSaveAddress() => Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 10
    ),
    child: Container(
      child: is_loading ? _buildLoadingButton() : _buildSaveButton(),
    ),
  );

  // Loading state button
  Widget _buildLoadingButton() => Padding(
    padding: const EdgeInsets.only(left: 20, right: 20,),
    child: SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: null, // disabled during loading
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue.shade200),
          backgroundColor: Colors.blue.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(color: Colors.blue, size: 30,),
            SizedBox(width: 10,),
            Text(
              _isEditingMode ? "Updating..." : "Saving...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // Save/Update button
  Widget _buildSaveButton() => Padding(
    padding: const EdgeInsets.only(right: 20, left: 20,),
    child: SizedBox(

      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          submit();
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          side: BorderSide(color: Colors.blue.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isEditingMode ? "Update Address" : "Save Address",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

}
