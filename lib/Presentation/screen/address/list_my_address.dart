import 'package:e_shop/Presentation/screen/address/add_address_page.dart';
import 'package:e_shop/data/models/address/address_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';

class AddressListPage extends StatefulWidget {
  final AddressRepository repo;
  final TokenStorage storage;

  const AddressListPage({
    super.key,
    required this.repo,
    required this.storage,
  });

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<AddressModel> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  //delete address by id
  Future<void> deleteAddress(int id) async {
    final userId = await widget.storage.getUserId();
    final token = await widget.storage.getToken();

    if (userId == null || token == null) {
      print("Missing userId or token");
      return;
    }

    try {
      await widget.repo.deleteAddress(
        id: id,
        userId: userId,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Deleted successfully ")),
      );

      // load(); //  refresh list
    } catch (e) {
      print("Error $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed ")),
      );
    }
  }
  //add to cart more
  Future<void> goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressPage(
          repo: widget.repo,
          storage: widget.storage,
        ),
      ),
    );

    if (result == true) {
      loadData(); //  refresh after add
    }
  }

  Future<void> loadData() async {
    final userId = await widget.storage.getUserId();
    final token = await widget.storage.getToken();

    final data = await widget.repo.fecthAddressbyUserId(
      userId: userId!,
      token: token!,
    );

    setState(() {
      list = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(backgroundColor: Colors.white,
        title: Text("My Address",),
      actions:[
        IconButton(onPressed: () => goToAdd(),
          icon:Icon(Icons.add,size: 30,color: Colors.red,)),
      ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];

        return   Padding(

          padding: const EdgeInsets.all(8.0),
          child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TOP ROW
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.home, color: Colors.blue),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // title,
                              'title',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),

                          if (item.isdefault)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "DEFAULT",
                                style: TextStyle(color: Colors.blue, fontSize: 12),
                              ),
                            )
                        ],
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: ()
                        => (item.id),
                        // onEdit,
                        icon: const Icon(Icons.edit, color: Colors.grey),
                      ),

                      IconButton(
                        onPressed:(){
                         // deleteAddress(item.id)
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// NAME
                  Text(
                    // name,
                      'name',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),

                  const SizedBox(height: 6),

                  /// row of ADDRESS
                  Row(
                    children: [

                      // address line 1
                      Text(
                          item.addressline1,
                          style: const TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.w500)),

                      Text(' , ',style: TextStyle(color: Colors.grey,fontSize: 16),),

                      //  city
                      Text(
                          item.city,
                          style: const TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.w500)),

                      Text(' , ',style: TextStyle(color: Colors.grey,fontSize: 16),),


                    ],
                  ),

                  // row of ADDRESS
                  Row(
                    children: [
                      // zip code
                      Text(
                          item.zipcode,
                          style: const TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.w500)),

                      Text(' , ',style: TextStyle(color: Colors.grey,fontSize: 16),),

                      //country
                      Text(
                          item.country,
                          style: const TextStyle(color: Colors.grey,fontSize: 18,fontWeight: FontWeight.w500)),
                    ],
                  ),



                  const Divider(height: 20),

                  /// PHONE
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        // phone
                        'phone number',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// SET DEFAULT BUTTON
                  if (!item.isdefault)
                    Center(
                      child: OutlinedButton(
                        onPressed:(){
                          // onSetDefault,
                        },
                        child: const Text("SET AS DEFAULT"),
                      ),
                    ),
                ],
              ),
            ),
        );
        },
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: ,
      //   child: Icon(Icons.add),
      // ),
    );
  }


  //cart clean address

  Widget addressCard({
    required String title,
    required String name,
    required String address,
    required String phone,
    bool isDefault = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onSetDefault,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP ROW
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home, color: Colors.blue),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),

                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "DEFAULT",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                ],
              ),

              const Spacer(),

              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.grey),
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// NAME
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),

          const SizedBox(height: 6),

          /// ADDRESS
          Text(address,
              style: const TextStyle(color: Colors.grey)),

          const Divider(height: 20),

          /// PHONE
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(phone),
            ],
          ),

          const SizedBox(height: 12),

          /// SET DEFAULT BUTTON
          if (!isDefault)
            OutlinedButton(
              onPressed: onSetDefault,
              child: const Text("SET AS DEFAULT"),
            ),
        ],
      ),
    );
  }
}