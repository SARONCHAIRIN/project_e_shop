import 'package:e_shop/Presentation/screen/map/map_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/address/address_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../order/paymentScreen.dart';

class AddAddressPage extends StatefulWidget {
  final AddressRepository repo;
  final TokenStorage storage;
  const AddAddressPage({
    super.key,
    required this.repo,
    required this.storage,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final citycontroller = TextEditingController();
  final countrycontroller = TextEditingController();
  final addressline1controller = TextEditingController();
  final zipcodecontroller = TextEditingController();
  bool is_loading = false;



 @override
  void dispose(){
   citycontroller.dispose();
   countrycontroller.dispose();
   addressline1controller.dispose();
   zipcodecontroller.dispose();
   super.dispose();
  }


  void submit() async {
    setState(() => is_loading = true);

    try {
      final userId = await widget.storage.getUserId();
      final token  = await widget.storage.getToken();

      if (userId == null || token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please login again.')),
        );
        return;
      }

      final address = AddressModel(
        city:         citycontroller.text.trim(),
        country:      countrycontroller.text.trim(),
        addressline1: addressline1controller.text.trim(),
        zipcode:      zipcodecontroller.text.trim(),
        isdefault:    true,
      );

      final savedAddress = await widget.repo.addAddress(
        userId:  userId,
        token:   token,
        address: address,
      );

      if (!mounted) return;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Address saved!'),
      //     backgroundColor: Colors.green,
      //   ),
      // );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            userId:    userId,
            token:     token,
            addressId: savedAddress.id!, // ← id=6 ពី API
          ),
        ),
      );

    } catch (e) {
      debugPrint('Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => is_loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
              SizedBox(height: 5,),

              //new Address
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text(
                  'New Address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 1,),

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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 6,),

              //build address line1
              _buildAddressline1(),
              SizedBox(height: 20,),

               //address line 1
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text(
                  'COUNTRY  ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 6,),

              //build address li6ne1
              _buildcountry(),
              SizedBox(height: 20,),

              //build city and zip code
              _buildCityandZipcode(),
              SizedBox(height: 25,),

              //build save address
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
     height: 60,
     decoration: BoxDecoration(

       borderRadius: BorderRadius.circular(10),
       color: Colors.white,
       boxShadow: [
         BoxShadow(
           blurRadius: 1,
           blurStyle: BlurStyle.outer,
           color: Colors.blue.shade200,
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
           fontSize: 19,
           fontWeight: FontWeight.w500,
         ),

         border: OutlineInputBorder(
           borderRadius: BorderRadius.circular(10),
           borderSide:BorderSide.none,
         ),
       ),
       style: TextStyle(
         color: Colors.black,
         fontSize: 20,
         fontWeight: FontWeight.w400,
       ),
     ),
   ),
 );

 Widget _buildcountry () =>  Padding(
   padding: const EdgeInsets.all(8.0),
   child: Container(
     width: double.infinity,
     height: 60,
     decoration: BoxDecoration(

       borderRadius: BorderRadius.circular(10),
       color: Colors.white,
       boxShadow: [
         BoxShadow(
           blurRadius: 1,
           blurStyle: BlurStyle.outer,
           color: Colors.blue.shade200,
         ),
       ],
     ),
     child: TextFormField(
       controller: countrycontroller,
       style: TextStyle(
         color: Colors.black,
         fontSize: 20,
         fontWeight: FontWeight.w400,
       ),

       decoration: InputDecoration(
        hintText : 'Cambodia',
         hintStyle: TextStyle(
           color: Colors.grey,
           fontSize: 19,
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
                   fontSize: 16,
                   fontWeight: FontWeight.w400,
                 ),
               ),
             ),
             SizedBox(height: 6,),

             //text  field
             Container(
               width: double.infinity,
               height: 60,
               decoration: BoxDecoration(

                 borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                     blurRadius: 1,
                     blurStyle: BlurStyle.outer,
                     color: Colors.blue.shade200,
                   ),
                 ],
               ),
               child: TextFormField(
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
                     fontSize: 19,
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
                   fontSize: 16,
                   fontWeight: FontWeight.w400,
                 ),
               ),
             ),
             SizedBox(height: 6,),

             Container(
               width: double.infinity,
               height: 60,
               decoration: BoxDecoration(

                 borderRadius: BorderRadius.circular(10),
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                     blurRadius: 1,
                     blurStyle: BlurStyle.outer,
                     color: Colors.blue.shade200,
                   ),
                 ],
               ),
             child: TextFormField(
             controller: zipcodecontroller,
             style: TextStyle(
             color: Colors.black,
             fontSize: 20,
             fontWeight: FontWeight.w400,
             ),

             decoration: InputDecoration(
             hintText : '10110',
             hintStyle: TextStyle(
             color: Colors.grey,
             fontSize: 19,
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
      child: is_loading
          ? _buildaftersave()
          : _buildbeforeSave(),
    ),
   );

  //before save
  Widget _buildaftersave() =>
      Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () {
                submit();
              },
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
                  SpinKitCircle(color: Colors.blue,size: 30,),
                  Text(
                    "Save Address",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
        ),
      );

  //after save
Widget _buildbeforeSave() => Padding(
  padding: const EdgeInsets.only(
    right: 20,
    left: 20,
  ),
  child: SizedBox(
     width: double.infinity,
     height: 50,
     child: OutlinedButton(
       onPressed: () {
         submit();
       },
       style: OutlinedButton.styleFrom(
         backgroundColor: Colors.blue.shade200,
         side: BorderSide(color: Colors.blue.shade200),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
         ),
         padding: EdgeInsets.symmetric(vertical: 16),
       ),
       child: Text(
         "Save Address",
         style: TextStyle(
           color: Colors.white,
           fontSize: 17,
           fontWeight: FontWeight.w600,
         ),
       ),
     ),
   ),
);

}
