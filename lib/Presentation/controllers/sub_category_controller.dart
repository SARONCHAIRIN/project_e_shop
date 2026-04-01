import 'package:flutter/material.dart';

import '../../domains/entities/sub_category.dart';
import '../../domains/usecases/get_all_sub_category.dart';

class SubCategoryController extends ChangeNotifier {

  final GetAllSubCategory getAllSubCategory;

  SubCategoryController(this.getAllSubCategory);

  List<SubCategory> subCategories = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchSubCategories() async {
    try {
      isLoading = true;
      notifyListeners();

      subCategories = await getAllSubCategory();

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}