import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/utils/validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_auth_repository.dart';
import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final User_AuthRepository authRepository;
  static const routeName = '/login';

  const LoginScreen({
    super.key,
    required this.authRepository,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool obscurePassword = true;
  bool _loading = false;
  String? _error;
  String? _message;
  String? user;

  final _formkey = GlobalKey<FormState>();

  Future<UserModel> _login() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      // Call login API
      final user = await widget.authRepository.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      final storage = widget.authRepository.storage;

      print('====RAW LOGIN RESPONSE====');
      print('UserModel: $user');
      print('id: ${user.id},'
          ' username: ${user.username}, '
          'email: ${user.email}, '
          'token: ${user.token}',
      );
      print('==========================');

      // -------------------
      // Save token
      // -------------------
      if (user.token.isNotEmpty) {
        await storage.writeToken(user.token);
        final tokenRead = await storage.readToken();
        print('Token saved & read back: $tokenRead');
      } else {
        print('Token is empty, not saving.');
      }

      // -------------------
      // Save username
      // -------------------
      if (user.username.isNotEmpty) {
        await storage.writeUsername(user.username);
        final usernameRead = await storage.readUsername();
        print('Username saved & read back: $usernameRead');
      } else {
        print('Username is empty, not saving.');
      }

      // -------------------
      // Save email (with check & fallback)
      // -------------------
      String emailToSave = '';
      if (user.email.isNotEmpty) {
        emailToSave = user.email;
      } else {
        // fallback to username if email is empty
        emailToSave = user.username;
        print('Email empty, fallback to username: $emailToSave');
      }

      await storage.saveUserEmail(emailToSave);
      final emailRead = await storage.readUserEmail();
      print('Email saved & read back: $emailRead');

      // -------------------
      // Save userId
      // -------------------
      await storage.saveUserId(user.id);
      final userIdRead = await storage.readUserId();
      print('UserId saved & read back: $userIdRead');

      print('====LOGIN SUCCESS====');
      print('UserId: ${user.id}');
      print('Username: ${user.username}');
      print('Email: $emailRead');
      print('Token: ${user.token}');
      print('=====================');

      // -------------------
      // Save fullName
      // -------------------
      if (user.fullName != null && user.fullName!.isNotEmpty) {
        await storage.saveFullName(user.fullName!);
        final fullNameRead = await storage.readFullName();
        print('FullName saved & read back: $fullNameRead');
      } else {
        print('FullName is empty or null, not saving.');
      }

      setState(() => _message = "Login successful!");

      // Navigate to main screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DivicesNav(authRepository: widget.authRepository),
        ),
            (route) => false,
      );

      return user;
    } catch (e) {
      setState(() => _error = "Invalid username or password");
      print("LOGIN ERROR: $e");
      rethrow;
    } finally {
      setState(() => _loading = false);
    }
  }

  // eck stored data
  Future<void> checkStoredData() async {
    final allData = await widget.authRepository.storage.getAllUserInfo();
    print("========== AFTER LOGIN ==========");
    print("Token: ${allData['token']}");
    print("Username: ${allData['username']}");
    print("Email: ${allData['email']}");
    print("UserId: ${allData['userId']}");
    print("UserId Type: ${allData['userId']?.runtimeType}");
    print("==================================");
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(

        body: Stack(
          children: [

            //image background
            Positioned.fill(
              child: Image.asset(
                // "assets/images/background_form_login.png",
                "assets/images/back_image.png",
                fit: BoxFit.cover,

              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 60,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 10,
                        blurStyle: BlurStyle.outer,

                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.transparent.withOpacity(0.1),

                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(

                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [

                          SizedBox(height: 5,),

                          const Icon(Icons.security_outlined, size: 60,
                              color: Colors.white),
                          const SizedBox(height: 2),
                          const Text(
                            'Log In to your Account',
                            style: TextStyle(fontSize: 27,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),

                          const SizedBox(height: 10),

                          Form(
                            key: _formkey,
                            autovalidateMode: AutovalidateMode
                                .onUserInteraction,
                            child: Column(
                              children: [

                                //text field with username
                                TextFormField(
                                  controller: usernameController,
                                  validator: Validator.username,
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),

                                  decoration: InputDecoration(

                                    fillColor: Colors.white.withOpacity(0.2),
                                    // hintText: 'Username',
                                    labelText: 'Username',
                                    labelStyle: TextStyle(color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                    hintStyle: TextStyle(
                                        color: Colors.white60, fontSize: 18),

                                    border: OutlineInputBorder(

                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          style: BorderStyle.solid,
                                          width: 1),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 13),
                                  ),

                                ),
                                const SizedBox(height: 16),
                                //test field with password
                                TextFormField(

                                  controller: passwordController,
                                  validator: Validator.password,
                                  obscureText: obscurePassword,
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    // hintText: 'Password',
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500),
                                    hintStyle: TextStyle(
                                        color: Colors.white, fontSize: 18),

                                    fillColor: Colors.white.withOpacity(0.2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: obscurePassword ? Colors
                                            .lightBlueAccent : Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() =>
                                        obscurePassword = !obscurePassword);
                                      },
                                    ),
                                  ),


                                ),


                                // Show error message if login fails
                                if (_error != null)
                                  Text(_error!, style: const TextStyle(
                                      color: Colors.red)),

                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.white,
                                            blurRadius: 5,
                                            blurStyle: BlurStyle.outer
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      //check condition if loading is true disable the button
                                      onPressed: _loading ?
                                      null :
                                          () {
                                        if (_formkey.currentState!.validate()) {
                                          _login();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                18)),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: _loading
                                          ? const SpinKitDualRing(
                                        color: Colors.white, size: 25,)
                                          : const Text('Log In',
                                          style: TextStyle(fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),


                          const SizedBox(height: 8),
                          //forget password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(

                                    checkColor: Colors.white,
                                    hoverColor: Colors.white,
                                    activeColor: Colors.black,
                                    fillColor: MaterialStateProperty.all(
                                        Colors.lightBlueAccent.shade400),

                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() => rememberMe = value!);
                                    },
                                  ),
                                  const Text('Remembers me',
                                      style: TextStyle(color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),

                              TextButton(
                                onPressed: () {

                                },
                                child: const Text('Forgot Password?',
                                    style: TextStyle(
                                        color: Colors.redAccent, fontSize: 10
                                        , fontWeight: FontWeight.bold)
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1,),


                          // Or with
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('-------', style: TextStyle(
                                  color: Colors.white, fontSize: 20,
                                  fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,),
                              Text('or with ', style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 18,),),
                              Text('-------', style: TextStyle(
                                  color: Colors.white, fontSize: 20,
                                  fontWeight: FontWeight.bold),),
                            ],
                          ),
                          SizedBox(height: 5,),

                          //login with facebook
                          GestureDetector(
                            onTap: () {

                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 10,),
                                    Image.asset(
                                      'assets/images/logo_facebook.png',
                                      fit: BoxFit.fill,
                                      width: 40,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      'Login With FaceBook', style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,

                                    ),),
                                    Expanded(child: SizedBox(width: 1,)),
                                  ],

                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),

                          //login with google
                          GestureDetector(
                            onTap: () {

                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 10,),
                                    Image.asset(
                                      'assets/images/logo_google.png',
                                      fit: BoxFit.fill,
                                      width: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text('Login With Google', style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,

                                    ),),
                                    Expanded(child: SizedBox(width: 1,)),
                                  ],

                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2,),

                          // singin
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        SignupScreen(
                                            authRepository: widget
                                                .authRepository)),
                              );
                            },
                            child: const Text("Don't have an account? Sign Up",
                              style: TextStyle(color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
