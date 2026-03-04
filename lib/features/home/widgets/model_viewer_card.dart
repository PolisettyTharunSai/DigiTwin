import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../core/constants/app_colors.dart';

/// Card that embeds the ModelViewer for 3D crop models.
/// Includes a fullscreen button that navigates to [ARViewPage].
class ModelViewerCard extends StatelessWidget {
  final String modelUrl;
  final int currentDay;
  final VoidCallback onFullscreenTap;

  const ModelViewerCard({
    super.key,
    required this.modelUrl,
    required this.currentDay,
    required this.onFullscreenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            children: [
              ModelViewer(
                key: ValueKey(modelUrl),
                src: modelUrl,
                alt: '3D model for Day $currentDay',
                ar: true,
                arModes: const ['scene-viewer', 'webxr-ar-only', 'quick-look'],
                cameraControls: true,
                autoRotate: true,
                backgroundColor: Colors.white,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppColors.primary),
                  onPressed: onFullscreenTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
