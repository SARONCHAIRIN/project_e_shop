import 'package:e_shop/data/models/order/order_model.dart';
import 'package:e_shop/data/repositories/order/order_repository.dart';
import 'package:flutter/material.dart';

class OrderController extends ChangeNotifier{
  final OrderRepository repository;

  OrderController({
    required this.repository,
});

  List<OrderModel> orders = [];
  bool isLoading = false;

  Future<void> fetchOrders(
      int userId,
      String token,
      ) async {
     try{
       isLoading = true;
       notifyListeners();

      orders = await repository.fetchOrder(userId, token);
       print("ORDERS FROM API: ${orders.length}");

      isLoading = false;
      notifyListeners();

    }catch(e){
      print('Error fetching orders: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  //checkout
  Future<bool> checkout(
      int userId,
      String token,
      int address_id,
      String payment_method,
      ) async{
    try{
      return await repository.checkOut(userId, token, address_id, payment_method);

    }catch(e){
      print('Error during checkout: $e');
      return false;
    }
  }

  //cancel order
  Future<void> cancelOrder(
  int userId,
  String token,
  int orderId,
      )async{
    try{

      await repository.cancelOrder(userId, token, orderId);
      // After cancelling, refresh the orders list
      await fetchOrders(userId, token);

    }catch(e){
      print('Error cancelling order: $e');
    }
  }

}

