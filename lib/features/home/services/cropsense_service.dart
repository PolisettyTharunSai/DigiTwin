import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';

/// Holds the full result of one CropSense analysis run.
class CropSenseAnalysisResult {
  final String? diseaseLabel;
  final double? diseaseConfidence;
  final String? diseaseAdvisory;
  final String? pestLabel;
  final double? pestConfidence;
  final String? pestAdvisory;
  final String? damageLabel;
  final double? damageConfidence;

  /// 'completed' | 'partial' | 'failed'
  final String status;

  const CropSenseAnalysisResult({
    this.diseaseLabel,
    this.diseaseConfidence,
    this.diseaseAdvisory,
    this.pestLabel,
    this.pestConfidence,
    this.pestAdvisory,
    this.damageLabel,
    this.damageConfidence,
    this.status = 'completed',
  });

  /// Maps to the new plant_daily_log columns for a Supabase update call.
  Map<String, dynamic> toLogColumns() => {
    AppConstants.COL_IMAGE_ANALYSIS_STATUS: status,
    AppConstants.COL_DISEASE_LABEL: diseaseLabel,
    AppConstants.COL_DISEASE_CONFIDENCE: diseaseConfidence,
    AppConstants.COL_DISEASE_ADVISORY: diseaseAdvisory,
    AppConstants.COL_PEST_LABEL: pestLabel,
    AppConstants.COL_PEST_CONFIDENCE: pestConfidence,
    AppConstants.COL_PEST_ADVISORY: pestAdvisory,
    AppConstants.COL_DAMAGE_LABEL: damageLabel,
    AppConstants.COL_DAMAGE_CONFIDENCE: damageConfidence,
  };
}

/// Wraps the CropSense REST API (https://model.annam.ai).
///
/// Usage:
/// ```dart
/// final result = await CropSenseService.instance.analyze(imageBytes);
/// ```
class CropSenseService {
  CropSenseService._();
  static final CropSenseService instance = CropSenseService._();

  static const _timeout = Duration(seconds: 30);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Runs disease, pest, and damage predictions on [imageBytes] in parallel,
  /// then auto-fetches advisories for any detected labels.
  ///
  /// Never throws — all failures are caught and logged. Returns a result with
  /// status='failed' if every prediction call fails.
  Future<CropSenseAnalysisResult> analyze(List<int> imageBytes) async {
    final base64Image = base64Encode(imageBytes);
    final requestBody = jsonEncode({'image': base64Image, 'heatmap': false});

    debugPrint('CropSenseService: starting 3 parallel predictions…');

    // ── Step 1: disease / pest / damage in parallel ───────────────────────
    final predictions = await Future.wait([
      _safePredict('disease', requestBody),
      _safePredict('pest', requestBody),
      _safePredict('damage', requestBody),
    ]);

    final diseaseLabel = _topLabel('disease', predictions[0]);
    final diseaseConf = _topConfidence('disease', predictions[0]);
    final pestLabel = _topLabel('pest', predictions[1]);
    final pestConf = _topConfidence('pest', predictions[1]);
    final damageLabel = _topLabel('damage', predictions[2]);
    final damageConf = _topConfidence('damage', predictions[2]);

    debugPrint(
      'CropSenseService: predictions → '
      'disease=$diseaseLabel($diseaseConf) '
      'pest=$pestLabel($pestConf) '
      'damage=$damageLabel($damageConf)',
    );

    // ── Step 2: Fetch advisories (only for detected labels) ───────────────
    final advisories = await Future.wait([
      diseaseLabel != null
          ? _safeAdvisory(
              '/advisory/disease'
              '/${Uri.encodeComponent(AppConstants.CROP_NAME)}'
              '/${Uri.encodeComponent(diseaseLabel)}',
            )
          : Future.value(null),
      pestLabel != null
          ? _safeAdvisory('/advisory/pest/${Uri.encodeComponent(pestLabel)}')
          : Future.value(null),
    ]);

    final hasAny =
        diseaseLabel != null || pestLabel != null || damageLabel != null;

    debugPrint(
      'CropSenseService: analysis complete — '
      'status=${hasAny ? 'completed' : 'failed'}',
    );

    return CropSenseAnalysisResult(
      diseaseLabel: diseaseLabel,
      diseaseConfidence: diseaseConf,
      diseaseAdvisory: advisories[0],
      pestLabel: pestLabel,
      pestConfidence: pestConf,
      pestAdvisory: advisories[1],
      damageLabel: damageLabel,
      damageConfidence: damageConf,
      status: hasAny ? 'completed' : 'failed',
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _safePredict(
    String endpoint,
    String body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.CROPSENSE_BASE_URL}/predict/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      debugPrint(
        'CropSenseService: /predict/$endpoint → ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('CropSenseService: /predict/$endpoint failed — $e');
    }
    return null;
  }

  Future<String?> _safeAdvisory(String path) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.CROPSENSE_BASE_URL}$path'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          final status = data['status']?.toString().toLowerCase();
          if (status == 'not_found' || status == 'error') return null;
          return (data['advisory'] ??
                  data['recommendation'] ??
                  data['message'] ??
                  data['text'])
              ?.toString();
        }
        return data.toString();
      }
    } catch (e) {
      debugPrint('CropSenseService: advisory $path failed — $e');
    }
    return null;
  }

  String? _topLabel(String endpoint, Map<String, dynamic>? data) {
    if (_hasPredictionError(data)) return null;
    if (endpoint == 'damage') {
      return (data?['severity_grade'] ??
              data?['damage_label'] ??
              data?['label'] ??
              data?['class'])
          ?.toString();
    }

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

  double? _topConfidence(String endpoint, Map<String, dynamic>? data) {
    if (_hasPredictionError(data)) return null;
    if (endpoint == 'damage') {
      return _toDouble(
        data?['damaged_percent'] ??
            data?['confidence'] ??
            data?['score'] ??
            data?['probability'],
      );
    }

    final raw =
        data?['confidence'] ??
        data?['score'] ??
        data?['probability'] ??
        _confidenceFromItem(_topScoredItem(data?['detections'])) ??
        _confidenceFromItem(_topScoredItem(data?['predictions']));
    return _toDouble(raw);
  }

  bool _hasPredictionError(Map<String, dynamic>? data) {
    if (data == null) return true;
    final error = data['error'];
    if (error != null && error.toString().trim().isNotEmpty) return true;
    final status = data['status']?.toString().toLowerCase();
    return status == 'error' || status == 'failed';
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
