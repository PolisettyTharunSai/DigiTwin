import 'package:flutter/material.dart';

class Step5Content extends StatelessWidget {
  const Step5Content({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF7F3DFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth * 0.5;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Header
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
                      width: double.infinity,
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

              const Text(
                "Seed Rate, Spacing & Nutrition",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Deciding on the right seed rate and fertilizer balance is the secret to a high-yield harvest.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),

              // 2. Seed Rate Section
              _buildSectionHeader(
                "Seed Rate (Quantity)",
                Icons.grass,
                Colors.green,
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "Normal",
                          "100–125 kg/ha",
                          "Timely",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          "Late Sown",
                          "+25% extra",
                          "Low moisture",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          "Broadcasting",
                          "150 kg/ha",
                          "Hand-sown",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricCard(
                          "Dibbling",
                          "25–30 kg/ha",
                          "Line sowing",
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. Spacing Guide
              _buildSectionHeader(
                "Recommended Spacing",
                Icons.straighten,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildSpacingTable(),
              const SizedBox(height: 30),

              // 4. Nitrogen Management
              _buildSectionHeader(
                "Nitrogen (Growth Booster)",
                Icons.bolt,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildDeficiencyList(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      "Irrigated",
                      "120–150 kg/ha",
                      "Full dose",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      "Rainfed",
                      "40–60 kg/ha",
                      "Standard",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Application Strategy (Split Doses):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 15),
              _buildSplitTimeline(primaryPurple),

              const SizedBox(height: 30),

              // 5. Phosphorus & Potassium
              _buildNutrientCard(
                "Phosphorus (P)",
                "60 kg P₂O₅ /ha",
                "Apply FULL dose at sowing (Basal).",
                Colors.deepPurple,
              ),
              const SizedBox(height: 12),
              _buildNutrientCard(
                "Potassium (K)",
                "40–60 kg /ha",
                "Only if soil test shows deficiency.",
                Colors.indigo,
              ),

              const SizedBox(height: 30),

              // 6. Micronutrient Grid (Adjusted for Manganese text width)
              _buildSectionHeader("Micronutrients", Icons.biotech, Colors.teal),
              const SizedBox(height: 12),
              _buildMicronutrientGrid(),
              const SizedBox(height: 12),
              _buildZincDetailCard(),

              const SizedBox(height: 30),

              // 7. INM Section
              _buildSectionHeader(
                "Integrated Nutrition (INM)",
                Icons.eco,
                Colors.green.shade700,
              ),
              const SizedBox(height: 12),
              _buildModernINM(),

              const SizedBox(height: 40),

              // 8. Premium Quick Tips
              _buildPremiumQuickTips(primaryPurple),

              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          _buildTableRow([
            "Condition",
            "Row-Row",
            "Plant-Plant",
          ], isHeader: true),
          _buildTableRow(["Irrigated", "22.5 cm", "8–18 cm"]),
          _buildTableRow(["Rainfed", "25–30 cm", "5–6 cm"]),
          _buildTableRow(["Late Sown", "15–16 cm", "Closely"]),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.blue.withOpacity(0.05) : Colors.transparent,
      ),
      children: cells
          .map(
            (cell) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                cell,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isHeader ? Colors.blue : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDeficiencyList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "⚠️ Is your crop hungry for Nitrogen?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _defPoint("Fewer tillers (Less branching)"),
          _defPoint("Small ear heads"),
          _defPoint("Weak & pale yellowish look"),
        ],
      ),
    );
  }

  Widget _defPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTimeline(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _timelineStep("Sowing", "1st Part", "Basal", color),
        const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        _timelineStep("1st Water", "2nd Part", "Tillering", color),
        const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        _timelineStep("2nd Water", "3rd Part", "Jointing", color),
      ],
    );
  }

  Widget _timelineStep(String label, String part, String desc, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
          child: const Icon(Icons.water_drop, color: Colors.white, size: 14),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          part,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(desc, style: const TextStyle(fontSize: 8, color: Colors.black45)),
      ],
    );
  }

  Widget _buildNutrientCard(
    String title,
    String dose,
    String note,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dose,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --- MICRONUTRIENT GRID ---
  Widget _buildMicronutrientGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌱 Essential Elements:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniChip("Zinc (Zn)"),
              _miniChip("Iron (Fe)"),
              _miniChip("Boron (B)"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _miniChip("Copper (Cu)"),
              _miniChip(
                "Manganese (Mn)",
                flex: 2,
              ), // Slightly more space for Mn text
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 2,
        ), // Tight horizontal padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal.withOpacity(0.3)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1, // Force one line
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildZincDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌾 Zinc (Zn) Management",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _subRow(Icons.landscape, "Soil App:", "25 kg ZnSO₄/ha"),
          const SizedBox(height: 8),
          _subRow(Icons.wash, "Spray:", "5kg ZnSO₄ + 2.5kg Lime / 1000L"),
        ],
      ),
    );
  }

  Widget _subRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Text("$title $desc", style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // --- MODERN INM ---
  Widget _buildModernINM() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Text(
            "♻️ Integrated Nutrient Management",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _inmItem(Icons.compost, "Green Manure"),
              const SizedBox(width: 10),
              _inmItem(Icons.loop, "Pulse Rotation"),
            ],
          ),
          const SizedBox(height: 10),
          _inmItem(
            Icons.biotech,
            "Bio-fertilizers (Azotobacter/PSB)",
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _inmItem(IconData icon, String text, {bool fullWidth = false}) {
    Widget content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    return fullWidth
        ? SizedBox(width: double.infinity, child: content)
        : Expanded(child: content);
  }

  // --- PREMIUM QUICK TIPS ---
  Widget _buildPremiumQuickTips(Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: color, size: 20),
                const SizedBox(width: 10),
                const Text(
                  "Quick Tips for Success",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _tipRow("Adjust seed rate for late sowing.", color),
                _tipRow("Maintain row spacing for root aeration.", color),
                _tipRow("Split Nitrogen into 3 precise doses.", color),
                _tipRow("Basal dose of Phosphorus is mandatory.", color),
                _tipRow("Zinc improves grain shine and weight.", color),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "PRO TIP: Healthy soil = Heavy Yield!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
