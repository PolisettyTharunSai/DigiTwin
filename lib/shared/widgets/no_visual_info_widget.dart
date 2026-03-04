import 'package:flutter/material.dart';

/// Placeholder widget shown when no image or 3D model is available
/// for the current day. Displays a ghost-eye icon and a descriptive message.
class NoVisualInfoWidget extends StatelessWidget {
  final String message;
  final double height;

  const NoVisualInfoWidget({
    super.key,
    required this.message,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            size: 58,
            color: Colors.grey,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
