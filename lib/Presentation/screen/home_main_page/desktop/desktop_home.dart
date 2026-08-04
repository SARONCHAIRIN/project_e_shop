import 'package:flutter/material.dart';

import '../home_view_args.dart';

import 'desktop_home_body.dart';



class DesktopHome extends StatelessWidget {


  final HomeViewArgs args;



  const DesktopHome({

    super.key,

    required this.args,

  });



  @override
  Widget build(BuildContext context){


    return Scaffold(

      body:

      DesktopHomeBody(

        args:args,

      ),

    );


  }


}