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

class _BakongQrScreenState extends State<BakongQrScreen>
		with SingleTickerProviderStateMixin {
	Uint8List? _qrImageBytes;
	Timer? _countdownTimer;
	Timer? _pollTimer;
	Duration _remaining = const Duration(minutes: 15);
	bool _loading = true;
	String? _error;
	bool _cancelling = false;

	late AnimationController _pulseController;
	late Animation<double> _pulseAnimation;

	// Total session seconds for progress indicator
	static const int _totalSeconds = 15 * 60;

	@override
	void initState() {
		super.initState();
		_pulseController = AnimationController(
			vsync: this,
			duration: const Duration(seconds: 2),
		)..repeat(reverse: true);

		_pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
			CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
		);

		_prepareQr();
	}

	@override
	void dispose() {
		_countdownTimer?.cancel();
		_pollTimer?.cancel();
		_pulseController.dispose();
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
		final confirmed = await _showCancelDialog();
		if (!confirmed) return;

		setState(() => _cancelling = true);
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
				setState(() => _cancelling = false);
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: const Text('Failed to cancel order'),
						backgroundColor: const Color(0xFFFF3B30),
						behavior: SnackBarBehavior.floating,
						shape:
						RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					),
				);
			}
		}
	}

	Future<bool> _showCancelDialog() async {
		return await showModalBottomSheet<bool>(
			context: context,
			backgroundColor: Colors.transparent,
			builder: (ctx) => Container(
				decoration: const BoxDecoration(
					color: Colors.white,
					borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
				),
				padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Container(
							width: 40,
							height: 4,
							decoration: BoxDecoration(
								color: const Color(0xFFE0E0E0),
								borderRadius: BorderRadius.circular(2),
							),
						),
						const SizedBox(height: 24),
						Container(
							width: 56,
							height: 56,
							decoration: BoxDecoration(
								color: const Color(0xFFFF3B30).withOpacity(0.1),
								shape: BoxShape.circle,
							),
							child: const Icon(
								Icons.cancel_outlined,
								color: Color(0xFFFF3B30),
								size: 28,
							),
						),
						const SizedBox(height: 16),
						const Text(
							'Cancel Payment?',
							style: TextStyle(
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Color(0xFF1A1A2E),
								letterSpacing: -0.3,
							),
						),
						const SizedBox(height: 8),
						const Text(
							'This will cancel your order and\nthe QR code will be invalidated.',
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 14,
								color: Color(0xFF8A8A9A),
								height: 1.5,
							),
						),
						const SizedBox(height: 24),
						Row(
							children: [
								Expanded(
									child: OutlinedButton(
										onPressed: () => Navigator.pop(ctx, false),
										style: OutlinedButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 14),
											side: const BorderSide(color: Color(0xFFE4E4EF)),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										child: const Text(
											'Keep Paying',
											style: TextStyle(
												color: Color(0xFF1A1A2E),
												fontWeight: FontWeight.w600,
											),
										),
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: ElevatedButton(
										onPressed: () => Navigator.pop(ctx, true),
										style: ElevatedButton.styleFrom(
											backgroundColor: const Color(0xFFFF3B30),
											foregroundColor: Colors.white,
											elevation: 0,
											padding: const EdgeInsets.symmetric(vertical: 14),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										child: const Text(
											'Yes, Cancel',
											style: TextStyle(fontWeight: FontWeight.w600),
										),
									),
								),
							],
						),
					],
				),
			),
		) ??
				false;
	}

	@override
	Widget build(BuildContext context) {
		final minutes =
		_remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
		final seconds =
		_remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
		final progress = _remaining.inSeconds / _totalSeconds;
		final isUrgent = _remaining.inSeconds < 60;

		return Scaffold(
			backgroundColor: const Color(0xFFF8F7F4),
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				leading: IconButton(
					icon: Container(
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(12),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withOpacity(0.06),
									blurRadius: 8,
									offset: const Offset(0, 2),
								),
							],
						),
						child: const Icon(Icons.arrow_back_ios_new_rounded,
								size: 16, color: Color(0xFF1A1A2E)),
					),
					onPressed: () => Navigator.pop(context),
				),
				title: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						// Bakong logo placeholder (blue circle B)
						Container(
							width: 28,
							height: 28,
							decoration: const BoxDecoration(
								shape: BoxShape.circle,
								gradient: LinearGradient(
									colors: [Color(0xFF0066FF), Color(0xFF00A3FF)],
									begin: Alignment.topLeft,
									end: Alignment.bottomRight,
								),
							),
							child: const Center(
								child: Text(
									'B',
									style: TextStyle(
										color: Colors.white,
										fontSize: 13,
										fontWeight: FontWeight.w800,
									),
								),
							),
						),
						const SizedBox(width: 8),
						const Text(
							'Bakong Pay',
							style: TextStyle(
								color: Color(0xFF1A1A2E),
								fontWeight: FontWeight.w700,
								fontSize: 17,
								letterSpacing: -0.3,
							),
						),
					],
				),
				centerTitle: true,
			),
			body: SafeArea(
				child: _loading
						? _buildLoading()
						: _error != null
						? _buildError()
						: _buildContent(minutes, seconds, progress, isUrgent),
			),
		);
	}

	Widget _buildLoading() {
		return const Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					SpinKitFadingCircle(color: Color(0xFF0066FF), size: 48),
					SizedBox(height: 20),
					Text(
						'Generating QR Code...',
						style: TextStyle(
							color: Color(0xFF8A8A9A),
							fontSize: 15,
							fontWeight: FontWeight.w500,
						),
					),
				],
			),
		);
	}

	Widget _buildError() {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(32),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Container(
							width: 80,
							height: 80,
							decoration: BoxDecoration(
								color: const Color(0xFFFF3B30).withOpacity(0.1),
								shape: BoxShape.circle,
							),
							child: const Icon(Icons.wifi_off_rounded,
									color: Color(0xFFFF3B30), size: 38),
						),
						const SizedBox(height: 20),
						const Text(
							'Something went wrong',
							style: TextStyle(
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Color(0xFF1A1A2E),
								letterSpacing: -0.3,
							),
						),
						const SizedBox(height: 8),
						Text(
							_error ?? 'Unknown error occurred',
							textAlign: TextAlign.center,
							style: const TextStyle(
								color: Color(0xFF8A8A9A),
								fontSize: 14,
								height: 1.5,
							),
						),
						const SizedBox(height: 28),
						SizedBox(
							width: 160,
							height: 50,
							child: ElevatedButton.icon(
								onPressed: _prepareQr,
								icon: const Icon(Icons.refresh_rounded, size: 18),
								label: const Text('Try Again'),
								style: ElevatedButton.styleFrom(
									backgroundColor: const Color(0xFF0066FF),
									foregroundColor: Colors.white,
									elevation: 0,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(14),
									),
								),
							),
						),
					],
				),
			),
		);
	}

	Widget _buildContent(
			String minutes, String seconds, double progress, bool isUrgent) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20),
			child: Column(
				children: [
					const SizedBox(height: 4),

					// Instruction chip
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
						decoration: BoxDecoration(
							color: const Color(0xFF0066FF).withOpacity(0.08),
							borderRadius: BorderRadius.circular(20),
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Container(
									width: 7,
									height: 7,
									decoration: const BoxDecoration(
										shape: BoxShape.circle,
										color: Color(0xFF0066FF),
									),
								),
								const SizedBox(width: 7),
								const Text(
									'Open Bakong app → Scan QR to pay',
									style: TextStyle(
										color: Color(0xFF0066FF),
										fontSize: 12.5,
										fontWeight: FontWeight.w600,
										letterSpacing: -0.1,
									),
								),
							],
						),
					),

					const SizedBox(height: 16),

					// QR Card
					Container(
						width: double.infinity,
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(24),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withOpacity(0.07),
									blurRadius: 24,
									offset: const Offset(0, 6),
								),
							],
						),
						child: Column(
							children: [
								// QR area
								Padding(
									padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
									child: Stack(
										alignment: Alignment.center,
										children: [
											// Decorative corner frames
											_buildQrFrame(),
											// QR image
											ScaleTransition(
												scale: _pulseAnimation,
												child: Container(
													width: 210,
													height: 210,
													decoration: BoxDecoration(
														borderRadius: BorderRadius.circular(12),
														color: Colors.white,
													),
													child: ClipRRect(
														borderRadius: BorderRadius.circular(12),
														child: _qrImageBytes != null
																? Image.memory(
															_qrImageBytes!,
															fit: BoxFit.contain,
															errorBuilder: (_, __, ___) => const Center(
																child: Text(
																	'Failed to render QR',
																	style:
																	TextStyle(color: Color(0xFF8A8A9A)),
																),
															),
														)
																: const Center(
															child: Text('No QR available'),
														),
													),
												),
											),
										],
									),
								),

								// Divider with Bakong branding
								Padding(
									padding: const EdgeInsets.symmetric(horizontal: 20),
									child: Row(
										children: [
											Expanded(
													child: Container(height: 1, color: const Color(0xFFF0F0F5))),
											Padding(
												padding: const EdgeInsets.symmetric(horizontal: 12),
												child: Row(
													children: [
														Container(
															width: 18,
															height: 18,
															decoration: const BoxDecoration(
																shape: BoxShape.circle,
																gradient: LinearGradient(
																	colors: [Color(0xFF0066FF), Color(0xFF00A3FF)],
																),
															),
															child: const Center(
																child: Text('B',
																		style: TextStyle(
																				color: Colors.white,
																				fontSize: 9,
																				fontWeight: FontWeight.w800)),
															),
														),
														const SizedBox(width: 5),
														const Text(
															'Bakong KHQR',
															style: TextStyle(
																color: Color(0xFF8A8A9A),
																fontSize: 11,
																fontWeight: FontWeight.w600,
															),
														),
													],
												),
											),
											Expanded(
													child: Container(height: 1, color: const Color(0xFFF0F0F5))),
										],
									),
								),

								// Timer section
								Padding(
									padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
									child: Column(
										children: [
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													Row(
														children: [
															Icon(
																Icons.timer_outlined,
																size: 16,
																color: isUrgent
																		? const Color(0xFFFF3B30)
																		: const Color(0xFF8A8A9A),
															),
															const SizedBox(width: 5),
															Text(
																'Expires in',
																style: TextStyle(
																	fontSize: 13,
																	color: isUrgent
																			? const Color(0xFFFF3B30)
																			: const Color(0xFF8A8A9A),
																	fontWeight: FontWeight.w500,
																),
															),
														],
													),
													Container(
														padding: const EdgeInsets.symmetric(
																horizontal: 12, vertical: 5),
														decoration: BoxDecoration(
															color: isUrgent
																	? const Color(0xFFFF3B30).withOpacity(0.1)
																	: const Color(0xFF0066FF).withOpacity(0.08),
															borderRadius: BorderRadius.circular(20),
														),
														child: Text(
															'$minutes:$seconds',
															style: TextStyle(
																fontSize: 16,
																fontWeight: FontWeight.w700,
																color: isUrgent
																		? const Color(0xFFFF3B30)
																		: const Color(0xFF0066FF),
																fontFeatures: const [
																	FontFeature.tabularFigures()
																],
															),
														),
													),
												],
											),
											const SizedBox(height: 10),
											// Progress bar
											ClipRRect(
												borderRadius: BorderRadius.circular(4),
												child: LinearProgressIndicator(
													value: progress,
													minHeight: 5,
													backgroundColor: const Color(0xFFF0F0F5),
													valueColor: AlwaysStoppedAnimation<Color>(
														isUrgent
																? const Color(0xFFFF3B30)
																: const Color(0xFF0066FF),
													),
												),
											),
										],
									),
								),
							],
						),
					),

					const SizedBox(height: 16),

					// Polling status card
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(14),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withOpacity(0.04),
									blurRadius: 10,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Row(
							children: [
								SpinKitPulse(color: const Color(0xFF32C787), size: 20),
								const SizedBox(width: 10),
								const Expanded(
									child: Text(
										'Waiting for payment confirmation...',
										style: TextStyle(
											color: Color(0xFF1A1A2E),
											fontSize: 13.5,
											fontWeight: FontWeight.w500,
										),
									),
								),
								Container(
									padding:
									const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
									decoration: BoxDecoration(
										color: const Color(0xFF32C787).withOpacity(0.1),
										borderRadius: BorderRadius.circular(6),
									),
									child: const Text(
										'LIVE',
										style: TextStyle(
											color: Color(0xFF32C787),
											fontSize: 10,
											fontWeight: FontWeight.w800,
											letterSpacing: 0.5,
										),
									),
								),
							],
						),
					),

					const Spacer(),

					// Steps guide
					_buildStepsGuide(),

					const SizedBox(height: 16),

					// Cancel button
					SizedBox(
						width: double.infinity,
						height: 52,
						child: OutlinedButton(
							onPressed: _cancelling ? null : _cancelOrder,
							style: OutlinedButton.styleFrom(
								foregroundColor: const Color(0xFFFF3B30),
								side: const BorderSide(color: Color(0xFFFFE0DE), width: 1.5),
								backgroundColor: const Color(0xFFFF3B30).withOpacity(0.04),
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(14),
								),
							),
							child: _cancelling
									? const SizedBox(
								width: 20,
								height: 20,
								child: CircularProgressIndicator(
									strokeWidth: 2,
									color: Color(0xFFFF3B30),
								),
							)
									: const Text(
								'Cancel Order',
								style: TextStyle(
									fontSize: 15,
									fontWeight: FontWeight.w600,
									letterSpacing: -0.2,
								),
							),
						),
					),

					const SizedBox(height: 16),
				],
			),
		);
	}

	Widget _buildQrFrame() {
		const frameColor = Color(0xFF0066FF);
		const frameSize = 240.0;
		const cornerLen = 22.0;
		const strokeW = 3.0;

		return SizedBox(
			width: frameSize,
			height: frameSize,
			child: CustomPaint(
				painter: _CornerFramePainter(
					color: frameColor,
					cornerLength: cornerLen,
					strokeWidth: strokeW,
				),
			),
		);
	}

	Widget _buildStepsGuide() {
		final steps = [
			(Icons.phone_android_rounded, 'Open Bakong app'),
			(Icons.qr_code_scanner_rounded, 'Tap Scan QR'),
			(Icons.check_circle_outline_rounded, 'Confirm payment'),
		];

		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			children: List.generate(steps.length, (i) {
				return Row(
					children: [
						Column(
							children: [
								Container(
									width: 40,
									height: 40,
									decoration: BoxDecoration(
										color: const Color(0xFF0066FF).withOpacity(0.08),
										shape: BoxShape.circle,
									),
									child: Icon(steps[i].$1,
											color: const Color(0xFF0066FF), size: 20),
								),
								const SizedBox(height: 5),
								Text(
									steps[i].$2,
									style: const TextStyle(
										fontSize: 11,
										color: Color(0xFF8A8A9A),
										fontWeight: FontWeight.w500,
									),
								),
							],
						),
						if (i < steps.length - 1) ...[
							const SizedBox(width: 8),
							const Icon(Icons.arrow_forward_ios_rounded,
									size: 12, color: Color(0xFFCCCCD8)),
							const SizedBox(width: 8),
						],
					],
				);
			}),
		);
	}
}

class _CornerFramePainter extends CustomPainter {
	final Color color;
	final double cornerLength;
	final double strokeWidth;

	_CornerFramePainter({
		required this.color,
		required this.cornerLength,
		required this.strokeWidth,
	});

	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()
			..color = color
			..strokeWidth = strokeWidth
			..strokeCap = StrokeCap.round
			..style = PaintingStyle.stroke;

		final w = size.width;
		final h = size.height;
		final cl = cornerLength;

		// Top-left
		canvas.drawLine(Offset(0, cl), const Offset(0, 0), paint);
		canvas.drawLine(const Offset(0, 0), Offset(cl, 0), paint);

		// Top-right
		canvas.drawLine(Offset(w - cl, 0), Offset(w, 0), paint);
		canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

		// Bottom-left
		canvas.drawLine(Offset(0, h - cl), Offset(0, h), paint);
		canvas.drawLine(Offset(0, h), Offset(cl, h), paint);

		// Bottom-right
		canvas.drawLine(Offset(w - cl, h), Offset(w, h), paint);
		canvas.drawLine(Offset(w, h), Offset(w, h - cl), paint);
	}

	@override
	bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}