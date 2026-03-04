import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../core/constants/app_colors.dart';

/// Full-screen AR view for a 3D model using model_viewer_plus.
/// Navigated to from the [ModelViewerCard] fullscreen button.
class ArViewScreen extends StatelessWidget {
  /// HTTPS URL pointing to the .glb model file.
  final String modelPath;

  /// Display name for the crop/day (shown in the AppBar).
  final String cropName;

  const ArViewScreen({
    super.key,
    required this.modelPath,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$cropName AR View'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ModelViewer(
              src: modelPath,
              alt: '$cropName AR model',
              ar: true,
              arModes: const ['scene-viewer'],
              arPlacement: ArPlacement.floor,
              arScale: ArScale.auto,
              cameraControls: true,
              autoRotate: false,
              cameraOrbit: '0deg 75deg 2.5m',
              minCameraOrbit: 'auto auto 1m',
              maxCameraOrbit: 'auto auto 10m',
              fieldOfView: '30deg',
              exposure: 1,
              shadowIntensity: 1,
              interactionPrompt: InteractionPrompt.none,
              backgroundColor: AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
