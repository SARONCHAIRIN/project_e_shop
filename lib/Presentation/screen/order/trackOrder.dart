import 'package:e_shop/Presentation/controllers/cart/cart_controller.dart';
import 'package:e_shop/Presentation/screen/cart/cart_screen.dart';
import 'package:e_shop/Presentation/screen/order/orderSuccessScreen.dart';
import 'package:e_shop/Presentation/screen/sub_category_screen/product_detail_screen_eshop.dart';
import 'package:e_shop/data/models/cart/cart_item_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
class TrackOrderPage extends StatefulWidget {
  const TrackOrderPage({super.key});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderSuccessScreen(
            paymentMethod: '',
            orderId: 0,
    ))),),
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {

            },
          ),
        ],
      ),
      body:  SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderStatusHeader(),
            const SizedBox(height: 12),
            _EstimatedArrivalCard(),
            const SizedBox(height: 12),
            _CarrierInfoCard(),
            const SizedBox(height: 12),
            _JourneyProgressCard(),
            const SizedBox(height: 12),
            _DestinationCard(),
            const SizedBox(height: 12),

            // _PackageContentsCard(),
            const SizedBox(height: 24),
            _ContactSupportButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Order Status Header ──────────────────────────────────────────────────────

class _OrderStatusHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER STATUS',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '#ORD-772910',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                'Placed Oct 22, 2023',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Estimated Arrival Card ───────────────────────────────────────────────────

class _EstimatedArrivalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'ESTIMATED ARRIVAL',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Color(0xFF3B6D11),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Oct 26, 2023',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'By 8:00 PM',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Carrier Info Card ────────────────────────────────────────────────────────

class _CarrierInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CARRIER INFORMATION',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF185FA5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Indigo Logistics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'IN-99201-XT',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF185FA5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Journey Progress Card ────────────────────────────────────────────────────

class _JourneyProgressCard extends StatelessWidget {
  final List<_JourneyStep> steps = const [
    _JourneyStep(
      icon: Icons.check_circle_outline,
      title: 'Order Placed',
      subtitle: 'Your order has been confirmed.',
      time: 'Oct 22, 10:45 AM',
      isCompleted: true,
    ),
    _JourneyStep(
      icon: Icons.inventory_2_outlined,
      title: 'Shipped',
      subtitle: 'Carrier has picked up your package.',
      time: 'Oct 23, 02:15 PM',
      isCompleted: true,
    ),
    _JourneyStep(
      icon: Icons.delivery_dining_outlined,
      title: 'Out for Delivery',
      subtitle: 'Package is with the local courier.',
      time: 'Expected Today',
      isCompleted: true,
      isHighlightTime: true,
    ),
    _JourneyStep(
      icon: Icons.check_circle_outline,
      title: 'Delivered',
      subtitle: 'Signature required upon arrival.',
      time: '',
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JOURNEY PROGRESS',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            return _JourneyStepRow(
              step: steps[i],
              isLast: i == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _JourneyStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isCompleted;
  final bool isHighlightTime;

  const _JourneyStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isCompleted,
    this.isHighlightTime = false,
  });
}

class _JourneyStepRow extends StatelessWidget {
  final _JourneyStep step;
  final bool isLast;

  const _JourneyStepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF3B30C4);
    const inactiveColor = Color(0xFFD3D1C7);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted ? activeColor : Colors.white,
                    border: step.isCompleted
                        ? null
                        : Border.all(color: inactiveColor),
                  ),
                  child: Icon(
                    step.icon,
                    size: 18,
                    color: step.isCompleted ? Colors.white : inactiveColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.isCompleted ? activeColor : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: step.isCompleted
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                  if (step.time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF185FA5),
                        fontWeight: step.isHighlightTime
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Destination Card ─────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESTINATION',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Container(
          //       width: 40,
          //       height: 40,
          //       decoration: BoxDecoration(
          //         color: const Color(0xFFF1EFE8),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Icon(
          //         Icons.location_on_outlined,
          //         color: Colors.grey,
          //         size: 20,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     const Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Jonathan Sterling',
          //             style: TextStyle(
          //               fontSize: 14,
          //               fontWeight: FontWeight.w600,
          //               color: Colors.black,
          //             ),
          //           ),
          //           SizedBox(height: 4),
          //           Text(
          //             '482 Cobalt Avenue, Suite 12\nIndigo District, NY 10012\nUnited States',
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.grey,
          //               height: 1.6,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}


class _PackageItem extends StatelessWidget {
  final Color imageColor;
  final IconData icon;
  final String name;
  final String variant;
  final String price;

  const _PackageItem({
    required this.imageColor,
    required this.icon,
    required this.name,
    required this.variant,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: imageColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                variant,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF185FA5),
          ),
        ),
      ],
    );
  }
}

// ── Contact Support Button ───────────────────────────────────────────────────

class _ContactSupportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          _openTelegram();
        },
        icon: const Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: Color(0xFF185FA5),
        ),
        label: const Text(
          'CONTACT SUPPORT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFF185FA5),
          ),
        ),
      ),
    );
  }
}

final String username = "chairin312007";

Future<void> _openTelegram() async {
  final Uri appUrl = Uri.parse("tg://resolve?domain=$username");
  final Uri webUrl = Uri.parse("https://t.me/$username");

  // Try open Telegram app
  if (await canLaunchUrl(appUrl)) {
    await launchUrl(appUrl);
  }
  // fallback to browser
  else {
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }
}

// ── Shared Card Widget ───────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: child,
    );
  }
}

