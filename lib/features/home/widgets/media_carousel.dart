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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    img,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _NoVisualInfoWidget(
                        message:
                            'No visual information available\nfor today.\n\nURL: $img',
                        height: imageHeight,
                      );
                    },
                  ),
                  // Overlay to display the image URL for verification
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.black54,
                      child: Text(
                        img,
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
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
