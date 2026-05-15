import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../core/constants/app_colors.dart';

/// 2D image carousel displayed when [show3DModel] is false
/// and the current day has available images.
class MediaCarousel extends StatelessWidget {
  final List<String> images;
  final double imageWidth;
  final double imageHeight;
  final CarouselSliderController carouselController;
  final void Function(int index) onPageChanged;
  final void Function(int index) onImageTap;

  const MediaCarousel({
    super.key,
    required this.images,
    required this.imageWidth,
    required this.imageHeight,
    required this.carouselController,
    required this.onPageChanged,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: carouselController,
      options: CarouselOptions(
        height: imageHeight,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        enlargeCenterPage: false,
        onPageChanged: (index, _) => onPageChanged(index),
      ),
      items: images.asMap().entries.map((entry) {
        final i = entry.key;
        final img = entry.value;

        return GestureDetector(
          onTap: () => onImageTap(i),
          child: Container(
            width: imageWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                img,
                // Using loadingBuilder to intercept the raw image and apply custom cropping
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    // Image is fully loaded. Apply the required crop:
                    // Top-left: (1100, 1404)
                    // Bottom-right: (1982, 3500)
                    // Width = 1982 - 1100 = 882
                    // Height = 3500 - 1404 = 2096
                    return FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: 882,
                        height: 2096,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -1100,
                              top: -1404,
                              child: child,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _NoVisualInfoWidget(
                    message: 'No visual information available\nfor today.',
                    height: imageHeight,
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Placeholder widget shown when no image or model is available.
class _NoVisualInfoWidget extends StatelessWidget {
  final String message;
  final double height;

  const _NoVisualInfoWidget({required this.message, this.height = 300});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off_outlined, size: 58, color: Colors.grey),
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
