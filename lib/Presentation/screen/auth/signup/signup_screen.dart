import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../data/repositories/user_auth_repository.dart';

class SignupScreen extends StatefulWidget {
  final User_AuthRepository authRepository;
  static const routeNameRegister = '/register';

  const SignupScreen({super.key, required this.authRepository});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool _loading = false;
  String? _error;


  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      //  Register user (no token returned from API)
      await widget.authRepository.register(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullnameController.text.trim(),
      );

      print("REGISTER SUCCESS for ${usernameController.text}");
      print('Email : ${emailController.text}');

      //  Login immediately to get token
      final user = await widget.authRepository.login(
        usernameController.text.trim(),
        passwordController.text,
      );

     final storage = await widget.authRepository.storage;

      if (user.email.isNotEmpty) {
        await storage.saveUserEmail(user.email);
        print('Email saved: ${user.email}');
      }

      print("LOGIN SUCCESS TOKEN: ${user.token}");

      //  Navigate to main app screen (home)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => DivicesNav(authRepository: widget.authRepository),
        ),
            (route) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString());
      print("REGISTER/LOGIN ERROR: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [


          Positioned.fill(
            child: Image.asset(
              "assets/images/back_image.png",
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
              ),
              child: Container(
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      spacing: 2,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.security_outlined,
                            size: 60, color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create Your Account',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height:10),

                        Form(
                          key: _formKey,
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              // Username
                              TextFormField(
                                controller: usernameController,
                                validator: Validator.username,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 13),
                                ),

                              ),
                              const SizedBox(height: 16),

                              // Email
                              TextFormField(
                                controller: emailController,
                                validator: Validator.email,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 13),
                                ),

                              ),
                              const SizedBox(height: 16),
                              // Full Name
                              TextFormField(
                                controller: fullnameController,
                                validator: Validator.fullName,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 13),
                                ),

                              ),
                              const SizedBox(height: 16),
                              // Password
                              TextFormField(
                                controller: passwordController,
                                validator: Validator.password,
                                obscureText: obscurePassword,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: obscurePassword
                                          ? Colors.lightBlueAccent
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() =>
                                      obscurePassword = !obscurePassword);
                                    },
                                  ),
                                ),

                              ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
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
                                    onPressed: _loading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18)),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: _loading
                                        ? const SpinKitDualRing(
                                        color: Colors.white, size: 25)
                                        : const Text(
                                      'Register',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              // Or with
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('-------',style: TextStyle(color: Colors.white,fontSize: 20,
                                      fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),
                                  Text('or with ',style: TextStyle(color: Colors.white,fontStyle:FontStyle.italic,fontSize: 18,),),
                                  Text('-------',style: TextStyle(color: Colors.white,fontSize: 20,
                                      fontWeight: FontWeight.bold),),
                                ],
                              ),
                              SizedBox(height: 5,),

                              //login with facebook
                              GestureDetector(
                                onTap: (){


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
                                        Text('Login With FaceBook',style: TextStyle(
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
                                onTap: (){

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
                                        Text('Login With Google',style: TextStyle(
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
                                onPressed: (){
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                    LoginScreen.routeName,
                                      (route) => false,
                                  );
                                },
                                child: const Text(
                                  "Already have an account? Log in",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
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