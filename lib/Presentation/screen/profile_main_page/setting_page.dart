import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/profile_image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';

class SettingPage extends StatefulWidget {
  final  authRepository;
  const SettingPage({
    super.key,
    required this.authRepository,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool ison_notification = false;
  bool ison_email = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text('Setting',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,

        ),),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Divider(
              color: Colors.grey,
              thickness: 0.1,
              height: 1,
            ),
            SizedBox(height: 40,),

            //account
            _buildAccount(),
            SizedBox(height: 40,),

            //notification
            _buildnotification(),
            SizedBox(height: 40,),

            //preferences
            _buildpreferences(),
            SizedBox(height: 40,),

            //Legal
            _buildLegal(),
            SizedBox(height: 40,),

            //button logout
            _buildButtonlogout(),
            SizedBox(height: 30,),




          ],
        ),
      ),
    );
  }

  //account
  Widget _buildAccount() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      //account
      Padding(
        padding: EdgeInsets.only(
          left: 20,
      ),
      child: Text('ACCOUNT',
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w500,

      ),
      ),
      ),

      SizedBox(height: 10,),
      Divider(
        height: 0.5,
        thickness: 0.5,
        color: Colors.grey.shade300,
      ),

      //type of setting
      Padding(
        padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        spacing: 15,
        children: [

          //row of edit profile
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
                child: Icon(Icons.person_outline,size: 25,color: Colors.indigoAccent,),
              ),

              SizedBox(width: 30,),

              Expanded(
                child: Text('Edit profile',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,

                  ),
                ),
              ),

              IconButton(
                onPressed: () async{
                  try {
                    final tokenStorage = TokenStorage();
                    final token = await tokenStorage.getToken();
                    final userId = await tokenStorage.getUserId();
                    final username = await tokenStorage.getUsername();
                    final email = await tokenStorage.readUserEmail();

                    if (token != null && username != null && email != null) {
                     await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                // userId: userId ?? 0,
                                username: username,
                                token: token,
                                email: email,

                              )
                          )
                      );

                    }
                  } catch (e) {
                    print("Error: $e");
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey,
                ),

              ),
            ],
          ),

          //row of Shipping address
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
                child: Text('Shipping Address',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                    fontSize: 18,
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
  );



  //Notification
Widget _buildnotification() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    //notification
    Padding(
      padding: EdgeInsets.only(
        left: 20,
      ),
      child: Text('NOTIFICATION',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,

        ),
      ),
    ),
    SizedBox(height: 10,),
    Divider(
      height: 0.5,
      thickness: 0.5,
      color: Colors.grey.shade300,
    ),

    //type of notification
    Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        spacing: 15,
        children: [

          //row of push notification
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
                child: Icon(Icons.notifications_active_outlined,size: 25,color: Colors.indigoAccent,),
              ),

              SizedBox(width: 30,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //title
                  Text('Push Notifications',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                  SizedBox(height: 1,),

                  //sub title
                  Text('Order update and offers',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ],
              ),
              Expanded(child: SizedBox(width: 1,)),


              CupertinoSwitch(
                  value: ison_notification,
                  onChanged: (bool value){
                    setState(() {
                       ison_notification = value;
                    });
                  }
              ),
            ],
          ),

          //row of email alerts
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
                child: Icon(Icons.email_outlined,size: 25,color: Colors.indigoAccent,),
              ),

              SizedBox(width: 30,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('Email Alerts',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,

                    ),
                  ),

                  Text('Newsletter and daily deals',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ],
              ),
              Expanded(child: SizedBox(width: 1,)),

              CupertinoSwitch(
                  value: ison_email,
                  onChanged: (bool value){
                    setState(() {
                      ison_email = value;
                    });
                  }
              ),
            ],
          ),
         ],
      ),
    ),


  ],
);


  //preferences
  Widget _buildpreferences() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      //notification
      Padding(
        padding: EdgeInsets.only(
          left: 20,
        ),
        child: Text('PREFERENCES',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,

          ),
        ),
      ),
      SizedBox(height: 10,),
      Divider(
        height: 0.5,
        thickness: 0.5,
        color: Colors.grey.shade300,
      ),

      //type of notification
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          spacing: 15,
          children: [

            //row of language
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
                  child: Icon(Icons.language,size: 25,color: Colors.indigoAccent,),
                ),

                SizedBox(width: 30,),

                Column(
                  children: [

                    //title
                    Text('Language',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                    SizedBox(height: 1,),

                    //sub title
                    Text('English (US)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox(width: 1,)),


                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.grey,),
                ),
              ],
            ),

            //row of Currency
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
                  child: Icon(Icons.currency_exchange_outlined,size: 25,color: Colors.indigoAccent,),
                ),

                SizedBox(width: 30,),

                Column(
                  children: [

                    Text('Currency',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                    Text('USD (\$)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,

                      ),
                    ),

                  ],
                ),
                Expanded(child: SizedBox(width: 1,)),

                IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.grey,),
                ),



              ],
            ),
          ],
        ),
      ),


    ],
  );

  //preferences
  Widget _buildLegal() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      //notification
      Padding(
        padding: EdgeInsets.only(
          left: 20,
        ),
        child: Text('LEGAL',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,

          ),
        ),
      ),
      SizedBox(height: 10,),
      Divider(
        height: 0.5,
        thickness: 0.5,
        color: Colors.grey.shade300,
      ),

      //type of notification
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          spacing: 15,
          children: [

            //row of language
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
                  child: Icon(Icons.privacy_tip_outlined,size: 25,color: Colors.indigoAccent,),
                ),

                SizedBox(width: 30,),

                //title
                Expanded(
                  child: Text('Privacy Policy',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ),

                IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.grey,),
                ),
              ],
            ),
            //row of Currency
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
                  child: Icon(Icons.text_snippet_outlined,size: 25,color: Colors.indigoAccent,),
                ),

                SizedBox(width: 30,),

                    Expanded(
                      child: Text('Terms of Service',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,

                        ),
                      ),
                    ),

                IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.grey,),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );


  //logout
Widget _buildButtonlogout() => Padding(
    padding: EdgeInsets.symmetric(
     horizontal: 15,
    ),
  child: ElevatedButton(
      onPressed: () async{

        final confirm = await showDialog(
            context: context,
            builder: (context){
              return AlertDialog(

                title: Text('Logout Account',
                  style:TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                content: Text('Are you sure you want to logout account?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
                ),
                icon: Icon(
                  Icons.phonelink_lock_outlined,
                  size: 60,
                  color: Colors.redAccent,
                ),

                actions: [

                  TextButton(onPressed: () => Navigator.pop(context, false),
                      child: Container(
                        alignment: Alignment.center,
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent,
                              blurRadius: 1,
                              blurStyle: BlurStyle.outer,
                            ),
                          ],
                        ),
                          child: Text('Cancel',style: TextStyle(color: Colors.blue,),)),
                  ),

                  TextButton(onPressed: () => Navigator.pop(context , true),
                      child: Container(
                        alignment: Alignment.center,
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Text('logout',
                        style: TextStyle(
                          color: Colors.redAccent,
                        ),),
                      ),
                  ),
                ],

              );
            },
        );

        if(confirm != true) return;

        await widget.authRepository.logout();

        if(!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => DivicesNav(authRepository: widget.authRepository),),
            (route) => false,
        );


      },
    style: ButtonStyle(

    ),
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurStyle: BlurStyle.outer,
              blurRadius: 1,

            ),
          ],
        ),
        child: Text('Logout',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,

        ),
        ),
      ),
  ),
);
}
