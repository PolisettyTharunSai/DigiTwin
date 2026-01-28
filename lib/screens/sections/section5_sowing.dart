import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section5Sowing extends StatelessWidget {
  const Section5Sowing({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "5️⃣ Sowing Time, Field Preparation & Establishment",
      content: """
Sowing Time:
• Long duration (135–140 days): Nov 10–30
• Short duration (120–125 days): up to Dec 15
• After Dec 15 → drastic yield loss

Field Preparation:
• Disking + harrowing
• Moderate to fine tilth
• Zero tillage possible
• Dibbling after rice

Methods:
• Broadcasting
• Zero tillage
• Drilling
• Dibbling
• FIRB system
""",
    );
  }
}
