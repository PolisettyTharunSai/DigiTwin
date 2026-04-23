import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../home/services/recommendation_service.dart';

/// Handles all Supabase interactions for the daily plant log feature.
class DailyLogService {
  DailyLogService._();

  static final DailyLogService instance = DailyLogService._();

  final _recommendationService = RecommendationService();

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<int?> _resolveDayNumberForLogDate(String logDateIso) async {
    try {
      final date = DateTime.parse(logDateIso);
      return await _recommendationService.getCropDayForDate(date);
    } catch (e) {
      debugPrint(
        'DailyLogService: Could not resolve day number from log date: $e',
      );
      return null;
    }
  }

  /// Returns `true` if the authenticated user has already submitted a log today.
  Future<bool> hasSubmittedToday(String userId) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await Supabase.instance.client
        .from(AppConstants.TABLE_PLANT_DAILY_LOG)
        .select('log_date')
        .eq('user_id', userId)
        .eq('log_date', today)
        .maybeSingle();

    return response != null;
  }

  /// Fetches the full log record for today, or `null` if none exists.
  Future<Map<String, dynamic>?> fetchTodayLog(String userId) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await Supabase.instance.client
        .from(AppConstants.TABLE_PLANT_DAILY_LOG)
        .select()
        .eq('user_id', userId)
        .eq('log_date', today)
        .maybeSingle();
  }

  /// Queries the DB for today's log, stores the result in [SharedPreferences],
  /// and returns whether the log exists.
  /// Handles the case where the user is not authenticated (returns `false`).
  Future<bool> checkTodayLogStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final user = Supabase.instance.client.auth.currentUser;

    try {
      if (user != null) {
        final response = await Supabase.instance.client
            .from(AppConstants.TABLE_PLANT_DAILY_LOG)
            .select('log_date')
            .eq('user_id', user.id)
            .eq('log_date', today)
            .maybeSingle();

        final bool logExists = response != null;
        await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
        await prefs.setBool(
          AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED,
          logExists,
        );
        return logExists;
      } else {
        await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
        await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, false);
        return false;
      }
    } catch (e) {
      debugPrint('DailyLogService: Error checking today log — $e');
      await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
      await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, false);
      return false;
    }
  }

  /// Upserts a daily log entry.
  /// [logData] must include 'user_id', 'log_date', and all log fields.
  Future<void> submitLog(Map<String, dynamic> logData) async {
    final payload = Map<String, dynamic>.from(logData);

    final logDate = payload['log_date']?.toString();
    if (payload['day_number'] == null && logDate != null) {
      final resolvedDay = await _resolveDayNumberForLogDate(logDate);
      if (resolvedDay != null) {
        payload['day_number'] = resolvedDay;
      }
    }

    final dayNumber = payload['day_number'] is num
        ? (payload['day_number'] as num).toInt()
        : int.tryParse(payload['day_number']?.toString() ?? '');

    final appliedN = _toDouble(payload['nutrient_n_applied_g']);
    final appliedP = _toDouble(payload['nutrient_p_applied_g']);
    final appliedK = _toDouble(payload['nutrient_k_applied_g']);

    if (dayNumber != null) {
      try {
        final nutrientState = await _recommendationService
            .computeNutrientStateForDay(
              day: dayNumber,
              overrideAppliedN: appliedN,
              overrideAppliedP: appliedP,
              overrideAppliedK: appliedK,
            );

        payload['nutrient_rec_n_g'] = nutrientState.recommendedN;
        payload['nutrient_rec_p_g'] = nutrientState.recommendedP;
        payload['nutrient_rec_k_g'] = nutrientState.recommendedK;
        payload['nutrient_carry_n_g'] = nutrientState.carryN;
        payload['nutrient_carry_p_g'] = nutrientState.carryP;
        payload['nutrient_carry_k_g'] = nutrientState.carryK;
        payload['fertilizer_source'] = nutrientState.fertilizerSource;
      } catch (e) {
        debugPrint('DailyLogService: Nutrient snapshot computation failed: $e');
      }
    }

    debugPrint('═══ DailyLogService.submitLog ═══');
    debugPrint('📤 Sending to plant_daily_log: $payload');

    final response = await Supabase.instance.client
        .from(AppConstants.TABLE_PLANT_DAILY_LOG)
        .upsert(payload, onConflict: 'user_id, log_date');

    debugPrint('📥 plant_daily_log upsert completed: $response');

    try {
      debugPrint(
        '📤 Calling updateCarryBalance → watered=${logData['watered']}, water_amount=${logData['water_amount']}, water_unit=${logData['water_unit']}',
      );
      await _recommendationService.updateCarryBalance(
        waterAmount: payload['water_amount'] ?? 0,
        waterUnit: payload['water_unit'],
        watered: payload['watered'] ?? false,
      );
      debugPrint('✅ updateCarryBalance completed');
    } catch (e) {
      debugPrint('❌ Could not update carry balance: $e');
    }
  }

  /// Uploads an image file to Supabase Storage and returns its public URL.
  /// [fileBytes] should be the raw bytes of the image file.
  Future<String> uploadImage({
    required String userId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final storageName =
        'public/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await Supabase.instance.client.storage
        .from(AppConstants.STORAGE_BUCKET_MODELS)
        .upload(
          storageName,
          fileBytes as dynamic,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    return Supabase.instance.client.storage
        .from(AppConstants.STORAGE_BUCKET_MODELS)
        .getPublicUrl(storageName);
  }

  /// Removes an image from Supabase Storage given its public URL.
  Future<void> deleteImage(String publicUrl) async {
    try {
      final storagePath = publicUrl
          .split('${AppConstants.STORAGE_BUCKET_MODELS}/')
          .last;
      await Supabase.instance.client.storage
          .from(AppConstants.STORAGE_BUCKET_MODELS)
          .remove([storagePath]);
    } catch (e) {
      debugPrint('DailyLogService: Error deleting old image — $e');
    }
  }

  /// Persists today's submission status in SharedPreferences.
  Future<void> cacheSubmissionStatus({required bool submitted}) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
    await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, submitted);
  }
}
