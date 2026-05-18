import 'package:flutter/material.dart';
import 'package:e_shop/data/models/order/order_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const PaymentSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
	final statusText = order.status.toString().split('.').last.toUpperCase();
	return Scaffold(
	  appBar: AppBar(title: const Text('Payment Success')),
	  body: Padding(
		padding: const EdgeInsets.all(16.0),
		child: Center(
		  child: Column(
		    crossAxisAlignment: CrossAxisAlignment.center,
		    children: [
		  	const SizedBox(height: 20),
		  	const Icon(Icons.check_circle, color: Colors.green, size: 80),
		  	const SizedBox(height: 20),
		  	Text('Order #${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
		  	const SizedBox(height: 8),
		  	Text('Status: $statusText', style: const TextStyle(fontSize: 16)),
		  	const SizedBox(height: 8),
		  	Text('Total: \$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
		  	const SizedBox(height: 20),
		  	ElevatedButton(
		  	  onPressed: () {
		  		// navigate to order detail or back
		  		Navigator.pop(context);
		  	  },
		  	  child: const Text('Back'),
		  	),
		    ],
		  ),
		),
	  ),
	);
  }
}



