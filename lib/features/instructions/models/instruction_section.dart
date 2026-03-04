import 'package:flutter/material.dart';

enum ContentType {
  heading,
  paragraph,
  bullets,
  image,
}

class ContentBlock {
  final ContentType type;
  final String? text;
  final List<String>? bullets;
  final String? assetPath;

  ContentBlock.heading(this.text)
      : type = ContentType.heading,
        bullets = null,
        assetPath = null;

  ContentBlock.paragraph(this.text)
      : type = ContentType.paragraph,
        bullets = null,
        assetPath = null;

  ContentBlock.bullets(this.bullets)
      : type = ContentType.bullets,
        text = null,
        assetPath = null;

  ContentBlock.image(this.assetPath)
      : type = ContentType.image,
        text = null,
        bullets = null;
}

class Section {
  final String title;
  final String description;
  final String thumbnailAsset;
  final List<ContentBlock> content;

  Section({
    required this.title,
    required this.description,
    required this.thumbnailAsset,
    required this.content,
  });
}

final List<Section> sections = [
  Section(
    title: 'Introduction',
    description: 'Get to know about Potato',
    thumbnailAsset: 'assets/images/step1.png',
    content: [],
  ),
  Section(
    title: 'Climate & Soil',
    description: 'Optimal Conditions',
    thumbnailAsset: 'assets/images/step2.png',
    content: [],
  ),
  Section(
    title: 'Seed & Sowing',
    description: 'Prep & Planting',
    thumbnailAsset: 'assets/images/step3.png',
    content: [],
  ),
  Section(
    title: 'Nutrient Management',
    description: 'Best Fertilization',
    thumbnailAsset: 'assets/images/step4.png',
    content: [],
  ),
  Section(
    title: 'Field Care',
    description: 'Protection & Irrigation',
    thumbnailAsset: 'assets/images/step5.png',
    content: [],
  ),
  Section(
    title: 'Harvest & Storage',
    description: 'End of Cycle',
    thumbnailAsset: 'assets/images/step6.png',
    content: [],
  ),
];
