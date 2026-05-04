
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shop/Presentation/controllers/user/put_user_controller.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/user/put_info_user.dart';
import 'package:e_shop/data/datasources/user/get_user_Id_service.dart';
import 'package:e_shop/data/datasources/user/put_user_service.dart';
import 'package:e_shop/data/models/user/get_user_model.dart';
import 'package:e_shop/data/repositories/user/put_user_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/user/put_user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String token;
  final String? currentImageUrl;
  final String email;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.token,
    this.currentImageUrl,
    required this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? email;
  String? username;
  bool _isLoading = true;
  String? full_name;
  GetUserModel? user;
  bool _isloading = true;

  // late ProfileUpdateController controller;
  late PutUserController controller;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchUser();
    _loadUser();
    _loadSavedImage();
    _initController();
    _loadUserData();

    print('full name: ${user?.fullName}, email: ${user?.email}');

  }
  void _initController() {
    final userService = PutUserService();
    final repo = PutUserRepo(userService);
    controller = PutUserController(repo);
  }

  Future<void> fetchUser() async {
    final token = await TokenStorage().getToken();
    final userId = await TokenStorage().getUserId();

    if (token != null && userId != null) {
      final result = await GetUserIdService().getUserById(userId, token);

      //  save image URL in storage
      if (result?.image != null && result!.image!.isNotEmpty) {
        await TokenStorage().writeUserImage(result.image!);
        setState(() => _uploadedImageUrl = result.image);
        print('Image saved : ${result.image}');
      }
      setState(() {
        user = result;
        // fill controllers with API data
        nameController.text = user?.fullName ?? '';
        emailController.text = user?.email ?? '';
        _isloading = false;
      });
    } else {
      setState(() => _isloading = false);
    }
  }


  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final token = await TokenStorage().getToken();
    final userId = await TokenStorage().getUserId();
    if (token != null && userId != null) {
      final result = await GetUserIdService().getUserById(userId, token);

      setState(() {
        user = result;
        nameController.text = user?.fullName ?? '';
        emailController.text = user?.email ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedImage() async {
    final storage = TokenStorage();
    final savedImage = await storage.readUserImage();
    if (savedImage != null) {
      setState(() {
        _uploadedImageUrl = savedImage;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final storage = TokenStorage();

      username = await storage.readUsername();
      email = await storage.readUserEmail();


    } catch (e) {
      print("Error loading user: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final XFile? pickedFile = await _picker.pickImage(
  //         source: source,
  //         imageQuality: 70,
  //         maxWidth: 1024,
  //         maxHeight: 1024,
  //     );
  //     if (pickedFile != null) {
  //       setState(() {
  //         _image = File(pickedFile.path);
  //         _uploadedImageUrl = null;
  //       });
  //       await _uploadImage();
  //     }
  //   } catch (e) {
  //     // _showSnackBar("Error picking image: $e", isError: true);
  //   }
  // }


  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
    });

    await _uploadImage(); // upload immediately
  }
  //========upload image===
  Future<void> _uploadImage() async {


    setState(() => _isUploading = true);

    try {
      final storage = TokenStorage();
      int? userId = await storage.readUserId();
      final token = await storage.readToken();

      if (userId == null || userId <= 0 || token == null || token.isEmpty) {
        _showSnackBar('Please login first', isError: true);
        setState(() => _isUploading = false);
        return;
      }

      final uri = Uri.parse("https://e-shop-1-m034.onrender.com/api/v1/user/$userId/image");
      final request = http.MultipartRequest("POST", uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      setState(() => _isUploading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody.body);
        if (data['data'] != null && data['data']['image'] != null) {
          setState(() {
            _uploadedImageUrl = data['data']['image'];
            // _image = null;
          });
          // _uploadedImageUrl = data['data']['image'];

          final storage = TokenStorage();
          await storage.writeUserImage(_uploadedImageUrl!);

        }
        // _showSnackBar("Upload successful");
      } else if (response.statusCode == 401) {
        _showSnackBar("Unauthorized: token invalid or expired", isError: true);
      } else {
        _showSnackBar("Upload failed: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      // _showSnackBar("Error: $e", isError: true);
    }
  }

// Decode userId from JWT token
  int extractUserIdFromToken(String token) {
    try {
      String cleanToken = token.replaceFirst('Bearer ', '');
      List<String> parts = cleanToken.split('.');
      if (parts.length == 3) {
        String payloadStr = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        Map<String, dynamic> payload = json.decode(payloadStr);
        print("Token payload: $payload");

        // Change this based on your backend payload
        if (payload['sub'] != null) {
          // if 'sub' is username string, backend might need numeric userId separately
          return 0; // cannot use string as userId
        } else if (payload['userId'] != null) {
          return int.tryParse(payload['userId'].toString()) ?? 0;
        } else if (payload['id'] != null) {
          return int.tryParse(payload['id'].toString()) ?? 0;
        } else if (payload['user_id'] != null) {
          return int.tryParse(payload['user_id'].toString()) ?? 0;
        }
      }
    } catch (e) {
      print("Error extracting userId from token: $e");
    }
    return 0;
  }

  void _removeImage() async{

    final confirm = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Remove',style: TextStyle(color: Colors.blue,fontSize: 20),),
            icon: Icon(CupertinoIcons.delete,size: 30,color: Colors.red,),
            contentTextStyle: TextStyle(
              color: Colors.blue,
              fontSize: 15,
            ),
            content: Text('Are you sure you  want to remove image? '),
            actions: [

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [

                    BoxShadow(
                      blurStyle: BlurStyle.outer,
                      blurRadius: 0.5,
                      color: Colors.blue,
                    ),
                  ],
                ),
                child: TextButton(
                onPressed:()=>Navigator.pop(context,false),
                          child: Text('Cancel',
                          style: TextStyle(
                          color: Colors.blue,
                          ),
                          ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [

                    BoxShadow(
                      blurStyle: BlurStyle.outer,
                      blurRadius: 0.5,
                      color: Colors.red,
                    ),
                  ],
                ),
                child: TextButton(
                    onPressed: ()=> Navigator.pop(context,true),
                    child: Text('Remove',style: TextStyle(color: Colors.red,),),
                ),
              ),
            ],
          );

        }
    );

    if(confirm != true) return;

    setState(() {
      _image = null;
      _uploadedImageUrl = null;
    });
    // _showSnackBar('Image removed');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  ImageProvider? _getImageProvider() {
    if (_image != null) return FileImage(_image!);
    if (_uploadedImageUrl != null) return NetworkImage(_uploadedImageUrl!);
    if (widget.currentImageUrl != null) return NetworkImage(widget.currentImageUrl!);
    return null;
  }


  // pick from gallery
  Future<void> _pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // take photo
  Future<void> _pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }


  // show dialog
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Profile'),
          actions: [
            IconButton(
              onPressed: (){
                _removeImage();
              },
             icon:  Icon(Icons.delete_outline,size: 30,color: Colors.red,),),
          ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // image profile for user
            Stack(
              children: [

                GestureDetector(

                  onTap:  _showImagePickerDialog,
                  child: Container(
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
                ),

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
                    child: IconButton(
                      onPressed: _isUploading ? null : () =>  _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt,size: 26,color: Colors.blue,),
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 10),

            //username
            Text(username ??
                widget.username, style:
            const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            ),
            SizedBox(height: 10,),

            //email
            Text(
              user?.email ?? 'user@gmail.com',
                style:
                const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            _buildUpdateusername(),
            SizedBox(height: 20,),

             _buildupdateFullname(),
             SizedBox(height: 20,),

             _buildUpdateEmail(),
            SizedBox(height: 20,),

            _buildUpdatePassword(),
            SizedBox(height: 20,),

            // _updateUser(),
        ],
        ),
      ),

      bottomNavigationBar: _buildSaveChangeButton(),
    );
  }

  //build image to up load
  Widget _buildProfileImage()  {

    if (_image != null) {
      return ClipOval(
        child: Image.file(
          _image!,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    }
    else if (_uploadedImageUrl != null) {

      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: "${_uploadedImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}",
          width: 140,
          height: 140,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 140,
            height: 140,
            color: Colors.blue,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.person, size: 70,),
        ),
      );
    } else {
      return const Icon(Icons.person, size: 70,color: Colors.grey,);
    }
  }
