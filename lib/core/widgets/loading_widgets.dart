import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ── 1. Shimmer Skeleton ───────────────────────────────────────

/// Animated shimmer effect for skeleton loading placeholders.
///
/// Usage:
/// ```dart
/// ShimmerBox(width: double.infinity, height: 20)
/// ShimmerBox(width: 120, height: 120, borderRadius: 60) // circle
/// ```
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── 2. Order Card Skeleton ────────────────────────────────────

/// Full skeleton for an order card while loading.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerBox(width: 110, height: 16),
              const ShimmerBox(width: 80, height: 26, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const ShimmerBox(width: 160, height: 14),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 80, height: 14),
              ShimmerBox(width: 64, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 3. Order Detail Skeleton ──────────────────────────────────

/// Skeleton layout for the full order detail screen while loading.
class OrderDetailSkeleton extends StatelessWidget {
  const OrderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          _skeletonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 130, height: 22),
                    ShimmerBox(width: 90, height: 28, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: 8),
                const ShimmerBox(width: 160, height: 13),
                const SizedBox(height: 20),
                // Timeline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                    (_) => Column(
                      children: const [
                        ShimmerBox(width: 32, height: 32, borderRadius: 16),
                        SizedBox(height: 6),
                        ShimmerBox(width: 48, height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Items card
          _skeletonCard(
            child: Column(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      const ShimmerBox(width: 70, height: 70, borderRadius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ShimmerBox(width: double.infinity, height: 14),
                            SizedBox(height: 8),
                            ShimmerBox(width: 100, height: 14),
                            SizedBox(height: 8),
                            ShimmerBox(width: 60, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Address + payment
          _skeletonCard(
            child: Column(
              children: const [
                ShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: 10),
                ShimmerBox(width: double.infinity, height: 14),
                SizedBox(height: 10),
                ShimmerBox(width: 200, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// ── 4. Full-Screen Loading Overlay ────────────────────────────

/// Blocks user interaction and shows a centered spinner with message.
///
/// Usage — wrap your Scaffold body:
/// ```dart
/// LoadingOverlay(
///   isLoading: _isPlacingOrder,
///   message: 'Placing your order...',
///   child: YourScreen(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: SpinKitCircle(color: Colors.grey, size: 25),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── 5. Interaction Disabler ───────────────────────────────────

/// Wraps a widget to visually dim and block all touch events.
///
/// Usage:
/// ```dart
/// InteractionDisabler(
///   disabled: isLoading,
///   child: ElevatedButton(...),
/// )
/// ```
class InteractionDisabler extends StatelessWidget {
  final bool disabled;
  final Widget child;
  final double disabledOpacity;

  const InteractionDisabler({
    super.key,
    required this.disabled,
    required this.child,
    this.disabledOpacity = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: disabled ? disabledOpacity : 1.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(ignoring: disabled, child: child),
    );
  }
}
