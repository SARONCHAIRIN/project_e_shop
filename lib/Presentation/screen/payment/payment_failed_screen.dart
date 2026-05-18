import 'package:flutter/material.dart';

class PaymentFailedScreen extends StatefulWidget {
	final String reason;

	const PaymentFailedScreen({super.key, required this.reason});

	@override
	State<PaymentFailedScreen> createState() => _PaymentFailedScreenState();
}

class _PaymentFailedScreenState extends State<PaymentFailedScreen>
		with SingleTickerProviderStateMixin {
	late AnimationController _controller;
	late Animation<double> _fadeIn;
	late Animation<double> _scaleIn;
	late Animation<Offset> _slideUp;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 700),
		);

		_fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
		_scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
			CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
		);
		_slideUp = Tween<Offset>(
			begin: const Offset(0, 0.3),
			end: Offset.zero,
		).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

		_controller.forward();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;

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
				title: const Text(
					'Payment Status',
					style: TextStyle(
						color: Color(0xFF1A1A2E),
						fontWeight: FontWeight.w600,
						fontSize: 17,
						letterSpacing: -0.3,
					),
				),
				centerTitle: true,
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 24.0),
					child: Column(
						children: [
							const Spacer(flex: 2),

							// Animated icon section
							FadeTransition(
								opacity: _fadeIn,
								child: ScaleTransition(
									scale: _scaleIn,
									child: Column(
										children: [
											// Error icon with layered glow
											Stack(
												alignment: Alignment.center,
												children: [
													Container(
														width: 120,
														height: 120,
														decoration: BoxDecoration(
															shape: BoxShape.circle,
															color: const Color(0xFFFF3B30).withOpacity(0.08),
														),
													),
													Container(
														width: 90,
														height: 90,
														decoration: BoxDecoration(
															shape: BoxShape.circle,
															color: const Color(0xFFFF3B30).withOpacity(0.14),
														),
													),
													Container(
														width: 68,
														height: 68,
														decoration: const BoxDecoration(
															shape: BoxShape.circle,
															color: Color(0xFFFF3B30),
														),
														child: const Icon(
															Icons.close_rounded,
															color: Colors.white,
															size: 34,
														),
													),
												],
											),
										],
									),
								),
							),

							const SizedBox(height: 32),

							// Text content
							SlideTransition(
								position: _slideUp,
								child: FadeTransition(
									opacity: _fadeIn,
									child: Column(
										children: [
											const Text(
												'Payment Failed',
												style: TextStyle(
													fontSize: 26,
													fontWeight: FontWeight.w700,
													color: Color(0xFF1A1A2E),
													letterSpacing: -0.5,
													height: 1.2,
												),
											),
											const SizedBox(height: 10),
											Text(
												widget.reason,
												textAlign: TextAlign.center,
												style: const TextStyle(
													fontSize: 15,
													color: Color(0xFF8A8A9A),
													height: 1.5,
													letterSpacing: -0.1,
												),
											),
										],
									),
								),
							),

							const SizedBox(height: 32),

							// Info card
							FadeTransition(
								opacity: _fadeIn,
								child: Container(
									padding: const EdgeInsets.all(18),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(16),
										boxShadow: [
											BoxShadow(
												color: Colors.black.withOpacity(0.05),
												blurRadius: 16,
												offset: const Offset(0, 4),
											),
										],
									),
									child: Column(
										children: [
											_InfoRow(
												icon: Icons.receipt_long_rounded,
												label: 'Transaction',
												value: '#TXN-28471',
												iconColor: const Color(0xFF6C63FF),
											),
											const Padding(
												padding: EdgeInsets.symmetric(vertical: 12),
												child: Divider(height: 1, color: Color(0xFFF0F0F5)),
											),
											_InfoRow(
												icon: Icons.calendar_today_rounded,
												label: 'Date & Time',
												value: _formattedNow(),
												iconColor: const Color(0xFF32C787),
											),
											const Padding(
												padding: EdgeInsets.symmetric(vertical: 12),
												child: Divider(height: 1, color: Color(0xFFF0F0F5)),
											),
											_InfoRow(
												icon: Icons.error_outline_rounded,
												label: 'Reason',
												value: 'Declined by bank',
												iconColor: const Color(0xFFFF3B30),
											),
										],
									),
								),
							),

							const Spacer(flex: 3),

							// Action buttons
							SlideTransition(
								position: _slideUp,
								child: FadeTransition(
									opacity: _fadeIn,
									child: Column(
										children: [
											// Primary button
											SizedBox(
												width: double.infinity,
												height: 54,
												child: ElevatedButton(
													onPressed: () {},
													style: ElevatedButton.styleFrom(
														backgroundColor: const Color(0xFF1A1A2E),
														foregroundColor: Colors.white,
														elevation: 0,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(14),
														),
													),
													child: const Text(
														'Try Again',
														style: TextStyle(
															fontSize: 16,
															fontWeight: FontWeight.w600,
															letterSpacing: -0.2,
														),
													),
												),
											),

											const SizedBox(height: 12),

											// Secondary button
											SizedBox(
												width: double.infinity,
												height: 54,
												child: OutlinedButton(
													onPressed: () => Navigator.pop(context),
													style: OutlinedButton.styleFrom(
														foregroundColor: const Color(0xFF1A1A2E),
														side: const BorderSide(
															color: Color(0xFFE4E4EF),
															width: 1.5,
														),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(14),
														),
													),
													child: const Text(
														'Back to Orders',
														style: TextStyle(
															fontSize: 16,
															fontWeight: FontWeight.w500,
															letterSpacing: -0.2,
														),
													),
												),
											),

											const SizedBox(height: 12),

											// Help link
											TextButton(
												onPressed: () {},
												child: const Text(
													'Need help? Contact support',
													style: TextStyle(
														fontSize: 13,
														color: Color(0xFF8A8A9A),
														fontWeight: FontWeight.w500,
													),
												),
											),

											const SizedBox(height: 8),
										],
									),
								),
							),
						],
					),
				),
			),
		);
	}

	String _formattedNow() {
		final now = DateTime.now();
		const months = [
			'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
			'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
		];
		final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
		final minute = now.minute.toString().padLeft(2, '0');
		final period = now.hour >= 12 ? 'PM' : 'AM';
		return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute $period';
	}
}

class _InfoRow extends StatelessWidget {
	final IconData icon;
	final String label;
	final String value;
	final Color iconColor;

	const _InfoRow({
		required this.icon,
		required this.label,
		required this.value,
		required this.iconColor,
	});

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Container(
					width: 36,
					height: 36,
					decoration: BoxDecoration(
						color: iconColor.withOpacity(0.1),
						borderRadius: BorderRadius.circular(10),
					),
					child: Icon(icon, color: iconColor, size: 18),
				),
				const SizedBox(width: 12),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								label,
								style: const TextStyle(
									fontSize: 12,
									color: Color(0xFF8A8A9A),
									fontWeight: FontWeight.w500,
								),
							),
							const SizedBox(height: 2),
							Text(
								value,
								style: const TextStyle(
									fontSize: 14,
									color: Color(0xFF1A1A2E),
									fontWeight: FontWeight.w600,
									letterSpacing: -0.2,
								),
							),
						],
					),
				),
			],
		);
	}
}