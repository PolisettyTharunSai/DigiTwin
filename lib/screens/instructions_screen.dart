import 'package:flutter/material.dart';
import 'section_detail_screen.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);

    path.quadraticBezierTo(
      size.width * 0.05,
      size.height,
      size.width * 0.15,
      size.height,
    );

    path.lineTo(size.width * 0.85, size.height);

    path.quadraticBezierTo(
      size.width * 0.95,
      size.height,
      size.width,
      size.height - 20,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


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
    title: 'Know What You Crop!',
    description: 'Before going to plant understand the wheat crop based on your requirements',
    thumbnailAsset: 'assets/requirements/img1_1.png',
    content: [
      ContentBlock.image('assets/requirements/img1_1.png'),
      ContentBlock.heading('What is Wheat?'),
      ContentBlock.paragraph(
        'Wheat is a Rabi crop grown during winter and harvested in spring. '
            'It is one of the most important cereal crops in India.',
      ),
      ContentBlock.heading('Types of Wheat'),
      ContentBlock.bullets([
        'Bread wheat',
        'Most suited for chapati and bakery',
        'Cultivated throughout India',
        'Common wheat may be sub-divided',
        'Hard red winter wheat – commercial class',
        'Hard red spring wheat – grown where winter is too severe, high protein and excellent bread making characteristics',
        'Soft red winter wheat – grown in humid conditions, grains are soft, low protein, flour suitable for cakes and cookies',
        'White wheat – mainly for pastry purpose',
      ]),
    ],
  ),
  Section(
    title: 'Climatic Requirements',
    description:
    'Wheat growth and development are influenced by temperature, photoperiod, and climate. '
        'The crop shows strong adaptability through hardening, photoperiod response, and temperature tolerance at different growth stages.',
    thumbnailAsset: 'assets/requirements/img2_1.png',
    content: [
      ContentBlock.image('assets/requirements/img2_1.png'),
      ContentBlock.heading('Climate and Cold Hardening'),
      ContentBlock.bullets([
        'Wheat has the ability to undergo hardening after germination',
        'Germination can occur at temperatures just above 4°C',
        'Normal physiological activity begins above 5°C in the presence of adequate sunlight',
      ]),
      ContentBlock.paragraph(
        'After germination, wheat plants develop tolerance to freezing temperatures through the process of hardening.',
      ),
      ContentBlock.bullets([
        'Spring wheat can tolerate freezing temperatures as low as −9.4°C',
        'Winter wheat can tolerate freezing temperatures as low as −31.6°C',
      ]),
      ContentBlock.paragraph(
        'During hardening, there is a gradual increase in dry matter, sugars, amide nitrogen, and amino nitrogen in plant tissues. '
            'These changes enhance protein stability and increase tolerance to freezing stress.',
      ),
      ContentBlock.bullets([
        'Hardened plants have lower moisture content in the leaves',
        'Water is held more tightly within the cells',
      ]),
      ContentBlock.heading('Response to Photoperiod and Growth'),
      ContentBlock.bullets([
        'Wheat is a long-day plant',
        'Long-day conditions hasten flowering',
        'Short-day conditions prolong the vegetative phase',
        'Most modern varieties are photo-insensitive',
      ]),
      ContentBlock.heading('Temperature and Growth'),
      ContentBlock.paragraph(
        'Wheat can tolerate low temperatures during the vegetative stage and higher temperatures along with long days during the reproductive phase.',
      ),
      ContentBlock.bullets([
        'Optimum temperature for overall growth is 20–22°C',
        'Optimum temperature for vegetative growth ranges from 16–22°C',
        'Leaves attain maximum size at around 22°C',
        'Temperatures above 22°C reduce plant height, root length, and tiller number',
      ]),
      ContentBlock.paragraph(
        'Heading is accelerated as temperature increases from 22°C to 34°C but is delayed when temperatures exceed 34°C.',
      ),
      ContentBlock.bullets([
        'During grain development, 25°C for 4–5 weeks is optimum',
        'Temperatures above 25°C reduce grain weight',
      ]),
    ],
  ),
  Section(
    title: 'Growth Stages of Wheat',
    description:
    'In North India, wheat growth progresses through distinct vegetative and reproductive stages. '
        'Each stage occurs at a specific time after sowing and is critical for yield formation.',
    thumbnailAsset: 'assets/requirements/img3_1.png',
    content: [
      ContentBlock.image('assets/requirements/img3_1.png'),
      ContentBlock.heading('Vegetative Stage'),
      ContentBlock.bullets([
        'Germination occurs within 5–7 days after sowing',
        'Crown Root Initiation (CRI) takes place at 20–25 days after sowing (DAS)',
        'Tillering starts around 15 DAS and continues at 4–5 day intervals up to 45 DAS',
        'Jointing stage occurs between 45–60 DAS and represents peak vegetative growth',
      ]),
      ContentBlock.paragraph(
        'The jointing stage is characterized by rapid internode elongation and marks the transition towards reproductive development.',
      ),
      ContentBlock.heading('Reproductive Stage'),
      ContentBlock.bullets([
        'Boot leaf stage appears at 70–75 DAS',
        'Flowering occurs between 85–90 DAS',
        'Milking stage is observed at 100–105 DAS',
        'Dough stage occurs around 105–110 DAS',
        'Physiological maturity is attained between 115–120 DAS',
      ]),
    ],
  ),
  Section(
    title: 'Season and Time of Sowing',
    description:
    'Timely sowing is the most critical factor influencing wheat yield. '
        'Delay in sowing exposes the crop to terminal heat stress and reduces productivity.',
    thumbnailAsset: 'assets/requirements/img4_1.png',
    content: [
      ContentBlock.image('assets/requirements/img4_1.png'),
      ContentBlock.bullets([
        'Time of sowing determines yield potential in wheat',
        'Irrigated long-duration varieties (135–140 days) are sown from 10th to 30th November',
        'Short-duration varieties (120–125 days) can be sown up to 15th December',
        'Sowing after 15th December causes drastic reduction in yield',
        'Slight variation in sowing time exists among agro-climatic zones',
      ]),
    ],
  ),
  Section(
    title: 'Field Preparation for Wheat',
    description:
    'Proper field preparation ensures good soil tilth, seed–soil contact, '
        'and uniform crop establishment.',
    thumbnailAsset: 'assets/requirements/img5_1.png',
    content: [
      ContentBlock.image('assets/requirements/img5_1.png'),
      ContentBlock.bullets([
        'Field preparation is usually done after the harvest of Kharif crops',
        'One disking followed by harrowing is commonly practiced',
        'Moderate to fine tilth is ideal for wheat',
        'Zero tillage is possible, especially after rice harvest',
        'Dibbling in lines is a suitable option under zero tillage',
      ]),
    ],
  ),
  Section(
    title: 'Methods of Sowing in Wheat',
    description:
    'Different sowing methods are adopted based on soil conditions, '
        'availability of machinery, and irrigation practices.',
    thumbnailAsset: 'assets/requirements/img6_1.png',
    content: [
      ContentBlock.image('assets/requirements/img6_1.png'),
      ContentBlock.bullets([
        'Broadcasting',
        'Zero / No-tillage sowing',
        'Sowing behind the plough',
        'Drilling',
        'Dibbling',
        'FIRB – Furrow Irrigated Raised Bed system',
      ]),
    ],
  ),
  Section(
    title: 'Seed Rate and Spacing',
    description:
    'Optimum seed rate and spacing ensure proper plant population, '
        'better tillering, and efficient use of nutrients and water.',
    thumbnailAsset: 'assets/requirements/img7_1.png',
    content: [
      ContentBlock.image('assets/requirements/img7_1.png'),
      ContentBlock.bullets([
        'Recommended seed rate is 100–125 kg per hectare',
        'Seed rate should be increased by 25% under late sowing or low soil moisture',
        'Broadcast sowing requires about 150 kg seed per hectare',
        'For dibbling, 25–30 kg seed per hectare is sufficient',
        'Tillering varieties require wider spacing',
        'Irrigated wheat: 22.5 cm row spacing and 8–18 cm plant spacing',
        'Rainfed wheat: 25–30 cm × 5–6 cm spacing',
        'Late-sown wheat requires closer spacing of 15–16 cm',
      ]),
    ],
  ),
  Section(
    title: 'Nutrient Management',
    description:
    'Balanced application of macro and micronutrients is essential '
        'for achieving higher yield and better grain quality in wheat.',
    thumbnailAsset: 'assets/requirements/img8_1.png',
    content: [
      ContentBlock.image('assets/requirements/img8_1.png'),
      ContentBlock.bullets([
        'Nitrogen deficiency causes poor tillering and small ear heads',
        'Recommended nitrogen dose is 120–150 kg/ha for irrigated and 40–60 kg/ha for rainfed wheat',
        'Nitrogen is applied in 2–3 splits depending on soil type',
        'Phosphorus is a critical nutrient, especially for dwarf varieties',
        'Recommended phosphorus dose is 60 kg P₂O₅ per hectare as basal',
        'Potassium requirement is generally low in Indo-Gangetic alluvial soils',
        'Micronutrients like zinc are deficient in many wheat-growing soils',
        'Recommended zinc application is 25 kg ZnSO₄ per hectare',
        'Integrated nutrient management includes FYM, green manuring, and biofertilizers',
      ]),
    ],
  ),
  Section(
    title: 'Irrigation Management in Wheat',
    description:
    'Wheat is highly responsive to irrigation, and timely water application '
        'at critical growth stages ensures maximum yield.',
    thumbnailAsset: 'assets/requirements/img9_1.png',
    content: [
      ContentBlock.image('assets/requirements/img9_1.png'),
      ContentBlock.bullets([
        'Wheat requires 4–6 irrigations during the growing season',
        'Irrigation is scheduled at 40–50% depletion of available soil moisture',
        'IW:CPE ratio of 0.7–0.9 is suitable for wheat',
        'CRI stage (20–25 DAS) is the most critical irrigation stage',
        'Flowering is the second most critical stage',
        'Jointing and milking stages are also important',
      ]),
    ],
  ),
  Section(
    title: 'Weed Management in Wheat',
    description:
    'Weeds are severe competitors for nutrients, water, and light '
        'and must be controlled during the early stages of crop growth.',
    thumbnailAsset: 'assets/requirements/img10_1.png',
    content: [
      ContentBlock.image('assets/requirements/img10_1.png'),
      ContentBlock.bullets([
        'Weeds should be controlled at early stages of crop growth',
        'Major monocot weeds include Phalaris minor and Avena fatua',
        'Hand weeding is recommended at 20–25 DAS and again after two weeks',
        'Dicot weeds are controlled using 2,4-D at 0.3–0.4 kg/ha',
        'Monocot weeds are controlled using Isoproturon or Metoxuron',
        'Pre-emergence application of Pendimethalin provides broad-spectrum control',
      ]),
    ],
  ),
  Section(
    title: 'Harvesting and Threshing of Wheat',
    description:
    'Harvesting at the right stage ensures better grain quality, '
        'reduced losses, and efficient threshing.',
    thumbnailAsset: 'assets/requirements/img11_1.png',
    content: [
      ContentBlock.image('assets/requirements/img11_1.png'),
      ContentBlock.bullets([
        'Yellow and dry straw indicates crop maturity',
        'Over-maturity causes shredding and breaking of spikes',
        'Ideal harvesting stage is at 20–25% grain moisture',
        'Combine harvester is the most efficient method',
        'Manual harvesting or reapers are also used',
        'Harvested crop is dried for 3–4 days before threshing',
      ]),
    ],
  )
];

// ... (imports and data classes remain the same)

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color.fromARGB(255, 127, 61, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
// ---------- HEADER WITH CURVE ----------
          ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 10,
                right: 10,
                bottom: 18,
              ),
              width: double.infinity,
              color: primaryPurple,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- STACKED CARDS ----------
          Expanded(
            child: Container(
              color: const Color(0xFFF5F0FF), // same family as card color
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  for (int i = 0; i < sections.length; i++)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SectionCardDelegate(
                        section: sections[i],
                        index: i,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SectionDetailScreen(sectionIndex: i),
                            ),
                          );
                        },
                      ),
                    ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCardDelegate extends SliverPersistentHeaderDelegate {
  final Section section;
  final int index;
  final VoidCallback onTap;

  final double _maxExtent = 145.0;
  final double _minExtent = 0.0;

  _SectionCardDelegate({
    required this.section,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _maxExtent,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        section.thumbnailAsset,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFFFB3B3),
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            section.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _SectionCardDelegate oldDelegate) {
    return oldDelegate.section != section;
  }
}