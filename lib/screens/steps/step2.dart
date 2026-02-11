import 'package:flutter/material.dart';
import 'step2_translations.dart'; // Ensure this file exists in the same directory

class Step2Content extends StatelessWidget {
  final String locale;

  const Step2Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);

  // Helper method to fetch translated strings
  String _t(String key) {
    // 1. Clean the locale string (extract 'hi' from 'hi_IN')
    final String cleanCode = locale.split(RegExp('[-_]'))[0].toLowerCase();

    // 2. Fetch the data map for that code
    final Map<String, String> translationMap = Step2Translations.getContent(cleanCode);

    // 3. Return the key or fallback to English
    return translationMap[key] ?? Step2Translations.getContent('en')[key] ?? '';
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
              'assets/images/step2.png',
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

        // --- 2.1 CLIMATE ---
        _buildSubHeading(_t('climate_title')),

        _buildInfoCard(_t('climate_desc'), icon: Icons.wb_cloudy_outlined),
        const SizedBox(height: 20),

        // --- TEMPERATURE TABLE ---
        _buildSubHeading(_t('temp_title')),
        _buildTemperatureTable(),
        const SizedBox(height: 15),
        _buildWarningBox(_t('temp_warning')),

        const SizedBox(height: 25),

        // --- 2.2 RAINFALL & HUMIDITY ---
        _buildSubHeading(_t('rain_hum_title')),
        _buildFeatureCard(
          _t('rain_label'),
          _t('rain_desc'),
          Icons.umbrella_outlined,
          Colors.blue,
        ),
        _buildFeatureCard(
          _t('hum_label'),
          _t('hum_desc'),
          Icons.water_drop_outlined,
          Colors.cyan,
        ),

        const SizedBox(height: 25),

        // --- 2.3 SOIL ---
        _buildSubHeading(_t('soil_title')),

        _buildRequirementBox(
          title: _t('soil_type_label'),
          desc: _t('soil_type_desc'),
          icon: Icons.layers_outlined,
          color: Colors.brown,
        ),
        const SizedBox(height: 10),
        _buildRequirementBox(
          title: _t('soil_ph_label'),
          desc: _t('soil_ph_desc'),
          icon: Icons.science_outlined,
          color: Colors.indigo,
        ),

        const SizedBox(height: 25),

        // --- 2.8 SUNLIGHT & DRAINAGE ---
        _buildSubHeading(_t('sun_drain_title')),
        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                _t('sun_label'),
                _t('sun_val'),
                Icons.wb_sunny,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                _t('drain_label'),
                _t('drain_val'),
                Icons.format_line_spacing,
                Colors.teal,
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // --- 2.10 CROP ROTATION ---
        _buildSubHeading(_t('rotation_title')),
        _buildInfoCard(_t('rotation_desc'), icon: Icons.loop),

        const SizedBox(height: 25),

        // --- KEY CHECKLIST ---
        _buildChecklistSection(),

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

  Widget _buildTemperatureTable() {
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
            _buildTableRow(_t('germination'), _t('germination_val')),
            _buildTableRow(_t('veg_growth'), _t('veg_growth_val')),
            _buildTableRow(_t('tuber_dev'), _t('tuber_dev_val')),
            _buildTableRow(_t('night_crit'), _t('night_crit_val')),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String stage, String temp) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(stage, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            temp,
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
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection() {
    final items = [
      _t('check_1'),
      _t('check_2'),
      _t('check_3'),
      _t('check_4'),
      _t('check_5'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('checklist_title'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: accentGreen,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: accentGreen, size: 16),
                  const SizedBox(width: 8),
                  Text(item, style: const TextStyle(fontSize: 13)),
                ],
              ),
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
}
