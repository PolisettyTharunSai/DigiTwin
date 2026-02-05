import 'package:flutter/material.dart';
// Ensure this matches your actual file name for translations
import 'step6_translations.dart';

class Step6Content extends StatelessWidget {
  final String locale;
  const Step6Content({super.key, required this.locale});

  static const Color primaryPurple = Color(0xFFFF9644);
  static const Color accentGreen = Color(0xFF562F00);
  static const Color warningRed = Color(0xFFFD3C4A);

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height / 4;

    // Use the locale passed down from parent (placeholder). Fallback to system locale if empty.
    final String effectiveLocale = (locale.isNotEmpty)
        ? locale
        : Localizations.localeOf(context).languageCode;
    debugPrint("Step6Content rebuilding with locale: $effectiveLocale");
    final Map<String, String> t = Step6Translations.getContent(effectiveLocale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TOP HERO IMAGE ---
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/step6.png',
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
        _buildHeader(t['main_header'] ?? ""),
        const SizedBox(height: 20),

        // --- 6.1 HARVESTING ---
        _buildSubHeading(t['harvest_title'] ?? ""),
        _buildInfoCard(
          t['harvest_info'] ?? "",
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 12),
        _buildWarningBox(t['harvest_warning'] ?? ""),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _buildMiniCard(
                t['manual_label'] ?? "",
                t['manual_desc'] ?? "",
                Icons.front_hand,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniCard(
                t['mechanical_label'] ?? "",
                t['mechanical_desc'] ?? "",
                Icons.agriculture,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildRequirementBox(
          title: t['haulm_title'] ?? "",
          desc: t['haulm_desc'] ?? "",
          icon: Icons.content_cut_rounded,
          color: Colors.teal,
        ),

        const SizedBox(height: 25),

        // --- EXPECTED YIELD TABLE ---
        Text(
          t['yield_table_title'] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildSimpleTable([
          [t['yield_early_label'] ?? "", t['yield_early_val'] ?? ""],
          [t['yield_main_label'] ?? "", t['yield_main_val'] ?? ""],
          [t['yield_late_label'] ?? "", t['yield_late_val'] ?? ""],
        ]),

        const SizedBox(height: 25),

        // --- 6.2 GRADING ---
        _buildSubHeading(t['grading_title'] ?? ""),
        _buildGradeTable(t),
        const SizedBox(height: 8),
        _buildInfoCard(t['grading_tip'] ?? "", icon: Icons.lightbulb_outline),

        const SizedBox(height: 25),

        // --- 6.3 & 6.4 CURING & STORAGE ---
        _buildSubHeading(t['storage_title'] ?? ""),
        _buildRequirementBox(
          title: t['curing_title'] ?? "",
          desc: t['curing_desc'] ?? "",
          icon: Icons.healing_rounded,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 10),
        _buildRequirementBox(
          title: t['cold_storage_title'] ?? "",
          desc: t['cold_storage_desc'] ?? "",
          icon: Icons.ac_unit_rounded,
          color: Colors.cyan,
        ),
        const SizedBox(height: 10),
        _buildWarningBox(t['storage_problems'] ?? ""),

        const SizedBox(height: 25),

        // --- 6.6 MARKETING & VALUE ADDED ---
        _buildSubHeading(t['marketing_title'] ?? ""),
        _buildPestRow(
          t['channels_label'] ?? "",
          t['channels_desc'] ?? "",
          Icons.hub_rounded,
          Colors.indigo,
        ),
        _buildPestRow(
          t['value_added_label'] ?? "",
          t['value_added_desc'] ?? "",
          Icons.fastfood_rounded,
          Colors.amber,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          t['economic_tip'] ?? "",
          icon: Icons.attach_money_rounded,
        ),

        const SizedBox(height: 25),

        // --- 6.7 TRANSPORTATION ---
        _buildSubHeading(t['transport_title'] ?? ""),
        _buildTransportCard(t),

        const SizedBox(height: 30),

        // --- FINAL PRE-PLANTING CHECKLIST ---
        _buildFinalChecklist(t),

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

  Widget _buildSimpleTable(List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Table(
          children: rows
              .map(
                (row) => TableRow(
                  children: row
                      .map(
                        (cell) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            cell,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGradeTable(Map<String, String> t) {
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
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFFCE99)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    t['table_grade'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    t['table_weight'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            _buildTableRow(t['grade_a_label'] ?? "", t['grade_a_val'] ?? ""),
            _buildTableRow(t['grade_b_label'] ?? "", t['grade_b_val'] ?? ""),
            _buildTableRow(t['grade_c_label'] ?? "", t['grade_c_val'] ?? ""),
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
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportCard(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _TransportItem(icon: Icons.air, text: t['transport_vent'] ?? ""),
          _TransportItem(
            icon: Icons.wb_twilight,
            text: t['transport_hours'] ?? "",
          ),
          _TransportItem(icon: Icons.umbrella, text: t['transport_prot'] ?? ""),
        ],
      ),
    );
  }

  Widget _buildFinalChecklist(Map<String, String> t) {
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
            t['checklist_title'] ?? "",
            style: const TextStyle(
              color: primaryPurple,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          _buildCheckItem(t['check_1'] ?? ""),
          _buildCheckItem(t['check_2'] ?? ""),
          _buildCheckItem(t['check_3'] ?? ""),
          _buildCheckItem(t['check_4'] ?? ""),
          _buildCheckItem(t['check_5'] ?? ""),
          _buildCheckItem(t['check_6'] ?? ""),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: accentGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE COMPONENTS ---

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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPestRow(String title, String desc, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryPurple, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warningRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: warningRed,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TransportItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TransportItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
