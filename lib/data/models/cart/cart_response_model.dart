// import 'cart_model.dart';
//
// class CartResponse {
//   final String message;
//   final String code;
//   final CartData? data;
//
//   CartResponse({required this.message, required this.code, this.data});
//
//   factory CartResponse.fromJson(Map<String, dynamic> json) {
//     return CartResponse(
//       message: json['message'],
//       code: json['code'],
//       data: json['data'] != null ? CartData.fromJson(json['data']) : null,
//     );
//   }
// }