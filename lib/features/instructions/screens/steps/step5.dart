import 'package:flutter/material.dart';
import 'step5_translations.dart';

class Step5Content extends StatelessWidget {
  final String locale;

  const Step5Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);
  static const Color warningRed = Color(0xFFFD3C4A);

  // Helper method to fetch translated strings
  String _t(String key) {
    // 1. Clean the locale string (extract 'hi' from 'hi_IN')
    final String cleanCode = locale.split(RegExp('[-_]'))[0].toLowerCase();

    // 2. Fetch the data map for that code
    final Map<String, String> translationMap = Step5Translations.getContent(cleanCode);

    // 3. Return the key or fallback to English
    return translationMap[key] ?? Step5Translations.getContent('en')[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to see what locale is being passed
    debugPrint("Step5Content rebuilding with locale: $locale");

    final double imageHeight = MediaQuery.of(context).size.height / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TOP HERO IMAGE ---
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step5.png',
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

        // --- 5.1 WEED MANAGEMENT ---
        _buildSubHeading(_t('weed_mgmt_heading')),
        _buildInfoCard(
          _t('weed_critical_period'),
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          _t('mulching_title'),
          _t('mulching_desc'),
          Icons.eco_outlined,
          Colors.green,
        ),
        _buildFeatureCard(
          _t('manual_weeding_title'),
          _t('manual_weeding_desc'),
          Icons.pan_tool_outlined,
          Colors.orange,
        ),
        _buildFeatureCard(
          _t('chemical_control_title'),
          _t('chemical_control_desc'),
          Icons.biotech_outlined,
          Colors.blue,
        ),

        const SizedBox(height: 25),

        // --- 5.2 IRRIGATION ---
        _buildSubHeading(_t('irrigation_heading')),

        _buildRequirementBox(
          title: _t('irrigation_req_title'),
          desc: _t('irrigation_req_desc'),
          icon: Icons.waves_outlined,
          color: Colors.blue,
        ),
        const SizedBox(height: 15),
        Text(
          _t('critical_stages_label'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildIrrigationTable(),
        const SizedBox(height: 12),
        _buildWarningBox(_t('irrigation_stop_warning')),

        const SizedBox(height: 25),

        // --- 5.3 FIELD MONITORING ---
        _buildSubHeading(_t('earthing_up_heading')),
        _buildInfoCard(_t('earthing_up_desc'), icon: Icons.visibility_outlined),

        const SizedBox(height: 25),

        // --- 5.4 & 5.5 DISEASES & PESTS ---
        _buildSubHeading(_t('pest_disease_heading')),

        _buildPestRow(
          _t('early_blight_title'),
          _t('early_blight_desc'),
          Icons.spa_outlined,
          Colors.amber,
        ),
        _buildPestRow(
          _t('late_blight_title'),
          _t('late_blight_desc'),
          Icons.format_line_spacing,
          Colors.blueGrey,
        ),
        _buildPestRow(
          _t('aphids_title'),
          _t('aphids_desc'),
          Icons.pest_control_outlined,
          Colors.green,
        ),
        _buildPestRow(
          _t('cutworms_title'),
          _t('cutworms_desc'),
          Icons.bug_report_outlined,
          Colors.redAccent,
        ),
        _buildPestRow(
          _t('white_grubs_title'),
          _t('white_grubs_desc'),
          Icons.nature_outlined,
          Colors.brown,
        ),

        const SizedBox(height: 25),

        // --- 5.6 PHYSIOLOGICAL DISORDERS ---
        _buildSubHeading(_t('disorders_heading')),
        _buildDisorderTable(),

        const SizedBox(height: 25),

        // --- 5.8 IPDM ---
        _buildSubHeading(_t('ipdm_heading')),
        _buildInfoCard(_t('ipdm_desc'), icon: Icons.psychology_outlined),

        const SizedBox(height: 30),

        // --- QUICK SUMMARY CHECKLIST ---
        _buildModernSummary(),

        const SizedBox(height: 100),
      ],
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
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

  Widget _buildIrrigationTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.5)},
          children: [
            _buildTableRow(
              _t('stage_stolon'),
              _t('stolon_impact'),
              isHeader: true,
            ),
            _buildTableRow(_t('stage_initiation'), _t('initiation_impact')),
            _buildTableRow(_t('stage_bulking'), _t('bulking_impact')),
          ],
        ),
      ),
    );
  }

  Widget _buildDisorderTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFFCE99)),
              children: [
                _buildCell(_t('col_disorder'), isTitle: true),
                _buildCell(_t('col_cause'), isTitle: true),
                _buildCell(_t('col_symptom'), isTitle: true),
              ],
            ),
            _buildDisorderRow(
              _t('hollow_heart_t'),
              _t('hollow_heart_c'),
              _t('hollow_heart_s'),
            ),
            _buildDisorderRow(
              _t('black_heart_t'),
              _t('black_heart_c'),
              _t('black_heart_s'),
            ),
            _buildDisorderRow(
              _t('greening_t'),
              _t('greening_c'),
              _t('greening_s'),
            ),
            _buildDisorderRow(
              _t('cracking_t'),
              _t('cracking_c'),
              _t('cracking_s'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
          color: isTitle ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  TableRow _buildDisorderRow(String d, String c, String s) {
    return TableRow(children: [_buildCell(d), _buildCell(c), _buildCell(s)]);
  }

  TableRow _buildTableRow(String left, String right, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            left,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(right, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildPestRow(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          _buildCheckItem(_t('check_weed_free')),
          _buildCheckItem(_t('check_irrigation')),
          _buildCheckItem(_t('check_earthing')),
          _buildCheckItem(_t('check_monitor')),
          _buildCheckItem(_t('check_stop_irrigation')),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
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
                    fontSize: 14,
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
        children: [
          Icon(icon, color: primaryPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
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
        color: warningRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warningRed.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: warningRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
