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
    required String type, // 'weather', 'log', 'irrigation', 'recommendation'
    String? severity, // 'low', 'medium', 'severe'
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Check user preferences
    if (type == 'weather') {
      final enabled = prefs.getBool('weather_notifications') ?? true;
      if (!enabled) return;
    } else if (type == 'recommendation' || type == 'irrigation') {
      final enabled = prefs.getBool('recommendation_notifications') ?? true;
      if (!enabled) return;
    }

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

    // 2. Check for Recommendation (Irrigation)
    try {
      // Check if we already notified for recommendation today
      final lastRecNotify = prefs.getString('last_recommendation_notification_date');
      if (lastRecNotify != today) {
         // We'll use a simple approach to avoid complex dependencies: 
         // Check if there's a water requirement for today.
         // Note: In a real app, you might want to call RecommendationService here.
         // For now, we'll assume if we're calling this, we want to check.
         
         // Fetch profile to get current day
         final profileRes = await _supabase.from('profile').select('planting_date').eq('id', user.id).single();
         if (profileRes['planting_date'] != null) {
           final plantingDate = DateTime.parse(profileRes['planting_date']);
           final now = DateTime.now();
           final dayNum = now.difference(plantingDate).inDays + 1;

           // Call the edge function directly to check for recommendations
           final response = await _supabase.functions.invoke(
             'dynamic-function',
             body: {
               'action': 'recommend',
               'user_id': user.id,
               'day': dayNum,
               'is_today': true,
             },
           );

           if (response.status == 200 && response.data != null) {
             final data = response.data;
             final waterReq = data['water_requirement'];
             if (waterReq != null && waterReq.toString().contains('ml recommended')) {
               await addNotification(
                 title: 'Irrigation Recommendation',
                 message: 'Your plants need attention: $waterReq',
                 type: 'recommendation',
                 severity: 'medium',
               );
               await prefs.setString('last_recommendation_notification_date', today);
             }
           }
         }
      }
    } catch (e) {
      debugPrint('NotificationService: Error checking recommendations — $e');
    }
  }
}
