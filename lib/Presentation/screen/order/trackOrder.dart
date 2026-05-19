import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/order/order_model.dart';
import '../../../data/repositories/order_repository.dart';

class TrackOrderPage extends StatefulWidget {
  final int orderId;
  final int userId;
  final String token;

  const TrackOrderPage({
    super.key,
    required this.orderId,
    required this.userId,
    required this.token,
  });

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage>
    with SingleTickerProviderStateMixin {
  final OrderRepository _repo = OrderRepository();

  OrderModel? _order;
  bool _loading = true;
  String? _error;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _repo.getOrderDetail(
        orderId: widget.orderId,
        token: widget.token,
      );

      setState(() {
        _order = res;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Track Order",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : FadeTransition(
        opacity: _controller,
        child: _buildBody(),
      ),
    );
  }

  // ───────────────────────── BODY
  Widget _buildBody() {
    final order = _order!;
    final status = order.status?.name ?? "PENDING";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _orderHeader(order),
        const SizedBox(height: 12),
        _statusBadge(status),
        const SizedBox(height: 16),
        _progressTimeline(status),
        const SizedBox(height: 16),
        _orderItems(order),
        const SizedBox(height: 20),
        _supportButton(),
      ],
    );
  }

  // ───────────────────────── HEADER (REAL APP STYLE)
  Widget _orderHeader(OrderModel order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "#${order.orderNumber}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Total: \$${order.total.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── STATUS BADGE (ANIMATED LOOK)
  Widget _statusBadge(String status) {
    final isActive = status != "CANCELLED";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping,
            color: isActive ? Colors.blue : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.blue : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── REAL ANIMATED TIMELINE (LIKE SHOPEE)
  Widget _progressTimeline(String status) {
    final steps = ["PENDING", "CONFIRMED", "SHIPPED", "DELIVERED"];
    final current = steps.indexOf(status);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (i) {
          final done = i <= current;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (i * 100)),
            margin: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? Colors.green : Colors.white,
                    border: Border.all(
                      color: done ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.circle_outlined,
                    size: 16,
                    color: done ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: done ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      done ? "Completed" : "Pending",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────── ITEMS (MODERN PRODUCT STYLE)
  Widget _orderItems(OrderModel order) {
    final items = order.items ?? [];

    if (items.isEmpty) {
      return _card(
        child: const Text(
          "No items found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _card(
      child: Column(
        children: items.map((item) {
          final sku = item.productSku;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Hero(
                  tag: sku.id,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,

                    ),
                    child: Icon(Icons.picture_as_pdf_outlined,size: 30,color: Colors.grey,),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sku.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  "\$${item.unitPrice}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  // ───────────────────────── SUPPORT BUTTON (MODERN CTA)
  Widget _supportButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _openTelegram,
        icon: const Icon(Icons.chat),
        label: const Text("Chat Support"),
      ),
    );
  }

  Future<void> _openTelegram() async {
    final url = Uri.parse("https://t.me/your_support");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // ───────────────────────── CARD DESIGN (MODERN SHADOW)
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }

  // ───────────────────────── ERROR UI (MODERN)
  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 10),
          Text(_error ?? "Error"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _load,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}