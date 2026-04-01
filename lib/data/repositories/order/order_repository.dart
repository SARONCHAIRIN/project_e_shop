import 'package:e_shop/data/models/order/order_model.dart';
import '../../datasources/order/order_service.dart';

class OrderRepository {

  final OrderService service;

  OrderRepository({
    required this.service,
});

Future<List<OrderModel>> fetchOrder(
    int userId,
    String token
    )async{
     final data = await service.fetchOrders(userId, token);
     print("data from service: $data");

     return data.map<OrderModel>((json)  {
       return OrderModel.fromJson(json);
     }).toList();
}

//checkout
Future<bool> checkOut (
    int userId,
    String token,
    int address_id,
    String payment_method,
    )async{
   return service.checkout(userId, token, address_id, payment_method);
}

//cancel order
Future<bool> cancelOrder(
    int userId,
    String token,
    int orderId,
    )async{
  final result = await service.cancelOrder(orderId, userId, token);
  return result;
}
}