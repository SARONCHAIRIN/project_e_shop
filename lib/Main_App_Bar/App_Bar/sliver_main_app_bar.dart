import 'package:e_shop/Presentation/screen/profile_main_page/sub_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/storage/token_storage.dart';
import '../Search_in_App_Bar/button_search_in_app_bar.dart';

class SliverMainAppBar extends StatefulWidget {
  final bool showBars;
  final authRepository;

  const SliverMainAppBar({
    super.key,
    required this.showBars,
    required this.authRepository,
  });

  @override
  State<SliverMainAppBar> createState() => _SliverMainAppBarState();
}

class _SliverMainAppBarState extends State<SliverMainAppBar> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final storage = TokenStorage();
    final name = await storage.readUsername();
    setState(() {
      username = name ?? "User";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(

      pinned: true,           // Won't stay at top
      floating: true,         // Won't reappear when scrolling up
      // snap: false,             // Won't snap into view
      // stretch: true,           // Optional: allows stretching when over-scrolling
      centerTitle: false,
      forceMaterialTransparency: true,
      backgroundColor: Colors.yellowAccent,
      elevation: 0,
      expandedHeight: 40,

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.blue,
        statusBarIconBrightness: Brightness.light,
      ),

      // // Title
      // title: Text(
      //   username != null && username!.isNotEmpty ? "Welcome $username" : " ",
      //   style: TextStyle(
      //     color: Colors.lightBlueAccent.shade700,
      //     fontWeight: FontWeight.bold,
      //     fontSize: 25,
      //   ),
      // ),
      //
      // // Actions
      // actions: [
      //   Padding(
      //     padding:  EdgeInsets.only(right: 10),
      //     child:IconButton(
      //       onPressed: (){
      //     },
      //         icon: Icon(Icons.notifications_active_outlined,size: 25,color: Colors.blue,),
      //     ),
      //   ),
      //   Padding(
      //     padding: const EdgeInsets.only(right: 1),
      //     // child:
      //     // IconButton(
      //     //   onPressed: (){
      //     //   // Navigator.push(context, MaterialPageRoute(builder: (_) => SplashScreen(authRepository: widget.authRepository)));
      //     // },
      //     //     icon: Icon(Icons.logout,size: 30,color: Colors.blue,),
      //     // ),
      //   ),
      // ],

      // Bottom widget
      bottom: ButtonInAppBar(showBars: widget.showBars),
    );
  }
}