import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';

/// Handles all Supabase interactions for the daily plant log feature.
class DailyLogService {
  const DailyLogService._();

  static const DailyLogService instance = DailyLogService._();

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
        await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, logExists);
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
    await Supabase.instance.client
        .from(AppConstants.TABLE_PLANT_DAILY_LOG)
        .upsert(logData, onConflict: 'user_id, log_date');
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

    await Supabase.instance.client.storage.from(AppConstants.STORAGE_BUCKET_MODELS).upload(
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
      final storagePath = publicUrl.split('${AppConstants.STORAGE_BUCKET_MODELS}/').last;
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
