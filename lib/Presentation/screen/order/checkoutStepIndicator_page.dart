import 'package:flutter/material.dart';

class CheckoutStepIndicator extends StatefulWidget {
  final int currentStep;
  final Function(int) onStepTap;

  CheckoutStepIndicator({
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  State<CheckoutStepIndicator> createState() => _CheckoutStepIndicatorState();
}

class _CheckoutStepIndicatorState extends State<CheckoutStepIndicator> {
  final steps = ['ADDRESS', 'PAYMENT', 'REVIEW'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        bool isActive = i <= widget.currentStep;
        bool isCurrent = i == widget.currentStep;

        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onStepTap(i), //  send to parent
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        isActive ? Colors.blue : Colors.grey,
                      ),
                    ),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent
                            ? Colors.blue
                            : Colors.grey,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Divider(
                      color: i < widget.currentStep
                          ? Colors.blue
                          : Colors.grey,
                      thickness: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}