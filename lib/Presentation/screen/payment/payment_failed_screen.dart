import 'package:flutter/material.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String reason;

  const PaymentFailedScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(title: const Text('Payment Failed')),
	  body: Padding(
		padding: const EdgeInsets.all(16.0),
		child: Center(
		  child: Column(
		    mainAxisAlignment: MainAxisAlignment.center,
		    children: [
		  	const Icon(Icons.error_outline, color: Colors.red, size: 80),
		  	const SizedBox(height: 16),
		  	const Text('Payment failed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
		  	const SizedBox(height: 8),
		  	Text(reason, style: const TextStyle(color: Colors.grey)),
		  	const SizedBox(height: 20),
		  	ElevatedButton(
		  	  onPressed: () => Navigator.pop(context),
		  	  child: const Text('Back'),
		  	),
		    ],
		  ),
		),
	  ),
	);
  }
}



