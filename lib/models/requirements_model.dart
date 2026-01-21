import 'package:flutter/material.dart';

enum ContentType { heading, paragraph, image, bullets }

class ContentItem {
  final ContentType type;

  // for heading/paragraph/image
  final String data;

  // for bullet list
  final List<String>? bulletPoints;

  final TextStyle? style;

  // ✅ Heading
  ContentItem.heading(this.data, {this.style})
      : type = ContentType.heading,
        bulletPoints = null;

  // ✅ Paragraph
  ContentItem.paragraph(this.data, {this.style})
      : type = ContentType.paragraph,
        bulletPoints = null;

  // ✅ Image
  ContentItem.image(this.data)
      : type = ContentType.image,
        bulletPoints = null,
        style = null;

  // ✅ Bullets
  ContentItem.bullets(this.bulletPoints)
      : type = ContentType.bullets,
        data = "",
        style = null;
}

class RequirementPageData {
  final String title;
  final List<ContentItem> items;

  RequirementPageData({required this.title, required this.items});
}
