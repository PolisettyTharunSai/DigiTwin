import 'package:flutter/material.dart';

void main() {
  runApp(const WheatApp());
}

class WheatApp extends StatelessWidget {
  const WheatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wheat Planting Guide',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Section {
  final String title;
  final String description;
  final String longDescription;
  final List<String> bulletPoints;

  Section({
    required this.title,
    required this.description,
    required this.longDescription,
    required this.bulletPoints,
  });
}

final List<Section> sections = [
  Section(
    title: 'Section1',
    description: 'This is a small description about this page contents',
    longDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis .',
    bulletPoints: ['first point', 'second point', 'third point', 'fourth point'],
  ),
  Section(
    title: 'Section2',
    description: 'This is a small description about this page contents',
    longDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis .',
    bulletPoints: ['first point', 'second point', 'third point', 'fourth point'],
  ),
  Section(
    title: 'Section3',
    description: 'This is a small description about this page contents',
    longDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis .',
    bulletPoints: ['first point', 'second point', 'third point', 'fourth point'],
  ),
  Section(
    title: 'Section4',
    description: 'This is a small description about this page contents',
    longDescription:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis .',
    bulletPoints: ['first point', 'second point', 'third point', 'fourth point'],
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InstructionsScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Wheat Planting App\nClick the (i) button for instructions', textAlign: TextAlign.center),
      ),
    );
  }
}

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, left: 10, bottom: 10),
            width: double.infinity,
            color: const Color(0xFFC5B4E3), // Light purple
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Instructions',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Things to know before\nplanting wheat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SectionDetailScreen(sectionIndex: index),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB3B3), // Pinkish color from mockup
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                                child: Text('Image 1',
                                    style: TextStyle(fontSize: 10))),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Heading of section',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  section.description,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(height: 5),
                                const Text('----------------', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SectionDetailScreen extends StatelessWidget {
  final int sectionIndex;

  const SectionDetailScreen({super.key, required this.sectionIndex});

  @override
  Widget build(BuildContext context) {
    final section = sections[sectionIndex];
    final nextSectionIndex =
        sectionIndex + 1 < sections.length ? sectionIndex + 1 : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, left: 10, bottom: 10),
              width: double.infinity,
              color: const Color(0xFFC5B4E3),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    section.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB3B3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        'image',
                        style: TextStyle(fontSize: 60, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Subheading',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      section.longDescription,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Subheading',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: section.bulletPoints
                          .map((point) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (nextSectionIndex != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SectionDetailScreen(sectionIndex: nextSectionIndex),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5B4E3),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${sections[nextSectionIndex].title.toLowerCase()} name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
