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

  // Change this to match exactly what you named your function during deployment
  static const String _functionName = 'dynamic-function';

  // Reads profile to calculate the crop day number (1-based, clamped 1–109).
  Future<Map<String, dynamic>> _readProfile({int? targetDay}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final row = await _supabase
        .from('profile')
        .select('planting_date, is_crop_planted')
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
    };
  }

  // ------------------------------------------------------------------
  // getDailyRecommendation
  // Calls the edge function with action='recommend'.
  // Merges live water value with local asset labels for stage/nutrients.
  // ------------------------------------------------------------------
  Future<RecommendationResponse> getDailyRecommendation({int? targetDay}) async {
    try {
      final profile = await _readProfile(targetDay: targetDay);
      final int dayNum = profile['day'];

      // 1. Load local baseline data
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
        debugPrint('RecommendationService: No asset for day $dayNum');
      }

      // 2. Fetch live data from Supabase
      dynamic apiData;
      try {
        debugPrint('═══ RecommendationService.getDailyRecommendation ═══');
        debugPrint('📤 Sending to $_functionName: action=recommend, user_id=${profile['user_id']}, day=$dayNum, is_today=${targetDay == null}');

        final response = await _supabase.functions.invoke(
          _functionName,
          body: {
            'action': 'recommend',
            'user_id': profile['user_id'],
            'day': dayNum,
            'is_today': targetDay == null,
          },
        );

        debugPrint('📥 $_functionName response status: ${response.status}');
        // debugPrint('📥 $_functionName response data: ${response.data}');

        if (response.status == 200 && response.data != null) {
          apiData = response.data;
          debugPrint('✅ SUCCESS! Received from Supabase: $apiData');
        } else {
          debugPrint('❌ Recommendation error (Status ${response.status}): ${response.data}');
        }
      } catch (e) {
        debugPrint('❌ Recommendation fetch failed: $e');
      }

      if (apiData != null) {
        final apiRec = RecommendationResponse.fromJson(Map<String, dynamic>.from(apiData as Map));
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage,
          waterRequirement: apiRec.waterRequirement,
          nutrientApplication: localNutrients,
        );
      } else {
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage,
          waterRequirement: localWater,
          nutrientApplication: localNutrients,
        );
      }
    } catch (e) {
      debugPrint('❌ Error in getDailyRecommendation: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // updateCarryBalance
  // Called after plant_daily_log insert.
  // ------------------------------------------------------------------
  Future<void> updateCarryBalance({
    required num waterAmount,
    required String? waterUnit,
    required bool watered,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final double actualMl = watered ? _toMl(waterAmount, waterUnit) : 0.0;

    try {
      debugPrint('═══ RecommendationService.updateCarryBalance ═══');
      debugPrint('📤 Sending to $_functionName: action=update_balance, user_id=$userId, actual_watered_ml=$actualMl');
      
      final response = await _supabase.functions.invoke(
        _functionName,
        body: {
          'action': 'update_balance',
          'user_id': userId,
          'actual_watered_ml': actualMl,
        },
      );

      debugPrint('📥 $_functionName response status: ${response.status}');
      debugPrint('📥 $_functionName response data: ${response.data}');

      if (response.status != 200) {
        debugPrint('❌ updateCarryBalance failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error in updateCarryBalance: $e');
    }
  }
}
