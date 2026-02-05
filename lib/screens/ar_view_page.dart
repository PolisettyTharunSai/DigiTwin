import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewPage extends StatelessWidget {
  final String modelPath; // expects HTTPS URL
  final String cropName;

  const ARViewPage({
    super.key,
    required this.modelPath,
    required this.cropName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF1),
      appBar: AppBar(
        title: Text('$cropName AR View'),
        backgroundColor: const Color(0xFFFF9644),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF1),
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
              cameraOrbit: "0deg 75deg 2.5m",
              minCameraOrbit: "auto auto 1m",
              maxCameraOrbit: "auto auto 10m",
              fieldOfView: "30deg",
              exposure: 1,
              shadowIntensity: 1,
              interactionPrompt: InteractionPrompt.none,
              backgroundColor: const Color(0xFFFFFDF1),
            ),
          ),
        ),
      ),
    );
  }
}