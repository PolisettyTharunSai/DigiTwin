import 'package:flutter/material.dart';
import '../widgets/wheat_card.dart';

class Section2Climate extends StatelessWidget {
  const Section2Climate({super.key});

  @override
  Widget build(BuildContext context) {
    return const WheatCard(
      title: "2️⃣ Climate, Hardening & Photoperiod Response",
      content: """
Climate Requirements:
• Hardening ability after germination
• Germinates just above 4°C

Freezing tolerance:
• Spring wheat: –9.4°C
• Winter wheat: –31.6°C

Normal growth starts above 5°C with sunlight

Hardening Process:
• Increase in dry matter, sugars, amide & amino nitrogen
• Tolerance to freezing
• Reduced leaf moisture
• Tightly bound cellular water

Photoperiod Response:
• Long-day plant
• Long day → early flowering
• Short day → prolonged vegetative growth
• Modern varieties are photo-insensitive
""",
    );
  }
}
