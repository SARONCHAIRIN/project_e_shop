import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../controllers/order/order_controller.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  final int userId;
  final String token;

  const OrderScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<OrderController>().fetchOrders(
        widget.userId,
        widget.token,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrderController>();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Orders"),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchOrders(widget.userId, widget.token);
        },
        child: controller.isLoading
            ? Center(child: SpinKitCircle(color: Colors.blue))
            : controller.orders.isEmpty
            ? Center(child: Text("No orders found. Pull down to refresh."))
            : ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text("Order: ${order.orderNumber}"),
                subtitle: Text("Total: \$${order.totalAmount}"),
                trailing: Text(order.status),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OrderDetailScreen(order: order),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}