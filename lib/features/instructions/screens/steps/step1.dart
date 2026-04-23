import 'package:flutter/material.dart';
import 'step1_translations.dart'; // Ensure this file name matches

class Step1Content extends StatelessWidget {
  final String locale;

  const Step1Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);

  // Helper method to fetch translations
  String _t(String key) {
    // 1. Clean the locale string (extract 'hi' from 'hi_IN')
    final String cleanCode = locale.split(RegExp('[-_]'))[0].toLowerCase();

    // 2. Fetch the data map for that code
    final Map<String, String> translationMap = Step1Translations.getContent(cleanCode);

    // 3. Return the key or fallback to English
    return translationMap[key] ?? Step1Translations.getContent('en')[key] ?? '';
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
              'assets/images/step1.png',
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

        // --- MAIN SECTION HEADER ---
        _buildHeader(_t('main_header')),
        const SizedBox(height: 20),

        // --- INTRODUCTION ---
        _buildSubHeading(_t('intro_title')),
        _buildInfoCard(_t('intro_body'), icon: Icons.info_outline),

        const SizedBox(height: 20),
        Text(
          _t('why_farmers_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
          ),
        ),
        const SizedBox(height: 12),

        _buildFeatureCard(
          _t('feat_duration_title'),
          _t('feat_duration_sub'),
          Icons.timer,
          Colors.orange,
        ),
        _buildFeatureCard(
          _t('feat_demand_title'),
          _t('feat_demand_sub'),
          Icons.trending_up,
          Colors.blue,
        ),
        _buildFeatureCard(
          _t('feat_adapt_title'),
          _t('feat_adapt_sub'),
          Icons.wb_sunny_outlined,
          Colors.green,
        ),
        _buildFeatureCard(
          _t('feat_income_title'),
          _t('feat_income_sub'),
          Icons.payments_outlined,
          Colors.teal,
        ),

        const SizedBox(height: 15),
        _buildWarningBox(_t('warning_text')),

        const SizedBox(height: 25),

        // --- ORIGIN ---
        _buildSubHeading(_t('origin_title')),
        _buildOriginSection(),

        const SizedBox(height: 25),

        // --- IMPORTANCE IN INDIA ---
        _buildSubHeading(_t('importance_title')),
        _buildImportanceSection(),

        const SizedBox(height: 25),

        // --- NUTRITIVE VALUE ---
        _buildSubHeading(_t('nutritive_title')),
        const SizedBox(height: 10),
        _buildNutrientTable(),
        const SizedBox(height: 15),
        _buildNutrientGrid(),

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

  Widget _buildOriginSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.public, color: Colors.blueGrey, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _t('origin_body'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.agriculture, color: accentGreen, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('importance_body'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t('importance_bullets'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientTable() {
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
            _buildNutrientRow(_t('nut_carb'), "28.2 g"),
            _buildNutrientRow(_t('nut_vitc'), "0 mg"),
            _buildNutrientRow(_t('nut_potas'), "35 mg"),
            _buildNutrientRow(_t('nut_protein'), "2.7 g"),
            _buildNutrientRow(_t('nut_iron'), "0.2 mg"),
            _buildNutrientRow(_t('nut_calc'), "10 mg"),
            _buildNutrientRow(_t('nut_vitb6'), "0.1 mg"),
          ],
        ),
      ),
    );
  }

  TableRow _buildNutrientRow(String name, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(name, style: const TextStyle(fontSize: 13)),
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

  Widget _buildNutrientGrid() {
    final highlights = [
      _t('tag_fiber'),
      _t('tag_sodium'),
      _t('tag_gluten'),
      _t('tag_chol'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: highlights
          .map(
            (n) => Chip(
              label: Text(
                n,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryPurple,
                ),
              ),
              backgroundColor: const Color(0xFFFFCE99),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}
