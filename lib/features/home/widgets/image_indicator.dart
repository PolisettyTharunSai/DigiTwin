import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Animated dot-indicator row for the media carousel.
/// Active dot expands to show which image is currently visible.
class ImageIndicator extends StatelessWidget {
  final int imageCount;
  final int currentIndex;

  const ImageIndicator({
    super.key,
    required this.imageCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageCount, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
