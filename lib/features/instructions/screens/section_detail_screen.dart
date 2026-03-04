import 'package:flutter/material.dart';

import '../models/instruction_section.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(size.width * 0.05, size.height, size.width * 0.15, size.height);
    path.lineTo(size.width * 0.85, size.height);
    path.quadraticBezierTo(size.width * 0.95, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SectionDetailScreen extends StatelessWidget {
  final int sectionIndex;

  const SectionDetailScreen({super.key, required this.sectionIndex});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9644);
    final section = sections[sectionIndex];
    final nextSectionIndex =
        sectionIndex + 1 < sections.length ? sectionIndex + 1 : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 18),
              width: double.infinity,
              color: primaryOrange,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      section.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...section.content.map((block) {
                      switch (block.type) {
                        case ContentType.heading:
                          return Padding(
                            padding: const EdgeInsets.only(top: 25, bottom: 12),
                            child: Text(block.text ?? '', softWrap: true,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                          );
                        case ContentType.paragraph:
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text(block.text ?? '', style: const TextStyle(fontSize: 16, height: 1.4)),
                          );
                        case ContentType.bullets:
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (block.bullets ?? []).map((point) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    Expanded(child: Text(point, softWrap: true, style: const TextStyle(fontSize: 16))),
                                  ],
                                ),
                              )).toList(),
                            ),
                          );
                        case ContentType.image:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                block.assetPath ?? 'assets/requirements/image11.png',
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: double.infinity,
                                  height: 250,
                                  color: const Color(0xFFFFB3B3),
                                  child: const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.white)),
                                ),
                              ),
                            ),
                          );
                      }
                    }).toList(),
                    const SizedBox(height: 30),
                    if (nextSectionIndex != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SectionDetailScreen(sectionIndex: nextSectionIndex),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(sections[nextSectionIndex].title.toLowerCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 14),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
