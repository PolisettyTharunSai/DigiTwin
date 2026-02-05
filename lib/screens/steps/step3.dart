import 'package:flutter/material.dart';
import 'step3_translations.dart'; // Import added

class Step3Content extends StatelessWidget {
  final String locale; // Added locale parameter

  const Step3Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);

  // Helper method to fetch translated strings
  String _t(String key) {
    return Step3Translations.getContent(locale)[key] ??
        Step3Translations.getContent('en')[key] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TOP HERO IMAGE ---
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step3.png',
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

        // --- 3.1 VARIETIES ---
        _buildSubHeading(_t('varieties_heading')),
        _buildVarietyCategory(_t('early_title'), _t('early_val'), Colors.green),
        _buildVarietyCategory(_t('main_title'), _t('main_val'), Colors.orange),
        _buildVarietyCategory(_t('proc_title'), _t('proc_val'), Colors.blue),

        const SizedBox(height: 25),

        // --- 3.2 SEED SELECTION & CUTTING ---
        _buildSubHeading(_t('seed_selection_heading')),
        _buildRequirementBox(
          title: _t('ideal_seed_title'),
          desc: _t('ideal_seed_desc'),
          icon: Icons.spa_outlined,
          color: Colors.brown,
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          _t('seed_cut_title'),
          _t('seed_cut_desc'),
          Icons.content_cut,
          Colors.redAccent,
        ),

        const SizedBox(height: 25),

        // --- 3.4 DORMANCY & CHITTING ---
        _buildSubHeading(_t('seed_prep_heading')),

        _buildFeatureCard(
          _t('dormancy_title'),
          _t('dormancy_desc'),
          Icons.wb_sunny_outlined,
          Colors.amber,
        ),
        _buildFeatureCard(
          _t('chitting_title'),
          _t('chitting_desc'),
          Icons.eco_outlined,
          Colors.green,
        ),

        const SizedBox(height: 25),

        // --- 3.6 SPACING & PLACEMENT ---
        _buildSubHeading(_t('spacing_heading')),

        _buildSpacingTable(),
        const SizedBox(height: 12),
        _buildRequirementBox(
          title: _t('fert_place_title'),
          desc: _t('fert_place_desc'),
          icon: Icons.layers_outlined,
          color: Colors.deepOrange,
        ),
        const SizedBox(height: 10),
        _buildWarningBox(_t('seed_burn_warning')),

        const SizedBox(height: 25),

        // --- 3.7 METHODS ---
        _buildSubHeading(_t('planting_methods_heading')),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                _t('ridge_title'),
                _t('ridge_desc'),
                Icons.agriculture,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                _t('mech_title'),
                _t('mech_desc'),
                Icons.precision_manufacturing,
                Colors.indigo,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // --- NEW REDESIGNED QUICK SUMMARY ---
        _buildModernSummary(),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildModernSummary() {
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
          _buildCheckItem(_t('check_5')),
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

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryPurple,
              ),
            ),
          ),
        ],
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

  Widget _buildVarietyCategory(String title, String varieties, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            varieties,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade100),
          ),
          children: [
            _buildTableRow(_t('row_to_row'), _t('row_to_row_val')),
            _buildTableRow(_t('plant_to_plant'), _t('plant_to_plant_val')),
            _buildTableRow(_t('depth'), _t('depth_val')),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accentGreen,
            ),
          ),
        ),
      ],
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

  Widget _buildMiniCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
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

  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.amber.shade900,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
