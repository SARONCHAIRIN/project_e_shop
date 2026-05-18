import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/repositories/payment_repository.dart';
import 'payment_success_screen.dart';
import 'payment_failed_screen.dart';

class BakongQrScreen extends StatefulWidget {
	final int orderId;
	final String bakongQrString;
	final String bakongMd5;
	final OrderRepository orderRepository;
	final PaymentRepository paymentRepository;

	const BakongQrScreen({
		super.key,
		required this.orderId,
		required this.bakongQrString,
		required this.bakongMd5,
		required this.orderRepository,
		required this.paymentRepository,
	});

	@override
	State<BakongQrScreen> createState() => _BakongQrScreenState();
}

class _BakongQrScreenState extends State<BakongQrScreen> {
	Uint8List? _qrImageBytes;
	Timer? _countdownTimer;
	Timer? _pollTimer;
	Duration _remaining = const Duration(minutes: 15);
	bool _loading = true;
	String? _error;

	@override
	void initState() {
		super.initState();
		debugPrint('[BakongQrScreen] bakongQrString empty: ${widget.bakongQrString.isEmpty}');
		debugPrint('[BakongQrScreen] bakongMd5 empty: ${widget.bakongMd5.isEmpty}');
		_prepareQr();
	}

	@override
	void dispose() {
		_countdownTimer?.cancel();
		_pollTimer?.cancel();
		super.dispose();
	}

	Future<void> _prepareQr() async {
		setState(() {
			_loading = true;
			_error = null;
		});

		if (widget.bakongQrString.isEmpty || widget.bakongMd5.isEmpty) {
			setState(() {
				_error = 'QR data is missing.';
				_loading = false;
			});
			return;
		}

		try {
			final storage = TokenStorage();
			final token = await storage.getToken();

			//  Returns Uint8List PNG bytes directly
			final bytes = await widget.paymentRepository.generateQRImage(
				qr: widget.bakongQrString,
				md5: widget.bakongMd5,
				token: token ?? '',
			);

			setState(() => _qrImageBytes = bytes);

			_startCountdown();
			_startPolling();
		} catch (e) {
			debugPrint('[BakongQrScreen] Error preparing QR: $e');
			setState(() => _error = e.toString());
		} finally {
			if (mounted) setState(() => _loading = false);
		}
	}

	void _startCountdown() {
		_countdownTimer?.cancel();
		_remaining = const Duration(minutes: 15);
		_countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
			if (!mounted) return;
			setState(() {
				if (_remaining.inSeconds <= 1) {
					timer.cancel();
				} else {
					_remaining = _remaining - const Duration(seconds: 1);
				}
			});
		});
	}

	void _startPolling() {
		_pollTimer?.cancel();
		_pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
			if (!mounted) return;
			try {
				final storage = TokenStorage();
				final token = await storage.getToken();

				final res = await widget.paymentRepository.checkTransaction(
					md5: widget.bakongMd5,
					token: token ?? '',
				);

				final status = (res['status'] ?? 'PENDING').toString();

				if (status.toUpperCase() == 'SUCCESS') {
					timer.cancel();
					_countdownTimer?.cancel();

					final transactionId =
					(res['transaction_id'] ?? res['transactionId'] ?? '').toString();

					await widget.paymentRepository.verifyPayment(
						orderId: widget.orderId,
						transactionId: transactionId,
						token: token ?? '',
					);

					final order = await widget.orderRepository.getOrderDetail(
						orderId: widget.orderId,
						token: token ?? '',
					);

					if (!mounted) return;

					Navigator.pushReplacement(
						context,
						MaterialPageRoute(
							builder: (_) => PaymentSuccessScreen(order: order),
						),
					);
				}
			} catch (e) {
				debugPrint('[BakongQrScreen] Polling error: $e');
			}
		});
	}

	Future<void> _cancelOrder() async {
		try {
			final storage = TokenStorage();
			final token = await storage.getToken();
			final userId = await storage.getUserId();
			if (userId == null || token == null) return;

			await widget.orderRepository.cancelOrder(
				orderId: widget.orderId,
				userId: userId,
				token: token,
			);

			if (!mounted) return;
			Navigator.pushReplacement(
				context,
				MaterialPageRoute(
					builder: (_) => PaymentFailedScreen(reason: 'Order cancelled'),
				),
			);
		} catch (e) {
			debugPrint('[BakongQrScreen] Cancel order error: $e');
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Failed to cancel order')),
				);
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		final minutes =
		_remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
		final seconds =
		_remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

		return Scaffold(
			appBar: AppBar(title: const Text('Bakong - Scan QR')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: _loading
						? const Center(child: SpinKitFadingCircle(color: Colors.blue))
						: _error != null
						? Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							const Icon(Icons.error_outline,
									color: Colors.red, size: 48),
							const SizedBox(height: 12),
							Text(
								'Error: $_error',
								textAlign: TextAlign.center,
								style: const TextStyle(color: Colors.red),
							),
							const SizedBox(height: 16),
							ElevatedButton(
								onPressed: _prepareQr,
								child: const Text('Retry'),
							),
						],
					),
				)
						: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						const SizedBox(height: 8),
						Text(
							'Scan this QR with your Bakong app',
							style: Theme.of(context).textTheme.titleMedium,
						),
						const SizedBox(height: 12),
						Card(
							elevation: 2,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(12),
							),
							child: Container(
								padding: const EdgeInsets.all(12),
								width: double.infinity,
								height: 320,
								child: Center(
									child: _qrImageBytes != null
											? Image.memory(
										_qrImageBytes!,
										fit: BoxFit.contain,
										errorBuilder: (_, __, ___) => const Text(
												'Failed to render QR image'),
									)
											: const Text('No QR available'),
								),
							),
						),
						const SizedBox(height: 16),
						Text(
							'Time remaining: $minutes:$seconds',
							style: const TextStyle(fontSize: 16),
						),
						const SizedBox(height: 12),
						const Text(
							'Waiting for payment...',
							style: TextStyle(color: Colors.grey),
						),
						const Spacer(),
						Row(
							children: [
								Expanded(
									child: OutlinedButton(
										onPressed: _cancelOrder,
										style: OutlinedButton.styleFrom(
											backgroundColor: Colors.red.shade50,
										),
										child: const Text(
											'Cancel Order',
											style: TextStyle(color: Colors.red),
										),
									),
								),
							],
						),
					],
				),
			),
		);
	}
}