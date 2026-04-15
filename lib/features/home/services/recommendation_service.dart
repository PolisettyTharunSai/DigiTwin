import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────
// Unit conversion — handles whatever string is in water_unit
// ─────────────────────────────────────────────────────────────
double _toMl(num amount, String? unit) {
  switch ((unit ?? 'ml').toLowerCase().trim()) {
    case 'l':
    case 'liter':
    case 'liters':
    case 'litre':
    case 'litres':
      return amount.toDouble() * 1000;
    default:
      return amount.toDouble();
  }
}

// ─────────────────────────────────────────────────────────────
// Response model — same keys existing widgets already use
// ─────────────────────────────────────────────────────────────
class RecommendationResponse {
  final String day;
  final String cropStage;
  final String waterRequirement;
  final String nutrientApplication;

  RecommendationResponse({
    required this.day,
    required this.cropStage,
    required this.waterRequirement,
    required this.nutrientApplication,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    // Note: Use toString() to handle both int and String from JSON
    return RecommendationResponse(
      day: json['day']?.toString() ?? '',
      cropStage: json['crop_stage'] ?? 'Not available',
      waterRequirement: json['water_requirement'] ?? 'Not available',
      nutrientApplication: json['nutrient_application'] ?? 'Not available',
    );
  }

  Map<String, String> toMap() => {
    'day': 'Day $day',
    'crop_stage': cropStage,
    'water_requirement': waterRequirement,
    'nutrient_application': nutrientApplication,
  };
}

// ─────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────
class RecommendationService {
  final _supabase = Supabase.instance.client;

  // Reads planting_date, lat, lon from profile table.
  // Returns the crop day number (1-based, clamped 1–109).
  Future<Map<String, dynamic>> _readProfile({int? targetDay}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final row = await _supabase
        .from('profile')
        .select('latitude, longitude, planting_date, is_crop_planted')
        .eq('id', userId)
        .single();

    if (row['planting_date'] == null) {
      throw Exception('No planting date set. Please complete your profile first.');
    }
    if (row['is_crop_planted'] == false) {
      throw Exception('Crop has not been planted yet. Update your profile to continue.');
    }

    final plantingDate = DateTime.parse(row['planting_date'] as String);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final plantDate = DateTime(plantingDate.year, plantingDate.month, plantingDate.day);
    
    // Use targetDay if provided (for navigating history), else calculate today
    final day = targetDay ?? (todayDate.difference(plantDate).inDays + 1).clamp(1, 109);

    return {
      'user_id': userId,
      'day': day,
      'lat': (row['latitude'] as num?)?.toDouble() ?? 0.0,
      'lon': (row['longitude'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // ------------------------------------------------------------------
  // getDailyRecommendation
  // Calls the single deployed edge function with action='recommend',
  // and merges with local asset data for stage and nutrients.
  // ------------------------------------------------------------------
  Future<RecommendationResponse> getDailyRecommendation({int? targetDay}) async {
    try {
      final profile = await _readProfile(targetDay: targetDay);
      final int dayNum = profile['day'];

      // 1. Load local baseline data (Stage/Nutrients/Water fallback)
      String localStage = 'Emergence';
      String localNutrients = 'None';
      String localWater = '0 ml';
      try {
        final text = await rootBundle.loadString('assets/Data/day$dayNum/day$dayNum.txt');
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.contains('stage:')) localStage = line.split('stage:')[1].trim();
          if (line.contains('requirement:')) localWater = line.split('requirement:')[1].trim();
          if (line.contains('application:')) localNutrients = line.split('application:')[1].trim();
        }
      } catch (e) {
        debugPrint('RecommendationService: Failed to load daily asset for day $dayNum: $e');
      }

      // 2. Fetch live water recommendation from Supabase
      dynamic apiData;
      try {
        debugPrint('Invoking dynamic-function for day $dayNum...');
        final response = await _supabase.functions.invoke(
          'dynamic-function',
          body: {
            'action': 'recommend',
            'user_id': profile['user_id'],
            'day': dayNum,
            'lat': profile['lat'],
            'lon': profile['lon'],
          },
        );

        if (response.status == 200 && response.data != null) {
          apiData = response.data;
          debugPrint('✅ SUCCESS! Received from Supabase: $apiData');
        } else {
          debugPrint('Recommendation error (Status ${response.status}): ${response.data}');
        }
      } catch (e) {
        debugPrint('Recommendation fetch failed: $e');
      }

      // 3. Construct merged response
      if (apiData != null) {
        final apiRec = RecommendationResponse.fromJson(Map<String, dynamic>.from(apiData as Map));
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage, // Local anchor
          waterRequirement: apiRec.waterRequirement, // Dynamic live value
          nutrientApplication: localNutrients, // Local anchor
        );
      } else {
        // Fallback to local data if API fails
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage,
          waterRequirement: localWater,
          nutrientApplication: localNutrients,
        );
      }
    } catch (e) {
      debugPrint('Error in getDailyRecommendation: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // updateCarryBalance
  // Called after plant_daily_log insert.
  // Converts water_amount + water_unit to ml before sending.
  // ------------------------------------------------------------------
  Future<void> updateCarryBalance({
    required num waterAmount,
    required String? waterUnit,
    required bool watered,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // If farmer marked watered=false, send 0 regardless of amount field
    final double actualMl = watered ? _toMl(waterAmount, waterUnit) : 0.0;

    try {
      debugPrint('Updating carry balance for user $userId with $actualMl ml...');
      
      final response = await _supabase.functions.invoke(
        'dynamic-function',
        body: {
          'action': 'update_balance',
          'user_id': userId,
          'actual_watered_ml': actualMl,
        },
      );

      if (response.status != 200) {
        debugPrint('updateCarryBalance failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error in updateCarryBalance: $e');
    }
  }
}
