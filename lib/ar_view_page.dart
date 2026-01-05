import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ARViewPage extends StatefulWidget {
  final String modelPath;
  final String cropName;

  const ARViewPage({
    super.key,
    required this.modelPath,
    required this.cropName,
  });

  @override
  State<ARViewPage> createState() => _ARViewPageState();
}

class _ARViewPageState extends State<ARViewPage> {
  final Flutter3DController _controller = Flutter3DController();
  String? _chosenAnimation;

  bool get isObj => widget.modelPath.toLowerCase().endsWith('.obj');
  bool get isGlb => widget.modelPath.toLowerCase().endsWith('.glb');

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      debugPrint('Model loaded: ${_controller.onModelLoaded.value}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cropName} 3D View'),
        backgroundColor: Colors.green.shade700,
      ),

      floatingActionButton: isGlb
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _controller.playAnimation(),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () {
              _controller.pauseAnimation();
              _controller.pauseRotation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              _controller.resetAnimation();
              _controller.stopRotation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.threed_rotation),
            onPressed: () =>
                _controller.startRotation(rotationSpeed: 25),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _controller.resetCameraOrbit(),
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: _pickAnimation,
          ),
        ],
      )
          : null,

      body: isObj
          ? Flutter3DViewer.obj(
        src: widget.modelPath,
        scale: 5,
        cameraZ: 10,
        onLoad: (s) => debugPrint('OBJ loaded: $s'),
        onError: (e) => debugPrint('OBJ error: $e'),
      )
          : isGlb
          ? Flutter3DViewer(
        src: widget.modelPath,
        controller: _controller,
        activeGestureInterceptor: true,
        enableTouch: true,
        progressBarColor: Colors.green,
        onLoad: (s) {
          debugPrint('GLB loaded: $s');
          _controller.playAnimation();
        },
        onError: (e) => debugPrint('GLB error: $e'),
      )
          : ModelViewer(
        src: widget.modelPath,
        iosSrc: widget.modelPath,
        ar: true,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> _pickAnimation() async {
    final animations = await _controller.getAvailableAnimations();
    if (animations.isEmpty) return;

    _chosenAnimation = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: animations
            .map(
              (a) => ListTile(
            title: Text(a),
            onTap: () => Navigator.pop(context, a),
          ),
        )
            .toList(),
      ),
    );

    if (_chosenAnimation != null) {
      _controller.playAnimation(
        animationName: _chosenAnimation,
        loopCount: 0,
      );
    }
  }
}
