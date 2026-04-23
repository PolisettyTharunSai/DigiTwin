import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Handles in-app notifications and weather alerts.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _supabase = Supabase.instance.client;

  /// Fetches notifications from Supabase for the current user.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('NotificationService: Error fetching notifications — $e');
      return [];
    }
  }

  /// Adds a notification to the database.
  Future<void> addNotification({
    required String title,
    required String message,
    required String type, // 'weather', 'log', 'irrigation'
    String? severity, // 'low', 'medium', 'severe'
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'message': message,
        'type': type,
        'severity': severity,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('NotificationService: Error adding notification — $e');
    }
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      debugPrint('NotificationService: Error marking notification as read — $e');
    }
  }

  /// Checks and generates system notifications based on current state.
  /// Called periodically or on home screen load.
  Future<void> checkSystemNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Check if user forgot to water (last log was long ago or missing)
    final bool hasTodayLog = prefs.getBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED) ?? false;
    if (!hasTodayLog) {
      // Check if we already notified today to avoid spamming
      final lastLogNotify = prefs.getString('last_log_notification_date');
      if (lastLogNotify != today) {
        await addNotification(
          title: 'Daily Log Reminder',
          message: 'Don\'t forget to update your plant health check for today!',
          type: 'log',
        );
        await prefs.setString('last_log_notification_date', today);
      }
    }
  }
}
