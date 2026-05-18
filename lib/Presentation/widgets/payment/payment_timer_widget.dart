import 'package:flutter/material.dart';
import 'dart:async';

/// PaymentTimerWidget displays a countdown timer for payment (default 5 minutes)
/// 
/// Features:
/// - Countdown timer display (MM:SS format)
/// - Color changes on warning (yellow at 1 min, red at 30 sec)
/// - Auto-cancel callback on timeout
/// - Customizable duration
/// - Pause/resume support
class PaymentTimerWidget extends StatefulWidget {
  /// Total duration in seconds (default: 300 = 5 minutes)
  final int totalSeconds;

  /// Callback when timer reaches zero
  final VoidCallback? onTimeout;

  /// Optional custom styling
  final Color? initialColor;
  final Color? warningColor;
  final Color? dangerColor;
  final double fontSize;

  const PaymentTimerWidget({
    super.key,
    this.totalSeconds = 300,
    this.onTimeout,
    this.initialColor,
    this.warningColor,
    this.dangerColor,
    this.fontSize = 28,
  });

  @override
  State<PaymentTimerWidget> createState() => _PaymentTimerWidgetState();
}

class _PaymentTimerWidgetState extends State<PaymentTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _remainingSeconds--;
          if (_remainingSeconds <= 0) {
            _timer?.cancel();
            widget.onTimeout?.call();
          }
        });
      }
    });
  }

  /// Get color based on time remaining
  Color _getTimerColor() {
    final oneMinute = 60;
    final thirtySeconds = 30;

    if (_remainingSeconds <= thirtySeconds) {
      return widget.dangerColor ?? Colors.red;
    } else if (_remainingSeconds <= oneMinute) {
      return widget.warningColor ?? Colors.orange;
    }
    return widget.initialColor ?? Colors.blue;
  }

  /// Format seconds to MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Toggle pause/resume
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _getTimerColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTimerColor(),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Time Remaining',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: _getTimerColor(),
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
                child: Text(_formatTime(_remainingSeconds)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pause Button (optional)
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: _togglePause,
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              size: 18,
            ),
            label: Text(
              _isPaused ? 'Resume' : 'Pause',
              style: const TextStyle(fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Warning Message
        if (_remainingSeconds <= 30) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment expiring soon! Complete your transaction.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_remainingSeconds <= 60) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complete payment within the time limit.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

