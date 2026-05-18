import 'package:flutter/material.dart';

/// PaymentMethodTile widget for selecting payment method (COD or Bakong)
/// 
/// Features:
/// - Display icon, title, description
/// - Show selected state with visual feedback
/// - Tap to select payment method
/// - Reusable and customizable
class PaymentMethodTile extends StatelessWidget {
  /// Payment method icon (e.g., Icons.local_atm, Icons.qr_code)
  final IconData icon;

  /// Payment method title (e.g., "Cash on Delivery", "Bakong QR")
  final String title;

  /// Description text for the method
  final String description;

  /// Whether this payment method is currently selected
  final bool isSelected;

  /// Callback when tile is tapped
  final VoidCallback onTap;

  /// Optional custom icon color
  final Color? iconColor;

  /// Optional custom background color when selected
  final Color? selectedColor;

  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.iconColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? Colors.blue.shade50)
              : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Selection Indicator
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

