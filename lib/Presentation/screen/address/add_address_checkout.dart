import 'package:e_shop/Presentation/screen/map/map_screen.dart';
import 'package:e_shop/Presentation/screen/payment/payment_method_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/address/address_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../data/repositories/order_repository.dart';

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

  final OrderRepository _orderRepository = OrderRepository();
  double? totalPrice;

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
    _loadOrderTotal();
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
          citycontroller.text = address.city;
          countrycontroller.text = address.country;
          addressline1controller.text = address.addressline1;
          zipcodecontroller.text = address.zipcode;
        });
      }
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  @override
  void dispose() {
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
        _showSnackBar('session_expired'.tr(), isError: true);
        return;
      }

      // Validate inputs
      if (addressline1controller.text.isEmpty ||
          countrycontroller.text.isEmpty ||
          citycontroller.text.isEmpty ||
          zipcodecontroller.text.isEmpty) {
        if (!mounted) return;
        _showSnackBar('please_fill_all_fields'.tr(), isError: true);
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
              builder: (_) => PaymentMethodScreen(
                totalPrice: totalPrice ?? 0.0,
                addressId: savedAddress.id!,
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      _showSnackBar( 'failed'.tr(), isError: true);
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

  Future<void> _loadOrderTotal() async {
    try {
      final userId = await widget.storage.getUserId();
      final token = await widget.storage.getToken();

      if (userId == null || token == null) return;

      final result = await _orderRepository.getOrders(
        userId: userId,
        token: token,
        page: 1,
        limit: 1,
      );

      if (result.orders.isNotEmpty) {
        setState(() {
          totalPrice = result.orders.first.totalAmount ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error loading total price: $e');
    }
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
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              SizedBox(height: 10),

              // Title - shows "Update Address" or "New Address" based on mode
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  _isEditingMode ? "update_address".tr() : "new_address".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10),

              _buildaddressMap(),
              SizedBox(height: 10),

              //address line 1
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "address_line_1".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              //build address line1
              _buildAddressline1(),
              SizedBox(height: 10),

              // Country
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  "country".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _buildcountry(),

              //build city and zip code
              _buildCityandZipcode(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BuildSaveAddress(),
    );
  }

  Widget _buildaddressMap() => GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen()));
    },
    child: Container(
      width: double.infinity,
      height: 320,
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

  Widget _buildAddressline1() => Padding(
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
          hintText: 'address_example'.tr(),
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
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

  Widget _buildcountry() => Padding(
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
          hintText:'cambodia'.tr(),
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ),
  );

  Widget _buildCityandZipcode() => Padding(
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
                  "city".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

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
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText:'phnom_penh'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),

        //ZIP CODE
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //text zip code
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  "zip_code".tr(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

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
                    hintText: 'zip_code_example'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
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
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Container(
      child: is_loading ? _buildLoadingButton() : _buildSaveButton(),
    ),
  );

  // Loading state button
  Widget _buildLoadingButton() => SizedBox(
    width: double.infinity,
    height: 40,
    child: OutlinedButton(
      onPressed: null, // disabled during loading
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.blue.shade200),
        backgroundColor: Colors.blue.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(color: Colors.blue, size: 30),
          SizedBox(width: 10),
          Text(
            _isEditingMode ? "updating".tr() : "saving".tr(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  // Save/Update button
  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    height: 40,
    child: OutlinedButton(
      onPressed: () {
        submit();
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        side: BorderSide(color: Colors.blue.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        _isEditingMode ? "update_address".tr() : "save_address".tr(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
