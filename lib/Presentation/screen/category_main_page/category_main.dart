import 'package:e_shop/Presentation/screen/sub_category_screen/subcategory_with_product.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/rendering.dart';
import '../../../Main_App_Bar/App_Bar/sliver_main_app_bar.dart';
import '../../../core/network/api_client.dart';

class CategoryMain extends StatefulWidget {
  final authRepository;
  const CategoryMain({
    super.key,
    required this.authRepository,

  });

  @override
  State<CategoryMain> createState() => _CategoryMainState();
}

class _CategoryMainState extends State<CategoryMain> {
  final ScrollController _scrollController = ScrollController();
  bool showBars = true;
  bool showTextField = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (showBars) setState(() => showBars = false);
        // if(showTextField ) setState(() => showTextField = false);
      }
      else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!showBars) setState(() => showBars = true);
        // if(!showTextField) setState(() => showTextField = true);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Your app bar - will scroll away
          SliverMainAppBar(
            showBars: showBars,
            authRepository: widget.authRepository,
          ),

          // Your other slivers...
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Your grid
          const SubcategoryWithProduct(),
        ],
      ),
    );
  }
}
