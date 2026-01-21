import 'package:flutter/material.dart';
import '../models/requirements_model.dart';

Widget buildContentWidget(ContentItem item) {
  switch (item.type) {
    case ContentType.heading:
      return _HeadingBlock(title: item.data);

    case ContentType.paragraph:
      return _ParagraphBlock(text: item.data);

    case ContentType.image:
      return _ImageBlock(pathOrUrl: item.data);

    case ContentType.bullets:
      return _BulletBlock(points: item.bulletPoints ?? []);
  }
}

// ----------------------- HEADING UI -----------------------

class _HeadingBlock extends StatelessWidget {
  final String title;
  const _HeadingBlock({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------- PARAGRAPH UI -----------------------

class _ParagraphBlock extends StatelessWidget {
  final String text;
  const _ParagraphBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    // "Not boring" layout: paragraph in a soft card with left icon strip
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15.5,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------- IMAGE UI -----------------------

class _ImageBlock extends StatelessWidget {
  final String pathOrUrl;
  const _ImageBlock({required this.pathOrUrl});

  bool _isNetwork(String s) {
    return s.startsWith("http://") || s.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: _isNetwork(pathOrUrl)
            ? Image.network(
          pathOrUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _brokenImage(),
        )
            : Image.asset(
          pathOrUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _brokenImage(),
        ),
      ),
    );
  }

  Widget _brokenImage() {
    return Container(
      height: 200,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, size: 44),
      ),
    );
  }
}

// ----------------------- BULLETS UI -----------------------

class _BulletBlock extends StatelessWidget {
  final List<String> points;
  const _BulletBlock({required this.points});

  @override
  Widget build(BuildContext context) {
    // bullet box looks like "routine steps" with icons
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((p) => _bulletRow(p)).toList(),
      ),
    );
  }

  Widget _bulletRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Icon(Icons.check_circle,
                color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.35,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
