import 'dart:convert';
import 'package:e_shop/data/models/search%20/search_product_model.dart';
import 'package:http/http.dart' as http;

class SearchService {

final String uri = "https://e-shop-1-m034.onrender.com/api/v1/products/search?keyword=";

  Future<List<SearchProductModel>> searchProducts(String keyword) async{

    final url = Uri.parse(uri);
    final response = await http.get(url);
    try{
    if(response.statusCode == 200){
      final jsonData = jsonDecode(response.body);

      print('API BODY ${response.body}');
      print("API Rsponse ${response.statusCode}");

      List data = jsonData['data'];

      return data.map((e) => SearchProductModel.fromJson(e)).toList();
    }
    }catch(e){
      throw Exception("Field to load Products");
    }
    return [];

  }
}