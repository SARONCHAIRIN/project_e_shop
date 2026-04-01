import 'package:e_shop/Presentation/screen/search/product_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;
class ButtonInAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showBars;

   ButtonInAppBar({
    super.key,
    required this.showBars,
  });

  @override
  Size get preferredSize => const Size.fromHeight(45);


 /* TextEditingController searchController = TextEditingController();
  List<SearchProductModel> products  = [];
  void searchProduct() async{
    final service = SearchService();
    final result = await service.searchProducts(searchController.text);
    setState(() {
      products = result;
    });


  }*/

  Widget build(BuildContext context) {
    // final searchController = Provider.of<SearchController>(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 5
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        // height: showBars ? 35:  0,
        height: 40,
        padding: const EdgeInsets.only(
        ),
        child: showBars
            ? Center(
          child: TextField(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchProductpage()));
            },

            cursorColor: Colors.grey,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search product',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.search,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            // onChanged: (value) => searchController.search(value),
          ),
        )
            : const SizedBox(),
      ),
    );
  }
}
