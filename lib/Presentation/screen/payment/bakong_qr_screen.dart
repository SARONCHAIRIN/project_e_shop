import 'dart:async';
import 'dart:typed_data';
import 'package:e_shop/Presentation/screen/order/orderSuccessScreen.dart';
import 'package:e_shop/core/widgets/animation_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/repositories/payment_repository.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_failed_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class BakongQrScreen extends StatefulWidget {
  final int orderId;
  final String bakongQrString;
  final String paymentUrl;
  final String bakongMd5;
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  // New optional fields used to populate the order info card
  final String? customerName;
  final String? orderCode;
  final DateTime? orderDate;
  final String? note;

  const BakongQrScreen({
    super.key,
    required this.orderId,
    required this.bakongQrString,
    required this.paymentUrl,
    required this.bakongMd5,
    required this.orderRepository,
    required this.paymentRepository,
    this.customerName,
    this.orderCode,
    this.orderDate,
    this.note,
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

  final ScreenshotController _screenshotController = ScreenshotController();

  static const Color _blue = Color(0xFF0066FF);
  static const Color _blueLight = Color(0xFF00A3FF);
  static const Color _ink = Color(0xFF1A1A2E);
  static const Color _muted = Color(0xFF8A8A9A);
  static const Color _hairline = Color(0xFFF0F0F5);
  static const Color _red = Color(0xFFFF3B30);
  static const Color _green = Color(0xFF32C787);
  static const Color _bg = Color(0xFFF8F7F4);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
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
    int _retryCount = 0;
    const maxRetries = 3;

    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;

      try {
        final storage = TokenStorage();
        final token = await storage.getToken();

        final res = await widget.paymentRepository.checkTransaction(
          md5: widget.bakongMd5,
          token: token ?? '',
        );

        _retryCount = 0;

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
            FadeSlideRoute(
              page: OrderSuccessScreen(
                paymentMethod: "BAKONG",
                orderId: order.id,
              ),
            ),
          );
        }
      } catch (e) {
        _retryCount++;
        debugPrint(
          '[BakongQrScreen] Polling error ($_retryCount/$maxRetries): $e',
        );

        if (_retryCount >= maxRetries) {
          debugPrint('[BakongQrScreen] Too many errors, pausing poll...');
          timer.cancel();

          await Future.delayed(const Duration(seconds: 10));
          if (mounted) {
            _retryCount = 0;
            _startPolling();
          }
        }
      }
    });
  }

  Future<void> _saveQrToGallery() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final status = await Permission.photos.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied")));
        return;
      }

      await Gal.putImageBytes(image, album: "E-Shop QR");

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("QR saved to gallery")));
    } catch (e) {
      debugPrint("Save QR error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save QR")));
    }
  }

  Future<void> _openBakongApp() async {
    final uri = Uri.parse(widget.paymentUrl);
    debugPrint("Payment URL: $uri");

    try {
      final canOpen = await canLaunchUrl(uri);
      debugPrint("Can launch: $canOpen");

      if (!canOpen) {
        debugPrint("❌ Cannot open Bakong deep link");
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      debugPrint("Launch result: $launched");
    } catch (e) {
      debugPrint("Error opening Bakong: $e");
    }
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
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    color: _red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: _red,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cancel Payment?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will cancel your order and\nthe QR code will be invalidated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _muted, height: 1.5),
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
                            color: _ink,
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
                          backgroundColor: _red,
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
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final progress = _remaining.inSeconds / _totalSeconds;
    final isUrgent = _remaining.inSeconds < 60;

    return Scaffold(
      backgroundColor: _bg,
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
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _ink,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: _buildContent(minutes, seconds, progress, isUrgent),
              ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(color: _blue, size: 48),
          SizedBox(height: 20),
          Text(
            'Generating QR Code...',
            style: TextStyle(
              color: _muted,
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
                color: _red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: _red, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
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
                  backgroundColor: _blue,
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

  // ---------- Header: "E Shop" logo + tagline ----------
  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_blue, _blueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'E',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'E Shop',
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w800,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(),
            const SizedBox(width: 6),
            Text(
              'Easy Shopping, Happy Living',
              style: TextStyle(
                color: _muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            _dot(),
          ],
        ),
      ],
    );
  }

  Widget _dot() => Container(
    width: 4,
    height: 4,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: _muted),
  );

  // ---------- Bakong Pay pill badge ----------
  Widget _buildBakongBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_blue, _blueLight]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'BAKONG PAY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    String minutes,
    String seconds,
    double progress,
    bool isUrgent,
  ) {
    final customerName = widget.customerName ?? '-';
    final orderCode = widget.orderCode ?? 'ORD-${widget.orderId}';
    final date = widget.orderDate ?? DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy  •  hh:mm a').format(date);
    final note = widget.note ?? 'Thank you for shopping with E Shop!';

    return Column(
      children: [
        const SizedBox(height: 8),
        _buildHeader(),
        const SizedBox(height: 20),
        _buildBakongBadge(),
        const SizedBox(height: 16),

        // Main receipt-style card (captured for screenshot / save-to-gallery)
        Screenshot(
          controller: _screenshotController,
          child: Container(
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
                const SizedBox(height: 16),
                // Instruction chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.08),
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
                          color: _blue,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Open Bakong app → Scan QR to pay',
                        style: TextStyle(
                          color: _blue,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // QR area
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildQrFrame(),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _qrImageBytes != null
                            ? Image.memory(_qrImageBytes!, fit: BoxFit.contain)
                            : const Center(child: Text("No QR")),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Divider with Bakong branding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 1, color: _hairline)),
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
                                  colors: [_blue, _blueLight],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'B',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Bakong KHQR',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: _hairline)),
                    ],
                  ),
                ),

                // Order info card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.person_outline_rounded,
                          'Customer Name',
                          customerName,
                        ),
                        _infoDivider(),
                        _infoRow(
                          Icons.description_outlined,
                          'Order ID',
                          orderCode,
                        ),
                        _infoDivider(),
                        _infoRow(
                          Icons.calendar_today_outlined,
                          'Date',
                          dateStr,
                        ),
                        _infoDivider(),
                        _infoRow(Icons.notes_outlined, 'Note', note),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Timer section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
                        color: isUrgent ? _red : _muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Expires in',
                        style: TextStyle(
                          fontSize: 13,
                          color: isUrgent ? _red : _muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (isUrgent ? _red : _blue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$minutes:$seconds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? _red : _blue,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: _hairline,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUrgent ? _red : _blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15),

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
              PulsingDot(color: _green, size: 10),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Waiting for payment confirmation...',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: _green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        _buildStepsGuide(),
        const SizedBox(height: 16),

        // Cancel button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _cancelling ? null : _cancelOrder,
            style: OutlinedButton.styleFrom(
              foregroundColor: _red,
              side: const BorderSide(color: Color(0xFFFFE0DE), width: 1.5),
              backgroundColor: _red.withOpacity(0.04),
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
                      color: _red,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cancel_outlined, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Open Bakong to Pay
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _openBakongApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
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
                  'Open Bakong to Pay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Save QR to Gallery
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saveQrToGallery,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Save QR to Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),
        _buildFooter(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: _blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                color: _ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoDivider() => Container(height: 1, color: _hairline);

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_outlined, size: 15, color: _muted),
            SizedBox(width: 6),
            Text(
              'Secure Payment',
              style: TextStyle(
                fontSize: 12.5,
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Powered by ',
              style: TextStyle(fontSize: 11.5, color: _muted),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _red,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'BAKONG',
              style: TextStyle(
                fontSize: 11.5,
                color: _ink,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrFrame() {
    const frameColor = _blue;
    const frameSize = 250.0;
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
                    color: _blue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(steps[i].$1, color: _blue, size: 20),
                ),
                const SizedBox(height: 5),
                Text(
                  steps[i].$2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFFCCCCD8),
              ),
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

    canvas.drawLine(Offset(0, cl), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(cl, 0), paint);

    canvas.drawLine(Offset(w - cl, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

    canvas.drawLine(Offset(0, h - cl), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cl, h), paint);

    canvas.drawLine(Offset(w - cl, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cl), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
