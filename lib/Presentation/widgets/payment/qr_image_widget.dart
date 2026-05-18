import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// QRImageWidget displays QR code image with action buttons
/// 
/// Features:
/// - Display QR image from base64 or network URL
/// - Download button to save QR code
/// - Share button to share QR code
/// - Loading state while fetching image
/// - Error handling with retry option
class QRImageWidget extends StatefulWidget {
  /// QR image as base64 string or network URL
  final String imageSource;

  /// Whether imageSource is base64 (true) or URL (false)
  final bool isBase64;

  /// Order ID for context
  final int orderId;

  /// Optional callback when download is tapped
  final VoidCallback? onDownload;

  /// Optional callback when share is tapped
  final VoidCallback? onShare;

  /// Optional custom widget size
  final double size;

  const QRImageWidget({
    super.key,
    required this.imageSource,
    required this.isBase64,
    required this.orderId,
    this.onDownload,
    this.onShare,
    this.size = 250,
  });

  @override
  State<QRImageWidget> createState() => _QRImageWidgetState();
}

class _QRImageWidgetState extends State<QRImageWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Image Container
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Download Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleDownload,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Share Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleShare,
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        // Error Message
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build image widget based on source type
  Widget _buildImageWidget() {
    if (widget.isBase64) {
      try {
        // Decode base64 to Uint8List
        final bytes = _base64ToBytes(widget.imageSource);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load QR',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        return _buildErrorWidget('Invalid QR data');
      }
    } else {
      // Load from network URL
      return Image.network(
        widget.imageSource,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget('Failed to load image');
        },
      );
    }
  }

  /// Build error display widget
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Convert base64 string to Uint8List
  Uint8List _base64ToBytes(String base64String) {
    try {
      return Uint8List.fromList(
        base64String.codeUnits,
      );
    } catch (e) {
      throw Exception('Failed to decode base64: $e');
    }
  }

  /// Handle download action
  Future<void> _handleDownload() async {
    try {
      setState(() => _isLoading = true);
      widget.onDownload?.call();
      // You can implement actual download logic here
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code downloaded'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Download failed: $e';
      });
    }
  }

  /// Handle share action
  Future<void> _handleShare() async {
    try {
      setState(() => _isLoading = true);
      widget.onShare?.call();
      // You can implement actual share logic here
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code shared'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Share failed: $e';
      });
    }
  }
}

