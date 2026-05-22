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
      pinned: true,
      floating: true,
      centerTitle: false,
      forceMaterialTransparency: true,
      backgroundColor: Colors.yellowAccent,
      elevation: 0,
      expandedHeight: 40,

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.blue,
        statusBarIconBrightness: Brightness.light,
      ),

      bottom: ButtonInAppBar(showBars: widget.showBars,repository: widget.authRepository,),
    );
  }
}