/*
      CircleAvatar(
    radius: 70,
    backgroundColor: Colors.grey.shade200,
    backgroundImage:
    _image != null ? FileImage(_image!) : null,
    child: _image == null
        ? Icon(Icons.camera_alt, size: 40)
        : null,
  );
*/


  // build_take photo and gallery
  Widget _buildloadImage() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [


      //Gallery
      GestureDetector(
        onTap: _isUploading ? null : () => _pickImage(ImageSource.gallery),
        child: Container(
          alignment: Alignment.center,
          width: 160,
          height:45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.shade50,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade400,
                blurStyle: BlurStyle.outer,
                blurRadius: 1,
              ),
            ],
          ),
          // child: ElevatedButton.icon(
          //   icon: const Icon(Icons.photo_library),
          //   label: const Text('Gallery'),
          // onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),

          // ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(Icons.photo_library_outlined,size: 25,color: Colors.blueAccent,),

              SizedBox(width: 5,),

              Text('Gallery',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),)
            ],
          ),

        ),
      ),
      Expanded(child:  SizedBox(width: 1)),

      //camera
      GestureDetector(
        onTap: _isUploading ? null : () => _pickImage(ImageSource.camera),
        child: Container(
          alignment: Alignment.center,
          width: 160,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.shade50,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade400,
                blurStyle: BlurStyle.outer,
                blurRadius: 1,
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined,size: 25,color: Colors.blueAccent,),
              SizedBox(width: 5,),
              Text('Take Photo',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  //build button upload image to storage
  Widget _builduploadiamge() => GestureDetector(
    onTap: _isUploading ? null : _uploadImage,
    child: Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue,
            blurStyle: BlurStyle.outer,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

            _isUploading
              ? SpinKitCircle(color: Colors.blueAccent,size: 30,)
              : Icon(Icons.cloud_upload_outlined,size: 30,color: Colors.blueAccent,),
            Text(
              _isUploading
                  ? 'Uploading...'
                  : 'Upload Image',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),


        ],
      ),
    ),
  );



  Widget _buildchangeImage() => GestureDetector(
    onTap: _showImagePickerDialog,
    child: Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade500,
            blurRadius: 1,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Text('Update Image',
      style: TextStyle(
        color: Colors.blueAccent,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      ),
    ),
  );

  //user name
