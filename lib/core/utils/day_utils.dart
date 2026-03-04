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

    final int adjustedDay = currentDay - AppConstants.VISUAL_DATA_START_DAY;

    final startDate = DateTime(2025, 12, 10);
    final date = startDate.add(Duration(days: adjustedDay - 1));
    final day = date.day;
    final monthAbbr = DateFormat('MMM').format(date).toLowerCase();

    final String monthYearFolder = date.month == 12
        ? 'December ${date.year}'
        : '${DateFormat('MMM').format(date)} ${date.year}';

    final String dayFolder = '$day $monthAbbr';

    return List.generate(AppConstants.IMAGES_PER_DAY, (i) {
      final frameName = 'frame_${i.toString().padLeft(3, '0')}.webp';
      return '${AppConstants.IMAGE_BASE_URL}/${Uri.encodeComponent(monthYearFolder)}/${Uri.encodeComponent(dayFolder)}/1/$frameName';
    });
  }

  /// Returns the 3D model URL for [currentDay].
  /// Returns an empty string when [currentDay] <= [AppConstants.VISUAL_DATA_START_DAY].
  static String getModelUrlForDay(int currentDay) {
    if (currentDay <= AppConstants.VISUAL_DATA_START_DAY) return '';
    final int adjustedDay = currentDay - AppConstants.VISUAL_DATA_START_DAY;
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
