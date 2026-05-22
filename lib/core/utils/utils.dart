import 'dart:async';
import 'package:flutter/material.dart';

// ── 1. Double-Submit Guard ────────────────────────────────────

/// Prevents a button from being tapped multiple times while an
/// async operation is in progress.
///
/// Usage:
/// ```dart
/// final _guard = SubmitGuard();
///
/// onPressed: () => _guard.run(() async {
///   await placeOrder();
/// }),
/// ```
class SubmitGuard {
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> run(Future<void> Function() action) async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await action();
    } finally {
      _isRunning = false;
    }
  }

  void reset() => _isRunning = false;
}

// ── 2. Timeout Wrapper ────────────────────────────────────────

/// Wraps any future with a timeout and a clean error message.
///
/// Usage:
/// ```dart
/// final result = await withTimeout(
///   future: apiService.placeOrder(),
///   duration: Duration(seconds: 30),
///   timeoutMessage: 'Order request timed out. Please try again.',
/// );
/// ```
Future<T> withTimeout<T>({
  required Future<T> future,
  Duration duration = const Duration(seconds: 30),
  String? timeoutMessage,
}) async {
  try {
    return await future.timeout(duration);
  } on TimeoutException {
    throw TimeoutException(
      timeoutMessage ?? 'Request timed out. Please check your connection.',
    );
  }
}

// ── 3. Error Recovery Handler ─────────────────────────────────

/// Centralized error recovery: shows a dialog with a retry option.
///
/// Usage:
/// ```dart
/// await ErrorRecovery.show(
///   context: context,
///   message: 'Failed to place order.',
///   onRetry: () => placeOrder(),
/// );
/// ```
class ErrorRecovery {
  static Future<void> show({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    String? retryLabel,
    bool barrierDismissible = true,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => _ErrorDialog(
        message: message,
        onRetry: onRetry,
        retryLabel: retryLabel,
      ),
    );
  }

  /// Shows a lightweight snackbar error (non-blocking).
  static void showSnackBar(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Shows a success snackbar.
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF32C787),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const _ErrorDialog({required this.message, this.onRetry, this.retryLabel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 35,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRetry!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        retryLabel ?? 'Try Again',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