Widget _buildUpdateusername() => Padding(
  padding: const EdgeInsets.all(8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [


      //text usename
      Text('User Name',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      ),
      SizedBox(height: 5,),

      Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Row(
          children: [

            SizedBox(width: 20,),

            //icon
            Icon(Icons.person_outline,
            size: 30,
            color: Colors.grey,
            ),

            SizedBox(width: 20,),

            Text(
              username ?? widget.username,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

//Email Address
  Widget _buildUpdateEmail() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        //text email
        Text('Email Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5,),

        //email user
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 1,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(),
              ),
              hintText: "${user?.email.isNotEmpty == true ? user!.email : 'No data'}",
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

          ),
        ),
      ],
    ),
  );

  //build password update
  Widget _buildUpdatePassword() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //text email
        Text('Pass word',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5,),

        //email user
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 1,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email_outlined,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(),

              ),
              // labelText: "${user?.password == true ? user!.password : 'No data'}",
              hintText: "Enter new password",
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

          ),
        ),
      ],
    ),
  );

//full name
  Widget _buildupdateFullname() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // text full name
        Text( 'Full Name',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5,),

        //update password
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 1,
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.personal_injury_sharp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(),

              ),
              hintText: (user?.fullName != null && user!.fullName!.isNotEmpty)
                  ? user!.fullName!
                  : 'No data',
              hintStyle: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

          ),
        ),
      ],
    ),
  );

  //build EvelationButton
 Widget _buildSaveChangeButton() => Padding(
   padding: const EdgeInsets.only(
     bottom: 15,
     left: 15,
     right: 15,
   ),
   child: SizedBox(
     width: double.infinity,
     height: 50,
     child: ElevatedButton(
       style: ElevatedButton.styleFrom(
         backgroundColor: Colors.blue.shade50,

       ),
       onPressed: () async {
         // save image
         if (!_isUploading) await _uploadImage();


         // save user info
         final storage = TokenStorage();
         int? userId = await storage.readUserId(); // get saved user ID

         final savedPassword = await storage.readPassword();


         print('UPDATE userId: $userId');
         print('UPDATE email: ${emailController.text}');
         print('UPDATE fullName: ${nameController.text}');
         print('UPDATE password: ${passwordController.text}');

         if (userId != null && userId > 0) {
           final password = passwordController.text.isNotEmpty
               ? passwordController.text
               : savedPassword ?? '';

           final userData = PutUserModel(
             email: emailController.text,
             fullName: nameController.text,
             phoneNumber: "",
             birthdate: "",
             password  : password,

           );
           print('PutUserModel: ${userData}');

           bool success = await controller.updateUser(userId, userData);
           print('UPDATE SUCCESS: $success');


           if (success) {
             if (passwordController.text.isNotEmpty) {
               await storage.writePassword(passwordController.text);
             }
             await fetchUser(); //  reload data when update

           } else {
             print('Failed to update user'); //

           }

         } else {
           _showSnackBar("Not login", isError: true);
         }
       },
         child: Text("Save Change",
         style: TextStyle(
           color: Colors.blueAccent,
           fontSize: 20,
           fontWeight: FontWeight.w800,
         ),
         ),
     ),
   ),
 );

}

