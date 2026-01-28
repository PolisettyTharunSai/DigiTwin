import 'package:flutter/material.dart';

class WheatCard extends StatelessWidget {
  final String title;
  final String content;

  const WheatCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    /// 🔒 FIXED CARD SIZE (SAME FOR ALL CARDS)
    final double cardWidth = screenSize.width * 0.88;
    final double cardHeight = screenSize.height * 0.62;

    return Center(
      child: Material(
        elevation: 10,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white, // ✅ CARD BACKGROUND = WHITE
            borderRadius: BorderRadius.circular(26),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🟣 TITLE (NON-SCROLLING)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7F3DFF),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              /// 🔽 INTERNAL SCROLL — NO SCROLLBAR, NO GLOW
              Expanded(
                child: ScrollConfiguration(
                  behavior: const _NoScrollbarBehavior(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🚫 DISABLE SCROLLBAR & OVERSCROLL INDICATOR COMPLETELY
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}