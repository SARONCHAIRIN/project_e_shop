import '../../datasources/returnProduct/return_product_service.dart';

class ReturnRepository {
  final ReturnService service;

  ReturnRepository(this.service);

  Future<Map<String, dynamic>> requestReturn({
    required Map<String, dynamic> data,

    required String token,
  }) async {
    final response = await service.requestReturn(data: data, token: token);

    return response;
  }
}
