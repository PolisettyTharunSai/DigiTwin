import 'package:flutter/material.dart';
import 'step4_translations.dart'; // Import added

class Step4Content extends StatelessWidget {
  final String locale; // Added locale parameter

  const Step4Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);

  // Helper method to fetch translated strings
  String _t(String key) {
    // 1. Clean the locale string (extract 'hi' from 'hi_IN')
    final String cleanCode = locale.split(RegExp('[-_]'))[0].toLowerCase();

    // 2. Fetch the data map for that code
    final Map<String, String> translationMap = Step4Translations.getContent(cleanCode);

    // 3. Return the key or fallback to English
    return translationMap[key] ?? Step4Translations.getContent('en')[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TOP VISUAL REFERENCE ---
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step4.png',
              height: imageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: imageHeight,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // --- SECTION HEADER ---
        _buildHeader(_t('header_title')),
        const SizedBox(height: 20),

        _buildInfoCard(_t('soil_test_info'), icon: Icons.science_outlined),

        const SizedBox(height: 25),

        // --- 4.2 ROLE OF NUTRIENTS ---
        _buildSubHeading(_t('major_nutrients_heading')),
        _buildFeatureCard(
          _t('nitrogen_title'),
          _t('nitrogen_desc'),
          Icons.energy_savings_leaf_outlined,
          Colors.green,
        ),
        _buildFeatureCard(
          _t('phosphorus_title'),
          _t('phosphorus_desc'),
          Icons.straighten_outlined,
          Colors.orange,
        ),
        _buildFeatureCard(
          _t('potassium_title'),
          _t('potassium_desc'),
          Icons.verified_user_outlined,
          Colors.blue,
        ),

        const SizedBox(height: 25),

        // --- 4.3 APPLICATION METHOD ---
        _buildSubHeading(_t('timeline_heading')),
        _buildRequirementBox(
          title: _t('basal_app_title'),
          desc: _t('basal_app_desc'),
          icon: Icons.timer_outlined,
          color: primaryPurple,
        ),
        const SizedBox(height: 10),
        _buildRequirementBox(
          title: _t('top_dressing_title'),
          desc: _t('top_dressing_desc'),
          icon: Icons.shutter_speed_outlined,
          color: accentGreen,
        ),

        const SizedBox(height: 25),

        // --- 4.5 DEFICIENCY SYMPTOMS ---
        _buildSubHeading(_t('deficiency_heading')),

        _buildDeficiencyCard(_t('def_n_title'), _t('def_n_desc'), Colors.amber),
        _buildDeficiencyCard(
          _t('def_p_title'),
          _t('def_p_desc'),
          Colors.deepPurpleAccent,
        ),
        _buildDeficiencyCard(
          _t('def_k_title'),
          _t('def_k_desc'),
          Colors.orangeAccent,
        ),
        _buildDeficiencyCard(_t('def_b_title'), _t('def_b_desc'), Colors.brown),

        const SizedBox(height: 25),

        // --- 4.6 STAGE-WISE FOCUS ---
        _buildSubHeading(_t('stage_focus_heading')),
        _buildStageList(),

        const SizedBox(height: 30),

        // --- QUICK SUMMARY (CHECKLIST) ---
        _buildChecklistSummary(),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryPurple,
        ),
      ),
    );
  }

  Widget _buildSubHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDeficiencyCard(String title, String symptom, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: "$title: ",
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            TextSpan(text: symptom),
          ],
        ),
      ),
    );
  }

  Widget _buildStageList() {
    final stages = [
      {"stage": _t('stage_germ'), "focus": _t('focus_p')},
      {"stage": _t('stage_veg'), "focus": _t('focus_n')},
      {"stage": _t('stage_init'), "focus": _t('focus_nk')},
      {"stage": _t('stage_bulk'), "focus": _t('focus_k')},
    ];

    return Column(
      children: stages
          .map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s['stage']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    s['focus']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChecklistSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('checklist_title'),
            style: const TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          _buildCheckItem(_t('check_1')),
          _buildCheckItem(_t('check_2')),
          _buildCheckItem(_t('check_3')),
          _buildCheckItem(_t('check_4')),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementBox({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
