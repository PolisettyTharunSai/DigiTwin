import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';

/// Provides profile-related data access: farmer name, planting date.
class ProfileService {
  const ProfileService._();

  static const ProfileService instance = ProfileService._();

  /// Loads farmer name and planting date from Supabase, falling back to
  /// SharedPreferences offline cache.
  /// Returns a map with keys: 'farmerName' (String) and 'plantationDate' (DateTime?).
  Future<Map<String, dynamic>> loadFarmerAndPlantation() async {
    final prefs = await SharedPreferences.getInstance();

    // Start with cached values
    String farmerName = prefs.getString(AppConstants.PREF_FARMER_NAME) ?? 'Farmer';
    DateTime? plantationDate;

    final String? savedDate = prefs.getString(AppConstants.PREF_PLANTING_DATE);
    if (savedDate != null) {
      plantationDate = DateTime.tryParse(savedDate);
    }

    // Fetch fresh data from Supabase if authenticated
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from(AppConstants.TABLE_PROFILE)
            .select('name, planting_date')
            .eq('id', user.id)
            .maybeSingle();

        if (res != null) {
          if (res['name'] != null) {
            farmerName = res['name'];
            await prefs.setString(AppConstants.PREF_FARMER_NAME, farmerName);
          }

          if (res['planting_date'] != null) {
            final String dateStr = res['planting_date'];
            DateTime? parsed = DateTime.tryParse(dateStr);

            if (parsed == null) {
              try {
                parsed = DateFormat('d/M/yyyy').parse(dateStr);
              } catch (_) {
                try {
                  parsed = DateFormat('dd/MM/yyyy').parse(dateStr);
                } catch (_) {}
              }
            }

            if (parsed != null) {
              plantationDate = parsed;
              await prefs.setString(
                AppConstants.PREF_PLANTING_DATE,
                parsed.toIso8601String(),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('ProfileService: Error loading profile — $e');
      }
    }

    return {
      'farmerName': farmerName,
      'plantationDate': plantationDate,
    };
  }
}
