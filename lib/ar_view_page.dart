import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewPage extends StatelessWidget {
  final String modelPath; //  now expects an HTTPS URL
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
      body: ModelViewer(
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

    );
  }
}
