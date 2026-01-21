import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const primaryColor = Color(0xFF7F3DFF);

  late AnimationController _moveController;
  late AnimationController _expandController;
  late AnimationController _iconFadeController;
  late AnimationController _textMoveController;

  late Animation<Alignment> _positionAnim;
  late Animation<double> _ballSizeAnim;
  late Animation<double> _expandSizeAnim;
  late Animation<double> _iconFadeAnim;
  late Animation<double> _textTranslateAnim;

  bool expanding = false;
  bool showIcon = false;
  bool showText = false;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconFadeAnim = CurvedAnimation(
      parent: _iconFadeController,
      curve: Curves.easeIn,
    );

    _positionAnim =
        TweenSequence<Alignment>([
          TweenSequenceItem(
            tween: AlignmentTween(
              begin: Alignment.topRight,
              end: Alignment.centerLeft,
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: AlignmentTween(
              begin: Alignment.centerLeft,
              end: Alignment.bottomCenter,
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: AlignmentTween(
              begin: Alignment.bottomCenter,
              end: Alignment.centerRight,
            ),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: AlignmentTween(
              begin: Alignment.centerRight,
              end: Alignment.center,
            ),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
        );

    _ballSizeAnim = Tween<double>(
      begin: 24,
      end: 120,
    ).animate(CurvedAnimation(parent: _moveController, curve: Curves.linear));

    _start();
  }

  void _start() {
    /// 🔹 MOVE → IMMEDIATELY EXPAND + ICON FADE
    _moveController.forward().then((_) {
      if (!mounted) return;

      setState(() {
        expanding = true;
        showIcon = true;
      });

      _expandController.forward();
      _iconFadeController.forward();

      /// TEXT COMES SHORTLY AFTER
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() => showText = true);
        _textMoveController.forward();
      });

      /// NAVIGATION
      Future.delayed(const Duration(milliseconds: 1800), _navigate);
    });
  }

  void _navigate() {
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        session != null ? const HomeScreen() : const GetStartedScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    _expandController.dispose();
    _iconFadeController.dispose();
    _textMoveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// 🟣 FINAL CIRCLE SIZE (SAFE WHITE SPACE)
    final maxCircleDiameter = size.width * 0.88;

    _expandSizeAnim =
        Tween<double>(
          begin: _ballSizeAnim.value,
          end: maxCircleDiameter,
        ).animate(
          CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
        );

    /// ⬆️ TEXT FROM BOTTOM OF PHONE
    _textTranslateAnim = Tween<double>(begin: size.height / 2, end: 0).animate(
      CurvedAnimation(parent: _textMoveController, curve: Curves.linear),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _moveController,
              _expandController,
              _iconFadeController,
              _textMoveController,
            ]),
            builder: (_, __) {
              final ballSize = expanding
                  ? _expandSizeAnim.value
                  : _ballSizeAnim.value;

              return Align(
                alignment: expanding ? Alignment.center : _positionAnim.value,
                child: Container(
                  width: ballSize,
                  height: ballSize,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// 🚜 ICON (IMMEDIATE FADE-IN)
                        if (showIcon)
                          FadeTransition(
                            opacity: _iconFadeAnim,
                            child: const Icon(
                              Icons.agriculture,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),

                        /// 📝 TEXT
                        if (showText)
                          Transform.translate(
                            offset: Offset(0, _textTranslateAnim.value),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 170),
                              child: Text(
                                "Digital Twin",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}