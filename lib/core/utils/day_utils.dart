import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';

/// Pure utility functions for computing day-related values in the plantation cycle.
class DayUtils {
  DayUtils._();

  /// Returns the current day (1-based) since the [plantationDate].
  /// Clamps the result to [1, TOTAL_CROP_DAYS].
  static int calculateTodayDay(DateTime plantationDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      plantationDate.year,
      plantationDate.month,
      plantationDate.day,
    );
    final diff = today.difference(start).inDays;
    return (diff + 1).clamp(1, AppConstants.TOTAL_CROP_DAYS);
  }

  /// Returns the list of image URLs for [currentDay].
  /// Returns an empty list when [currentDay] <= [AppConstants.VISUAL_DATA_START_DAY].
  static List<String> getImagesForDay(int currentDay) {
    if (currentDay <= AppConstants.VISUAL_DATA_START_DAY) return [];
    
    // Clamp to the last available day
    final int effectiveDay = currentDay > AppConstants.VISUAL_DATA_END_DAY
        ? AppConstants.VISUAL_DATA_END_DAY
        : currentDay;

    final int adjustedDay = effectiveDay - AppConstants.VISUAL_DATA_START_DAY;

    return List.generate(AppConstants.IMAGES_PER_DAY, (i) {
      // New format: D{adjustedDay}_{imagenumber}.jpg
      // imagenumber is 1-based (1 to 10)
      final imageName = 'D${adjustedDay}_${i + 1}.jpg';
      return '${AppConstants.IMAGE_BASE_URL}/$imageName';
    });
  }

  /// Returns the 3D model URL for [currentDay].
  /// Returns an empty string when [currentDay] <= [AppConstants.VISUAL_DATA_START_DAY].
  static String getModelUrlForDay(int currentDay) {
    if (currentDay <= AppConstants.VISUAL_DATA_START_DAY) return '';

    // Clamp to the last available day
    final int effectiveDay = currentDay > AppConstants.VISUAL_DATA_END_DAY
        ? AppConstants.VISUAL_DATA_END_DAY
        : currentDay;

    final int adjustedDay = effectiveDay - AppConstants.VISUAL_DATA_START_DAY;
    return '${AppConstants.MODEL_BASE_URL}/Day$adjustedDay.glb';
  }

  /// Parses water text and returns a human-friendly label.
  static String formatWaterText(String water) {
    final lower = water.toLowerCase().trim();
    if (RegExp(r'^0+(?:\.0+)?\s*ml').hasMatch(lower)) {
      return 'No water required';
    }
    return water;
  }
}
