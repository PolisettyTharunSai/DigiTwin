import 'package:flutter/material.dart';
import '../models/requirements_model.dart';
import '../widgets/content_widgets.dart';
import 'enter_details_page.dart';

class RequirementsPage extends StatefulWidget {
  const RequirementsPage({super.key});

  @override
  State<RequirementsPage> createState() => _RequirementsPageState();
}

class _RequirementsPageState extends State<RequirementsPage> {
  int currentIndex = 0;

  late final List<RequirementPageData> pages = [
    // ---------------- PAGE 1 (INTRO) ----------------
    RequirementPageData(
      title: "Introduction",
      items: [
        ContentItem.image("assets/requirements/image11.png"),

        ContentItem.heading("Why Wheat is Important"),
        ContentItem.paragraph(
          "Wheat is one of the most widely cultivated cereal crops and is a major "
              "source of food energy. It plays an important role in daily diets, especially "
              "in India and many other countries.\n\n"
              "In this section, you will learn the crop requirements and optimal conditions "
              "for planting wheat. Tap Next to continue.",
        ),

        ContentItem.heading("Common Wheat (Triticum aestivum)"),
        ContentItem.paragraph(
          "Common wheat is the most widely grown wheat type. It is mainly used for "
              "chapati, bread, and bakery products.",
        ),

        ContentItem.heading("Types / Subdivision"),
        ContentItem.bullets([
          "Hard red winter wheat – commercial class",
          "Hard red spring – suitable where winter is severe, high protein, excellent bread quality",
          "Soft red winter – humid conditions, low protein, flour suitable for cakes and cookies",
          "White wheat – mainly used for pasta purpose",
        ]),

        ContentItem.paragraph(
          "Now that you know the basics, the next pages cover the real growing requirements "
              "like climate and soil.",
        ),
      ],
    ),

    // ---------------- PAGE 2 (CLIMATE) ----------------
    RequirementPageData(
      title: "Optimal Climate",
      items: [
        ContentItem.heading("Climate Requirement"),
        ContentItem.paragraph(
          "Wheat is generally a cool season crop. It grows best under cool and dry conditions. "
              "Extremely hot or very humid conditions can reduce yield and grain quality.",
        ),
        ContentItem.image("assets/requirements/image11.png"),

        ContentItem.heading("Ideal Temperature"),
        ContentItem.bullets([
          "Cool weather during vegetative growth is beneficial",
          "Moderate temperature during flowering helps grain formation",
          "Very high temperature during grain filling may reduce grain size",
        ]),

        ContentItem.heading("Best Season"),
        ContentItem.paragraph(
          "In many parts of India, wheat is grown as a Rabi crop. Sowing at the right time "
              "helps avoid heat stress during the later stages.",
        ),
      ],
    ),

    // ---------------- PAGE 3 (SOIL) ----------------
    RequirementPageData(
      title: "Soil Requirement",
      items: [
        ContentItem.heading("Soil"),
        ContentItem.paragraph(
          "Wheat grows best in well-drained soils with good structure. Soil should have "
              "moderate water holding capacity so that the crop gets enough moisture without "
              "becoming waterlogged.",
        ),

        ContentItem.heading("Suitable Soil Types"),
        ContentItem.bullets([
          "Loam soil",
          "Clay loam soil",
          "Well-drained heavy soils (if drainage is good)",
        ]),

        ContentItem.heading("Soil Tips"),
        ContentItem.paragraph(
          "Avoid soils that stay waterlogged for long periods. Proper drainage is important "
              "to prevent root diseases.",
        ),
        ContentItem.image("assets/requirements/image11.png"),
      ],
    ),

    // ---------------- PAGE 4 (WATER + NUTRITION) ----------------
    RequirementPageData(
      title: "Water & Nutrition",
      items: [
        ContentItem.heading("Watering (Irrigation)"),
        ContentItem.paragraph(
          "Provide irrigation at critical stages. Proper irrigation scheduling improves yield "
              "and keeps the crop healthy.",
        ),
        ContentItem.bullets([
          "Crown Root Initiation (CRI) stage is very important",
          "Tillering stage",
          "Flowering stage",
          "Grain filling stage",
        ]),

        ContentItem.heading("Nutrition (Fertilizer)"),
        ContentItem.paragraph(
          "Balanced nutrients help the crop achieve good tillers, better grain development and yield. "
              "Nitrogen is especially important for wheat growth.",
        ),
        ContentItem.bullets([
          "Use recommended NPK based on soil test",
          "Apply basal dose during land preparation",
          "Split nitrogen dose if needed (to reduce losses)",
        ]),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = pages[currentIndex];
    final isLast = currentIndex == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          page.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentIndex == 0) {
              Navigator.pop(context);
            } else {
              setState(() => currentIndex--);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EnterDetailsPage()),
              );
            },
            child: const Text(
              "Test",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ✅ Add a nice top mini progress bar like "Day 35" style
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Icon(Icons.menu_book,
                      color: Colors.green.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Requirements Page ${currentIndex + 1}/${pages.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: (currentIndex + 1) / pages.length,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade700),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                page.items.map((item) => buildContentWidget(item)).toList(),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: isLast
          ? null
          : FloatingActionButton.extended(
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.arrow_forward),
        label: const Text("Next"),
        onPressed: () {
          setState(() => currentIndex++);
        },
      ),
    );
  }
}
