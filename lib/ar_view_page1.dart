import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewPage extends StatelessWidget {
  final String modelPath;
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
        src: 'assets1/models1/Main_model.glb',
        iosSrc: 'assets1/models1/Main_model.glb',
        alt: "$cropName 3D model",
        ar: false,
        autoRotate: true,
        cameraControls: true,
        arModes: const ['scene-viewer', 'webxr', 'quick-look'],
        backgroundColor: Colors.white,
      ),
    );
  }
}
