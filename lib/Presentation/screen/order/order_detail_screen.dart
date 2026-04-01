import 'package:flutter/material.dart';
import '../../../data/models/order/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Detail")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order #: ${order.orderNumber}"),
            // Text("Total: \$${order.totalPrice}"),
            // Text("Status: ${order.status}"),
          ],
        ),
      ),
    );
  }
}