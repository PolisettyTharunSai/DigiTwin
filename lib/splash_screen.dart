import 'dart:async';
import 'package:flutter/material.dart';
import 'navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NavigationWrapper(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF022C22),
              Color(0xFF166534),
              Color(0xFFBBF7D0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              top: -80,
              left: -40,
              child: _blurCircle(160, Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              bottom: -60,
              right: -30,
              child: _blurCircle(200, Colors.white.withOpacity(0.12)),
            ),

            // Center logo + text
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _logoCircle(),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _fade,
                      child: const Column(
                        children: [
                          Text(
                            ' Di Twin ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Smart Farming Assistant',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom loading
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      minHeight: 3,
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Preparing your Farm...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoCircle() {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 18),
            blurRadius: 40,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/image.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
