import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import '../models/day_data.dart';
import '../../../core/utils/day_utils.dart';

/// Handles data loading for the HomeScreen:
/// - Day text from local assets
/// - 3D model availability check via HTTP HEAD request
class HomeService {
  HomeService() : _dio = Dio();

  final Dio _dio;

  /// Loads day text from bundled assets and returns a parsed [DayData].
  /// Falls back to [DayData.fallback] if the asset is missing.
  Future<DayData> loadDayData(int currentDay) async {
    try {
      final text = await rootBundle.loadString(
        'assets/Data/day$currentDay/day$currentDay.txt',
      );
      return DayData.fromRawText(text);
    } catch (_) {
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
