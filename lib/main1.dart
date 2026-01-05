import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('3D Model Viewer')),
        body: const Center(
          child: ModelViewer(
            src: 'assets/models/Main_model.glb',
            alt: 'A 3D model',
            ar: false,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
