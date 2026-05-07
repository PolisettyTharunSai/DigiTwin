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

    final diseaseLabel = _topLabel(predictions[0]);
    final diseaseConf = _topConfidence(predictions[0]);
    final pestLabel = _topLabel(predictions[1]);
    final pestConf = _topConfidence(predictions[1]);
    final damageLabel = _topLabel(predictions[2]);
    final damageConf = _topConfidence(predictions[2]);

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
          ? _safeAdvisory(
              '/advisory/pest/${Uri.encodeComponent(pestLabel)}',
            )
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
            Uri.parse(
              '${AppConstants.CROPSENSE_BASE_URL}/predict/$endpoint',
            ),
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
          return (data['advisory'] ?? data['message'] ?? data['text'])
              ?.toString();
        }
        return data.toString();
      }
    } catch (e) {
      debugPrint('CropSenseService: advisory $path failed — $e');
    }
    return null;
  }

  /// Extracts the top predicted class label from a prediction response.
  ///
  /// Handles the common shapes returned by ML APIs:
  ///   { "label": "Late Blight" }
  ///   { "predicted_class": "Aphid" }
  ///   { "predictions": [{"label": "...", "confidence": 0.9}] }
  String? _topLabel(Map<String, dynamic>? data) {
    if (data == null) return null;
    return (data['label'] ??
            data['class'] ??
            data['predicted_class'] ??
            data['prediction'] ??
            _firstPredictionField(data, 'label'))
        ?.toString();
  }

  double? _topConfidence(Map<String, dynamic>? data) {
    if (data == null) return null;
    final raw = data['confidence'] ??
        data['score'] ??
        data['probability'] ??
        _firstPredictionField(data, 'confidence');
    if (raw == null) return null;
    return raw is num ? raw.toDouble() : double.tryParse(raw.toString());
  }

  dynamic _firstPredictionField(Map<String, dynamic> data, String key) {
    final preds = data['predictions'];
    if (preds is List && preds.isNotEmpty && preds.first is Map) {
      return (preds.first as Map)[key];
    }
    return null;
  }
}
