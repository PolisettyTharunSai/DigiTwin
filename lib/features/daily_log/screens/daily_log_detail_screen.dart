import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class DailyLogDetailScreen extends StatefulWidget {
  final Map<String, dynamic> log;

  const DailyLogDetailScreen({super.key, required this.log});

  @override
  State<DailyLogDetailScreen> createState() => _DailyLogDetailScreenState();
}

class _DailyLogDetailScreenState extends State<DailyLogDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final date = DateTime.parse(log['log_date']);
    final dayNum = log['day_number'] ?? '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Day $dayNum Log Detail',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- LOG INFO ----------------
            _buildSectionHeader('Log Information'),
            _buildDetailCard([
              _buildDetailRow(
                'Date',
                DateFormat('EEEE, MMM dd yyyy').format(date),
              ),
              _buildDetailRow('Crop Day', 'Day $dayNum'),
            ]),
            const SizedBox(height: 20),

            // ---------------- WATER ----------------
            _buildSectionHeader('Watering'),
            _buildDetailCard([
              _buildDetailRow(
                'Watered',
                log['watered'] == true
                    ? '${log['water_amount']} ${log['water_unit']}'
                    : 'No',
              ),
            ]),
            const SizedBox(height: 20),

            // ---------------- OBSERVATIONS ----------------
            _buildSectionHeader('Observations'),
            _buildDetailCard([
              _buildDetailRow(
                'Pests Observed',
                log['pests_observed'] == true ? 'Yes' : 'No',
              ),
              if (log['pest_notes'] != null &&
                  log['pest_notes'].toString().isNotEmpty)
                _buildDetailRow('Pest Notes', log['pest_notes']),
              if (log['feedback'] != null &&
                  log['feedback'].toString().isNotEmpty)
                _buildDetailRow('General Feedback', log['feedback']),
            ]),
            const SizedBox(height: 20),

            // ---------------- NUTRIENTS ----------------
            _buildSectionHeader('Nutrients'),
            _buildDetailCard([
              _buildDetailRow('N Applied', '${log['nutrient_n_applied_g']} g'),
              _buildDetailRow('P Applied', '${log['nutrient_p_applied_g']} g'),
              _buildDetailRow('K Applied', '${log['nutrient_k_applied_g']} g'),
              if (log['fertilizer_source'] != null &&
                  log['fertilizer_source'].toString().isNotEmpty)
                _buildDetailRow('Source', log['fertilizer_source']),
            ]),
            const SizedBox(height: 20),

            // ---------------- AI ANALYSIS ----------------
            if (log['image_analysis_status'] == 'processing') ...[
              _buildSectionHeader('AI Crop Health Review'),
              _buildDetailCard([
                const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Analyzing your images...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 20),
            ],

            if (log['image_analysis_status'] == 'completed') ...[
              _buildSectionHeader('AI Crop Health Review'),
              _buildDetailCard([
                // Overall Health
                _buildDetailRow(
                  'Overall Health',
                  _getHealthStatus(log),
                  valueColor: _getHealthColor(log),
                ),
                const Divider(height: 24),

                // Disease Section
                _buildFarmerFriendlyBlock(
                  title: '🦠 Disease Detection',
                  label: log['disease_label'],
                  confidence: log['disease_confidence'],
                  advisory: log['disease_advisory'],
                  fallbackLabel: 'No signs of disease',
                ),
                const Divider(height: 24),

                // Pest Section
                _buildFarmerFriendlyBlock(
                  title: '🐛 Pest Detection',
                  label: log['pest_label'],
                  confidence: log['pest_confidence'],
                  advisory: log['pest_advisory'],
                  fallbackLabel: 'No pests detected',
                ),
                const Divider(height: 24),

                // Physical Damage Section
                _buildFarmerFriendlyBlock(
                  title: '🍂 Physical Damage',
                  label: log['damage_label'],
                  confidence: log['damage_confidence'],
                  advisory:
                      null, // Damage usually doesn't have an advisory in your schema, but you can add it if needed
                  fallbackLabel: 'No visible leaf damage',
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // ---------------- IMAGES ----------------
            if (log['images'] != null &&
                (log['images'] as List).isNotEmpty) ...[
              _buildSectionHeader('Photos'),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: (log['images'] as List).length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final url = log['images'][index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  /// A specialized block to make AI data scannable for farmers
  Widget _buildFarmerFriendlyBlock({
    required String title,
    required dynamic label,
    required dynamic confidence,
    required dynamic advisory,
    required String fallbackLabel,
  }) {
    final bool hasIssue =
        label != null &&
        label.toString().isNotEmpty &&
        label.toString().toLowerCase() != 'healthy' &&
        label.toString().toLowerCase() != 'none';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (!hasIssue)
          Text(
            fallbackLabel,
            style: const TextStyle(fontSize: 14, color: Colors.green),
          )
        else ...[
          _buildDetailRow('Identified', label.toString(), isSmall: false),
          if (confidence != null)
            _buildDetailRow(
              'Certainty',
              _formatConfidence(confidence),
              isSmall: true,
            ),
          if (advisory != null && advisory.toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended Action:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAdvisoryText(advisory),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _getHealthStatus(Map log) {
    // If any of the labels indicate a problem, flag it.
    final bool hasDisease =
        log['disease_label'] != null &&
        log['disease_label'].toString().toLowerCase() != 'healthy';
    final bool hasPest =
        log['pest_label'] != null &&
        log['pest_label'].toString().toLowerCase() != 'none';

    if (hasDisease || hasPest) {
      return 'Attention Needed ⚠️';
    }
    return 'Healthy 🌱';
  }

  Color _getHealthColor(Map log) {
    final bool hasDisease =
        log['disease_label'] != null &&
        log['disease_label'].toString().toLowerCase() != 'healthy';
    final bool hasPest =
        log['pest_label'] != null &&
        log['pest_label'].toString().toLowerCase() != 'none';

    if (hasDisease || hasPest) {
      return Colors.red;
    }
    return Colors.green;
  }

  String _formatConfidence(dynamic value) {
    if (value == null) return 'Unknown';

    final double? parsed = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());
    if (parsed == null) return 'Unknown';

    final double percentValue = parsed > 1 ? parsed : parsed * 100;
    final percent = percentValue.toStringAsFixed(0);
    final normalized = percentValue / 100;

    if (normalized > 0.8) return 'High ($percent%)';
    if (normalized > 0.5) return 'Medium ($percent%)';
    return 'Low ($percent%)';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmall ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parses a messy Map or stringified JSON into clean, bolded bullet points.
  Widget _buildAdvisoryText(dynamic advisoryData) {
    if (advisoryData == null) return const SizedBox();

    String text = advisoryData.toString().trim();
    if (text.isEmpty) return const SizedBox();

    if (text.startsWith('{') && text.endsWith('}')) {
      text = text.substring(1, text.length - 1);
    }

    final items = text
        .split(', ')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final colonIndex = item.indexOf(':');

        if (colonIndex != -1) {
          final key = item.substring(0, colonIndex).trim();
          final value = item.substring(colonIndex + 1).trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '• $key: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            '• ${item.trim()}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }
}
