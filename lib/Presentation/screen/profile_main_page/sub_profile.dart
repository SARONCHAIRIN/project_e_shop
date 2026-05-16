
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/address/list_my_address.dart';
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/profile_image_picker.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/setting_page.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:e_shop/data/models/user/get_user_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/user/get_user_Id_service.dart';

class Profilepage extends StatefulWidget {

  final authRepository;
  const Profilepage({
    super.key,
    required this.authRepository,
  });

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {

  String? username;
  String? email;
  bool _isLoading = true;
  bool _isloadinged = false;
  GetUserModel? user;

  File? _image;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();


  //======call address==========

  final serviceaddress = AddressService();
  final getAddressid = GetUserIdService();
  late final repoaddress  = AddressRepository(serviceaddress);
  final storage = TokenStorage();
  //==========================


  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadUser();
    _loadSavedImage();
  }




  Future<void> _loadUser() async {
    try {
      final storage = TokenStorage();

      // wait a little
      await Future.delayed(const Duration(milliseconds: 100));

      final name = await storage.readUsername();
      final storedEmail = await storage.readUserEmail();

      // fallback: if email is empty, use username
      final emailToShow = (storedEmail?.isNotEmpty == true) ? storedEmail : name;

      if (mounted) {
        setState(() {
          username = name;
          email = emailToShow;
          _isLoading = false;
        });
      }

      final allInfo = await storage.getAllUserInfo();
      print('All storage info: $allInfo');
      print('Final username: $username');
      print('Final email: $email');
      print('===========================');
    } catch (e) {
      print('Error loading user: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> fetchUser() async {
    print("fetch start");

    try {
      final userId = await TokenStorage().getUserId();
      print("user ID $userId");

      if (userId == null) {
        print('No userId');
        setState(() => _isloadinged = false);
        return;
      }

      //  use authenticatedGet — auto refresh token when 401
      final response = await widget.authRepository
          .authenticatedGet('/user/$userId/user');

      print("API RESULT: $response");

      // null refresh fail → back to login
      if (response == null) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(authRepository: widget.authRepository),
          ),
              (route) => false,
        );
        return;
      }

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        final body = response.body;
        print('RESPONSE BODY: $body'); //
        final data = jsonDecode(body);
        print('PARSED DATA: $data');

        final userData = data['data'];
        print('USER DATA: $userData');

        // save image URL when fetch
        if (userData['image'] != null && userData['image'].toString().isNotEmpty) {
          await TokenStorage().writeUserImage(userData['image']);
          if (mounted) setState(() => _uploadedImageUrl = userData['image']);
        }

        if(mounted){
          setState(() {
            user = GetUserModel.fromJson(userData);
            _isloadinged = false;
          });
        }

        print('User email: ${user?.email}');
        print('User name: ${user?.username}');
      } else {
        print('Failed: ${response.statusCode} - ${response.body}');
        setState(() => _isloadinged = false);
      }

    } catch (e) {
      print('fetchUser error: $e');
      setState(() => _isloadinged = false);
    }
  }

  // load saved image from storage
  Future<void> _loadSavedImage() async {
    final storage = TokenStorage();
    final savedImage = await storage.readUserImage();

    if (savedImage != null) {
      setState(() {
        _uploadedImageUrl = savedImage;
      });
    }
  }


  //pick image to profile
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isUploading = true;
        });

        //  CALL UPLOAD API
        final imageUrl = await _uploadImage(File(pickedFile.path));

        if (imageUrl != null) {
          await TokenStorage().writeUserImage(imageUrl);

          setState(() {
            _uploadedImageUrl = imageUrl;
            _image = null; // use network image after upload
          });
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final token = await TokenStorage().getToken();
      final userId = await TokenStorage().getUserId();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('YOUR_API_URL/user/$userId'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);

        return data['data']['image']; //  new image URL
      } else {
        print("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Upload error: $e");
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body  : _buildBody(),
      backgroundColor: Colors.grey.shade50,

    );
  }


  Widget _buildBody() => SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Column(
        children: [
          SizedBox(height: 80,),

          // Profile image
          Stack(
            children: [

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent,
                      blurStyle: BlurStyle.outer,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade50, // optional background
                  child: _buildProfileImage(),
                ),
              ),

              //edit profile
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 40,
                  height: 40 ,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 1,
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),

                  //icon edit
                  child: IconButton(

                    onPressed: () async{

                      try {
                        final tokenStorage = TokenStorage();
                        final token = await tokenStorage.getToken();
                        final userId = await tokenStorage.getUserId();
                        final username = await tokenStorage.getUsername();
                        final email = await tokenStorage.readUserEmail();

                        print('all data : ${tokenStorage.getAllUserInfo()}');

                        if (token != null && username != null && email != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(
                                      username: username,
                                      token: token,
                                      email: email,
                                    )
                            ),
                          );

                          // back reload data
                          await _loadSavedImage();
                          await fetchUser();
                        }
                      } catch (e) {
                        print("Error: $e");
                      }
                    },
                    icon: Icon(Icons.edit,size: 26,color: Colors.blue,),
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(width: 20),

          // username
          Text(
            username?.isNotEmpty == true ? username! : 'User',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          //email
          Text(
            user?.email ?? 'user@email.com',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10,),


          //ACTIVITY
          Padding(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
            ),
            child: Column(
              children: [

                //text activity
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ACTIVITY',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                // type of activity
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  width :double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade50,
                        blurStyle: BlurStyle.outer,
                        blurRadius: 0.1,
                      ),
                    ],
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      //row of order history
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(2),
                              color: Colors.blue.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 1,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            child: Icon(Icons.fax_rounded,size: 25,color: Colors.indigoAccent,),
                          ),

                          SizedBox(width: 30,),

                          Expanded(
                            child: Text('Order History',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),

                          IconButton(onPressed: (){

                          },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),

                          ),
                        ],
                      ),

                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                      ),

                      //row of Saved Address
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(2),
                              color: Colors.blue.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 1,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            child: Icon(Icons.location_on_outlined,size: 25,color: Colors.indigoAccent,),
                          ),

                          SizedBox(width: 30,),

                          Expanded(
                            child: Text('Saved Address',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),

                          IconButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AddressListPage(
                              repo: repoaddress,
                              storage: storage,

                            ),),);
                          },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                      ),

                      //row of payment method
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(2),
                              color: Colors.blue.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue,
                                  blurRadius: 1,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            child: Icon(Icons.payments_outlined,size: 25,color: Colors.indigoAccent,),
                          ),

                          SizedBox(width: 30,),

                          Expanded(
                            child: Text('Payment Methods',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),

                          IconButton(onPressed: (){

                          },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),


          //ACCOUNT
          Padding(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
            ),
            child: Column(
              children: [

                //text activity
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ACCOUNT',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 5,),

                // type of activity
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  width :double.infinity,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade50,
                        blurStyle: BlurStyle.outer,
                        blurRadius: 0.1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      //row of setting
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(2),
                              color: Colors.grey.shade100,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            child: Icon(Icons.settings,size: 25,color: Colors.grey,),
                          ),

                          SizedBox(width: 30,),

                          Expanded(
                            child: Text('Settings',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),

                          IconButton(onPressed: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context) => SettingPage(authRepository: widget.authRepository,)));
                          },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),

                          ),
                        ],
                      ),

                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                      ),


                      //row of logout
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius:BorderRadius.circular(2),
                              color: Colors.red.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade200,
                                  blurRadius: 1,
                                  blurStyle: BlurStyle.outer,
                                ),
                              ],
                            ),
                            child: Icon(Icons.logout,size: 25,color: Colors.red,),
                          ),

                          SizedBox(width: 30,),


                          Expanded(
                            child: Text('Logout',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,

                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    title: Text('Confirm Logout'),
                                    content: Text('Are you sure you want to logout?'),
                                    icon: Icon(Icons.phonelink_lock_outlined,size: 30,color: Colors.blueAccent,),

                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context,false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context,true),
                                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if(confirm != true) return;

                              await widget.authRepository.logout
                                ();

                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => DivicesNav(authRepository: widget.authRepository)),
                                    (route) => false,
                              );
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 100,),
        ],
      ),
    ),
  );


  Widget _buildProfileImage() {

    if (_image != null) {
      return ClipOval(
        child: Image.file(
          _image!,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    } else if (_uploadedImageUrl != null) {
      return Stack(
        children: [

          ClipOval(
            child: CachedNetworkImage(
              imageUrl: "${_uploadedImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}",
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 140,
                height: 140,
                color: Colors.blue.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.person, size: 70),
            ),
          ),
        ],
      );
    } else {
      return const Icon(Icons.person, size: 70,color:Colors.grey,);
    }
  }


}
