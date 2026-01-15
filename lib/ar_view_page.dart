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
      appBar: AppBar(
        title: Text('$cropName AR View'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              ar: true,
              arModes: const ['scene-viewer'],
              arPlacement: ArPlacement.floor,
              arScale: ArScale.auto,
              cameraControls: true,
              autoRotate: false,
              backgroundColor: Colors.white,
              alt: '$cropName AR model',
            ),
          ),
        ),
      ),
    );
  }
}
