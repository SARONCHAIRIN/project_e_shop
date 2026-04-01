import 'package:flutter/material.dart';

import '../../data/datasources/product_service_eshop.dart' show ProductService;
import '../../data/models/product_model_eshop.dart';

class SearchController extends ChangeNotifier {
  final ProductService service;

  SearchController(this.service);

  List<Product> results = [];
  bool isLoading = false;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      results = await service.searchProducts(query);
    } catch (e) {
      results = [];
      debugPrint('Search error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}