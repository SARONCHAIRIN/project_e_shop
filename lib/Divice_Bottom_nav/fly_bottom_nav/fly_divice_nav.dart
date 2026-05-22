import 'package:e_shop/Presentation/screen/Message_main_page/message_main.dart';
import 'package:e_shop/Presentation/screen/cart_main_page/cart_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'curved_navigation_bar.dart';

class FlyDiviceNav extends StatefulWidget {
  const FlyDiviceNav({super.key});

  @override
  State<FlyDiviceNav> createState() => _DivicePageState();
}

class _DivicePageState extends State<FlyDiviceNav> {
  int index = 0;

  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showBars) setState(() => showBars = false);
        // if(showTextField ) setState(() => showTextField = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showBars) setState(() => showBars = true);
        // if(!showTextField) setState(() => showTextField = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // List of pages
  final pages = [
    MessageMain(),
    // CartMain(),

    // ProfileMain(),
  ];

  @override
  Widget build(BuildContext context) {

    final items = const [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 25, color: Colors.blueAccent),

          SizedBox(height: 3),
          Text(
            "Home",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, color: Colors.blueAccent, size: 25),
          SizedBox(height: 3),
          Text(
            "Categry",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, color: Colors.blueAccent, size: 25),
          SizedBox(height: 3),
          Text(
            "Message",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Colors.blueAccent,
            size: 25,
          ),
          SizedBox(height: 3),
          Text(
            " Cart ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, color: Colors.blueAccent, size: 25),
          SizedBox(height: 3),
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,

      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              forceMaterialTransparency: true,
              surfaceTintColor: Colors.transparent,
              expandedHeight: showBars ? 160 : 70,
              toolbarHeight: showBars ? 60 : 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),

              // forceMaterialTransparency: true,
              leading: Icon(Icons.person, size: 25, color: Colors.blue),
              title: Center(
                child: Text(
                  "E-SHOP",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
              ),

              actions: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 10),
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 10),
              ],

              bottom: PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: AnimatedSize(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: showBars ? 80 : 0,
                    padding: const EdgeInsets.all(8),
                    child: Opacity(
                      opacity: showBars ? 1 : 0,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Search",
                          labelStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.blue,
                          ),
                          fillColor: Colors.blue.shade50,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.transparent,
          child: IndexedStack(index: index, children: pages),
        ),
      ),

      bottomNavigationBar: AnimatedSlide(
        duration: Duration(milliseconds: 250),
        offset: showBars ? Offset(0, 0) : Offset(0, 1),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 250),

          opacity: showBars ? 1 : 0,
          child: Container(
            decoration: const BoxDecoration(
              // color: Colors.,
            ),
            child: CurvedNavigationBar(
              index: index,
              backgroundColor: Colors.white,
              color: Colors.deepOrange.shade50,

              items: items,
              onTap: (selectedIndex) {
                setState(() => index = selectedIndex);
              },
            ),
          ),
        ),
      ),
    );
  }
}
