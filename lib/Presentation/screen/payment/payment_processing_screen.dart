import 'package:e_shop/Presentation/screen/order/orderSuccessScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/repositories/payment_repository.dart';
import 'bakong_qr_screen.dart';
import 'payment_failed_screen.dart';

/// Screen that handles creating orders for COD and Bakong and directs to the
/// appropriate follow-up screen.
class PaymentProcessingScreen extends StatefulWidget {
  final int addressId;
  final double totalPrice;
  final String paymentMethod; // 'COD' or 'BAKONG'
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  const PaymentProcessingScreen({
	super.key,
	required this.addressId,
	required this.totalPrice,
	required this.paymentMethod,
	required this.orderRepository,
	required this.paymentRepository,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _start() async {
	setState(() {
	  _isLoading = true;
	  _error = null;
	});

	try {
	  final storage = TokenStorage();
	  final userId = await storage.getUserId();
	  final token = await storage.getToken();

	  if (userId == null || token == null) {
		throw Exception('User not authenticated');
	  }

	  if (widget.paymentMethod.toUpperCase() == 'COD') {
		final order = await widget.orderRepository.createCODOrder(
		  userId: userId,
		  addressId: widget.addressId,
		  token: token,
		);

		if (!mounted) return;
		Navigator.pushReplacement(
		  context,
		  // MaterialPageRoute(builder: (_) => PaymentSuccessScreen(order: order)),
		  MaterialPageRoute(builder: (_) => OrderSuccessScreen(paymentMethod: widget.paymentMethod, orderId: order.id )),
		);

	  } else if (widget.paymentMethod.toUpperCase() == 'BAKONG') {
		// create bakong order then initiate bakong to get qr & md5
		final order = await widget.orderRepository.createBakongOrder(
		  userId: userId,
		  addressId: widget.addressId,
		  token: token,
		);

		if (!mounted) return;

		// initiate bakong via payment repository to get qr string and md5
		final bakong = await widget.paymentRepository.initiateBakongPayment(
		  orderId: order.id,
		  token: token,
		);

		Navigator.pushReplacement(
		  context,
		  MaterialPageRoute(
			builder: (_) => BakongQrScreen(
			  orderId: order.id,
			  bakongQrString: bakong.qrString ?? '',
			  bakongMd5: bakong.md5 ?? '',
			  orderRepository: widget.orderRepository,
			  paymentRepository: widget.paymentRepository,
			),
		  ),
		);

	  } else {
		throw Exception('Unsupported payment method: ${widget.paymentMethod}');
	  }
	} catch (e) {
	  debugPrint('PaymentProcessing error: $e');
	  setState(() => _error = e.toString());
	  if (!mounted) return;
	  Navigator.pushReplacement(
		context,
		MaterialPageRoute(builder: (_) => PaymentFailedScreen(reason: _error ?? 'Unknown error')),
	  );
	} finally {
	  if (mounted) setState(() => _isLoading = false);
	}
  }

  @override
  void initState() {
	super.initState();
	// start on next frame to let build show initial UI
	WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(title: const Text('Processing Payment')),
	  body: Center(
		child: _isLoading
			? Column(
				mainAxisSize: MainAxisSize.min,
				children: const [
				  SpinKitCircle(color: Colors.blue, size: 48),
				  SizedBox(height: 12),
				  Text('Processing your order...'),
				],
			  )
			: _error != null
				? Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
					  mainAxisSize: MainAxisSize.min,
					  children: [
						Text('Error: $_error', style: const TextStyle(color: Colors.red)),
						const SizedBox(height: 12),
						ElevatedButton(
						  onPressed: _start,
						  child: const Text('Retry'),
						),
					  ],
					),
				  )
				: const SizedBox.shrink(),
	  ),
	);
  }
}




