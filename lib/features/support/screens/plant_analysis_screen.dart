import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class PlantAnalysisScreen extends StatefulWidget {
  const PlantAnalysisScreen({super.key});

  @override
  State<PlantAnalysisScreen> createState() => _PlantAnalysisScreenState();
}

class _PlantAnalysisScreenState extends State<PlantAnalysisScreen> {
  final Set<_AnalysisOption> _selectedOptions = {
    _AnalysisOption.plant,
    _AnalysisOption.disease,
    _AnalysisOption.damage,
    _AnalysisOption.pest,
  };
  Uint8List? _imageBytes;
  _PlantAnalysisResult? _result;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _result = null;
    });
  }

  Future<void> _analyze() async {
    final image = _imageBytes;
    if (image == null || _selectedOptions.isEmpty || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final result = await _runSelectedAnalysis(image);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<_PlantAnalysisResult> _runSelectedAnalysis(Uint8List image) async {
    final calls = <Future<void>>[];
    final result = _PlantAnalysisResult();

    if (_selectedOptions.contains(_AnalysisOption.plant)) {
      calls.add(_predict('crop', image).then((data) => result.crop = data));
    }
    if (_selectedOptions.contains(_AnalysisOption.disease)) {
      calls.add(
        _predict('disease', image).then((data) => result.disease = data),
      );
    }
    if (_selectedOptions.contains(_AnalysisOption.pest)) {
      calls.add(_predict('pest', image).then((data) => result.pest = data));
    }
    if (_selectedOptions.contains(_AnalysisOption.damage)) {
      calls.add(_predict('damage', image).then((data) => result.damage = data));
    }

    await Future.wait(calls);
    return result;
  }

  Future<Map<String, dynamic>?> _predict(
    String endpoint,
    Uint8List image,
  ) async {
    final body = jsonEncode({'image': base64Encode(image), 'heatmap': false});

    final response = await http
        .post(
          Uri.parse('${AppConstants.CROPSENSE_BASE_URL}/predict/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('/predict/$endpoint failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  void _toggleOption(_AnalysisOption option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Analyze Plant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Choose checks',
            style: TextStyle(
              color: AppColors.darkBrown,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _AnalysisOption.values.map((option) {
              final selected = _selectedOptions.contains(option);
              return FilterChip(
                selected: selected,
                label: Text(option.label),
                avatar: Icon(
                  option.icon,
                  size: 17,
                  color: selected ? Colors.white : AppColors.primary,
                ),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.darkBrown,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
                onSelected: (_) => _toggleOption(option),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _UploadCard(
            imageBytes: _imageBytes,
            onCamera: () => _pickImage(ImageSource.camera),
            onGallery: () => _pickImage(ImageSource.gallery),
            onClear: () => setState(() {
              _imageBytes = null;
              _result = null;
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  _imageBytes == null ||
                      _selectedOptions.isEmpty ||
                      _isProcessing
                  ? null
                  : _analyze,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isProcessing ? 'Processing...' : 'Run Analysis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 22),
            const Text(
              'Results',
              style: TextStyle(
                color: AppColors.darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildResultCards(_result!),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildResultCards(_PlantAnalysisResult result) {
    final cards = <Widget>[];

    if (_selectedOptions.contains(_AnalysisOption.plant)) {
      final cropPrediction = _topScoredItem(result.crop?['predictions']);
      final cropLabel =
          cropPrediction?['class'] ??
          cropPrediction?['label'] ??
          cropPrediction?['name'];
      final cropConfidence = _confidenceFromItem(cropPrediction);
      final cropStatus = result.crop?['status']?.toString();
      final isUnsupportedCrop =
          cropStatus == 'unsupported_crop' ||
          cropLabel?.toString().toLowerCase() == 'unsupported_crop';

      cards.add(
        _ResultCard(
          title: 'Plant Detection',
          icon: Icons.local_florist_outlined,
          rows: [
            _ResultRow(
              label: 'Status',
              value: isUnsupportedCrop
                  ? 'Unsupported crop'
                  : 'Plant crop identified',
            ),
            if (cropLabel != null)
              _ResultRow(label: 'Top match', value: cropLabel.toString()),
            if (cropConfidence != null)
              _ResultRow(
                label: 'Confidence',
                value: _formatPercent(cropConfidence),
              ),
          ],
        ),
      );
    }

    if (_selectedOptions.contains(_AnalysisOption.disease)) {
      cards.add(
        _ResultCard(
          title: 'Disease Detection',
          icon: Icons.healing_outlined,
          rows: [
            if (_hasPredictionError(result.disease))
              _ResultRow(
                label: 'Status',
                value:
                    result.disease?['error']?.toString() ??
                    'Disease could not be detected',
              )
            else ...[
              _ResultRow(
                label: 'Diagnosis',
                value: _topLabel(result.disease) ?? 'No disease detected',
              ),
              if (_topConfidence(result.disease) != null)
                _ResultRow(
                  label: 'Confidence',
                  value: _formatPercent(_topConfidence(result.disease)),
                ),
            ],
          ],
        ),
      );
    }

    if (_selectedOptions.contains(_AnalysisOption.damage)) {
      final damageData = result.damage;
      final severity = damageData?['severity_grade'] ??
          damageData?['damage_label'] ??
          damageData?['label'] ??
          damageData?['class'];
      final confidence = damageData?['damaged_percent'] ??
          damageData?['confidence'] ??
          damageData?['score'] ??
          damageData?['probability'];

      cards.add(
        _ResultCard(
          title: 'Damage Detection',
          icon: Icons.warning_amber_rounded,
          rows: [
            if (_hasPredictionError(damageData))
              _ResultRow(
                label: 'Status',
                value: 'Damage could not be analyzed',
              )
            else ...[
              _ResultRow(
                label: 'Severity',
                value: severity?.toString() ?? 'No visible damage',
              ),
              if (confidence != null)
                _ResultRow(
                  label: 'Confidence',
                  value: _formatPercent(confidence),
                ),
            ],
          ],
        ),
      );
    }

    if (_selectedOptions.contains(_AnalysisOption.pest)) {
      cards.add(
        _ResultCard(
          title: 'Pest Detection',
          icon: Icons.bug_report_outlined,
          rows: [
            _ResultRow(
              label: 'Result',
              value: _topLabel(result.pest) ?? 'No pests detected',
            ),
            if (_topConfidence(result.pest) != null)
              _ResultRow(
                label: 'Confidence',
                value: _formatPercent(_topConfidence(result.pest)),
              ),
          ],
        ),
      );
    }

    return cards
        .map(
          (card) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: card),
        )
        .toList();
  }

  String _formatPercent(dynamic value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null) return 'Unknown';
    final percent = parsed > 1 ? parsed : parsed * 100;
    return '${percent.toStringAsFixed(0)}%';
  }

  bool _hasPredictionError(Map<String, dynamic>? data) {
    if (data == null) return true;
    final error = data['error'];
    if (error != null && error.toString().trim().isNotEmpty) return true;
    final status = data['status']?.toString().toLowerCase();
    return status == 'error' || status == 'failed';
  }

  String? _topLabel(Map<String, dynamic>? data) {
    if (_hasPredictionError(data)) return null;
    final direct =
        data?['label'] ??
        data?['class'] ??
        data?['predicted_class'] ??
        data?['prediction'] ??
        data?['disease'] ??
        data?['disease_name'] ??
        data?['predicted_disease'] ??
        data?['pest'] ??
        data?['pest_name'];
    if (direct != null) return direct.toString();

    final detection = _topScoredItem(data?['detections']);
    final detectedLabel =
        detection?['label'] ??
        detection?['class'] ??
        detection?['name'] ??
        detection?['pest'] ??
        detection?['disease'];
    if (detectedLabel != null) return detectedLabel.toString();

    final prediction = _topScoredItem(data?['predictions']);
    final predictedLabel =
        prediction?['label'] ??
        prediction?['class'] ??
        prediction?['name'] ??
        prediction?['pest'] ??
        prediction?['disease'];
    return predictedLabel?.toString();
  }

  double? _topConfidence(Map<String, dynamic>? data) {
    if (_hasPredictionError(data)) return null;
    final raw =
        data?['confidence'] ??
        data?['score'] ??
        data?['probability'] ??
        _confidenceFromItem(_topScoredItem(data?['detections'])) ??
        _confidenceFromItem(_topScoredItem(data?['predictions']));
    return _toDouble(raw);
  }

  Map<String, dynamic>? _topScoredItem(dynamic items) {
    if (items is! List || items.isEmpty) return null;

    Map<String, dynamic>? best;
    double? bestScore;
    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final score = _confidenceFromItem(map) ?? -1;
      if (best == null || score > (bestScore ?? -1)) {
        best = map;
        bestScore = score;
      }
    }
    return best;
  }

  double? _confidenceFromItem(Map<String, dynamic>? item) {
    if (item == null) return null;
    return _toDouble(
      item['confidence'] ??
          item['score'] ??
          item['probability'] ??
          item['det_conf'],
    );
  }

  double? _toDouble(dynamic raw) {
    if (raw == null) return null;
    return raw is num ? raw.toDouble() : double.tryParse(raw.toString());
  }
}

class _PlantAnalysisResult {
  Map<String, dynamic>? crop;
  Map<String, dynamic>? disease;
  Map<String, dynamic>? pest;
  Map<String, dynamic>? damage;
}

class _UploadCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  const _UploadCard({
    required this.imageBytes,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: imageBytes == null
          ? Column(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload Image',
                  style: TextStyle(
                    color: AppColors.darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCamera,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGallery,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    imageBytes!,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Remove image'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_ResultRow> rows;

  const _ResultCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkBrown,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.darkBrown,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AnalysisOption {
  plant('Plant Detection', Icons.local_florist_outlined),
  disease('Disease Detection', Icons.healing_outlined),
  damage('Damage Detection', Icons.warning_amber_rounded),
  pest('Pest Detection', Icons.bug_report_outlined);

  final String label;
  final IconData icon;

  const _AnalysisOption(this.label, this.icon);
}
