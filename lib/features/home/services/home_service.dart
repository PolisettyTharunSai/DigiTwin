import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/day_data.dart';
import '../../../core/utils/day_utils.dart';
import 'recommendation_service.dart';

/// Handles data loading for the HomeScreen:
/// - Day text from local assets (deprecated, moving to dynamic)
/// - 3D model availability check via HTTP HEAD request
/// - Dynamic recommendation via RecommendationService
class HomeService {
  HomeService() : _dio = Dio();

  final Dio _dio;
  final _recommendationService = RecommendationService();

  /// Loads day data by fetching a merged recommendation (live water + local others)
  /// from the RecommendationService.
  Future<DayData> loadDayData(int currentDay) async {
    try {
      final rec = await _recommendationService.getDailyRecommendation(targetDay: currentDay);
      
      return DayData(
        rawText: '', // Deprecated: rawText is no longer needed since we have structured fields
        stage: rec.cropStage,
        water: rec.waterRequirement,
        nutrients: rec.nutrientApplication,
      );
    } catch (e) {
      debugPrint('HomeService: Failed to load daily data for day $currentDay: $e');
      return DayData.fallback();
    }
  }

  /// Returns whether a 3D model exists for the given [currentDay].
  /// Always returns `true` for days ≤ 30 (no model expected yet).
  Future<bool> checkModelExists(int currentDay) async {
    final modelUrl = DayUtils.getModelUrlForDay(currentDay);
    if (modelUrl.isEmpty) return true; // No model expected, not an error

    try {
      final response = await _dio.head(modelUrl);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
