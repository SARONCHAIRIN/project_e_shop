import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/returnProduct/return_product_service.dart';
import '../data/repositories/returnProduct/return_product_repo.dart';
import 'category_icon_provider.dart';


final returnServiceProvider = Provider<ReturnService>((ref) {

  final dio = ref.read(dioProvider);

  return ReturnService(dio);

});


final returnRepositoryProvider = Provider<ReturnRepository>((ref) {

  final service = ref.read(returnServiceProvider);

  return ReturnRepository(service);

});