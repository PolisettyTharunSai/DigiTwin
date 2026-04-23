import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import 'nutrient_recommendation_engine.dart';

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
      throw Exception(
        'No planting date set. Please complete your profile first.',
      );
    }
    if (row['is_crop_planted'] == false) {
      throw Exception(
        'Crop has not been planted yet. Update your profile to continue.',
      );
    }

    final plantingDate = DateTime.parse(row['planting_date'] as String);
    final day = targetDay ?? _calculateCropDay(plantingDate);

    return {
      'user_id': userId,
      'day': day,
      'planting_date': plantingDate,
      // Note: We no longer send lat/lon from the app as the Edge Function
      // will fetch them directly from the profile table for better data integrity.
    };
  }

  int _calculateCropDay(DateTime plantingDate, {DateTime? referenceDate}) {
    final today = referenceDate ?? DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final plantDate = DateTime(
      plantingDate.year,
      plantingDate.month,
      plantingDate.day,
    );
    final raw = todayDate.difference(plantDate).inDays + 1;
    return raw.clamp(1, AppConstants.TOTAL_CROP_DAYS);
  }

  Future<int> getCropDayForDate(DateTime date) async {
    final profile = await _readProfile();
    final plantingDate = profile['planting_date'] as DateTime;
    return _calculateCropDay(plantingDate, referenceDate: date);
  }

  Future<List<NutrientScheduleEntry>> _loadNutrientSchedule(int upToDay) async {
    final rows = await _supabase
        .from(AppConstants.TABLE_NUTRIENT_SCHEDULE)
        .select('day, n_g, p_g, k_g, fertilizer_source')
        .lte('day', upToDay)
        .order('day', ascending: true);

    return (rows as List)
        .map(
          (row) => NutrientScheduleEntry(
            day: (row['day'] as num).toInt(),
            n: ((row['n_g'] ?? 0) as num).toDouble(),
            p: ((row['p_g'] ?? 0) as num).toDouble(),
            k: ((row['k_g'] ?? 0) as num).toDouble(),
            source: (row['fertilizer_source'] ?? 'None').toString(),
          ),
        )
        .toList();
  }

  Future<List<NutrientScheduleEntry>> _loadNutrientScheduleFromCsvAsset(
    int upToDay,
  ) async {
    final csv = await rootBundle.loadString('potato_nutrients.csv');
    final lines = csv
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    final schedule = <NutrientScheduleEntry>[];
    for (var i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',');
      if (parts.length < 5) continue;

      final day = int.tryParse(parts[0].trim());
      if (day == null || day > upToDay) continue;

      schedule.add(
        NutrientScheduleEntry(
          day: day,
          n: double.tryParse(parts[1].trim()) ?? 0.0,
          p: double.tryParse(parts[2].trim()) ?? 0.0,
          k: double.tryParse(parts[3].trim()) ?? 0.0,
          source: parts[4].trim().isEmpty ? 'None' : parts[4].trim(),
        ),
      );
    }

    return schedule;
  }

  Future<List<NutrientAppliedEntry>> _loadAppliedLogs(
    String userId,
    int upToDay,
  ) async {
    final rows = await _supabase
        .from(AppConstants.TABLE_PLANT_DAILY_LOG)
        .select(
          'day_number, nutrient_n_applied_g, nutrient_p_applied_g, nutrient_k_applied_g',
        )
        .eq('user_id', userId)
        .lte('day_number', upToDay);

    final byDay = <int, NutrientAppliedEntry>{};
    for (final row in (rows as List)) {
      final dayVal = row['day_number'];
      if (dayVal == null) continue;
      final day = (dayVal as num).toInt();
      byDay[day] = NutrientAppliedEntry(
        day: day,
        n: ((row['nutrient_n_applied_g'] ?? 0) as num).toDouble(),
        p: ((row['nutrient_p_applied_g'] ?? 0) as num).toDouble(),
        k: ((row['nutrient_k_applied_g'] ?? 0) as num).toDouble(),
      );
    }

    return byDay.values.toList();
  }

  Future<NutrientDayState> computeNutrientStateForDay({
    required int day,
    double? overrideAppliedN,
    double? overrideAppliedP,
    double? overrideAppliedK,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    var schedule = <NutrientScheduleEntry>[];
    try {
      schedule = await _loadNutrientSchedule(day);
    } catch (e) {
      debugPrint(
        'RecommendationService: Supabase nutrient schedule load failed: $e',
      );
    }

    if (schedule.isEmpty) {
      try {
        schedule = await _loadNutrientScheduleFromCsvAsset(day);
      } catch (e) {
        debugPrint(
          'RecommendationService: CSV nutrient schedule fallback failed: $e',
        );
      }
    }

    if (schedule.isEmpty) {
      throw Exception(
        'No nutrient schedule found in Supabase or local CSV fallback.',
      );
    }

    final applied = await _loadAppliedLogs(userId, day);
    final appliedByDay = <int, NutrientAppliedEntry>{
      for (final entry in applied) entry.day: entry,
    };

    final hasOverride =
        overrideAppliedN != null ||
        overrideAppliedP != null ||
        overrideAppliedK != null;
    if (hasOverride) {
      appliedByDay[day] = NutrientAppliedEntry(
        day: day,
        n: (overrideAppliedN ?? 0).toDouble(),
        p: (overrideAppliedP ?? 0).toDouble(),
        k: (overrideAppliedK ?? 0).toDouble(),
      );
    }

    final engine = NutrientRecommendationEngine();
    final state = engine.computeForDay(
      targetDay: day,
      schedule: schedule,
      applied: appliedByDay.values.toList(),
    );

    try {
      await _supabase.from(AppConstants.TABLE_NUTRIENT_DAILY_STATE).upsert({
        'user_id': userId,
        'day_number': day,
        'recommended_n_g': state.recommendedN,
        'recommended_p_g': state.recommendedP,
        'recommended_k_g': state.recommendedK,
        'carry_n_g': state.carryN,
        'carry_p_g': state.carryP,
        'carry_k_g': state.carryK,
        'fertilizer_source': state.fertilizerSource,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,day_number');
    } catch (e) {
      debugPrint('RecommendationService: Could not persist nutrient state: $e');
    }

    return state;
  }

  String buildNutrientRecommendationText(NutrientDayState state) {
    final allZero =
        state.recommendedN == 0 &&
        state.recommendedP == 0 &&
        state.recommendedK == 0;
    if (allZero) {
      return 'No nutrient application required today. Carry: N ${state.carryN} g, P2O5 ${state.carryP} g, K2O ${state.carryK} g.';
    }

    final sourceText =
        state.fertilizerSource.trim().isEmpty ||
            state.fertilizerSource.toLowerCase() == 'none'
        ? ''
        : ' Source: ${state.fertilizerSource}.';

    return 'Apply N ${state.recommendedN} g, P2O5 ${state.recommendedP} g, K2O ${state.recommendedK} g.$sourceText Carry after application (if exactly followed): N ${state.carryN} g, P2O5 ${state.carryP} g, K2O ${state.carryK} g.';
  }

  // ------------------------------------------------------------------
  // getDailyRecommendation
  // Calls the single deployed edge function with action='recommend',
  // and merges with local asset data for stage and nutrients.
  // ------------------------------------------------------------------
  Future<RecommendationResponse> getDailyRecommendation({
    int? targetDay,
  }) async {
    try {
      final profile = await _readProfile(targetDay: targetDay);
      final int dayNum = profile['day'];

      // 1. Load local baseline data (Stage/Water fallback)
      String localStage = 'Emergence';
      String localWater = '0 ml';
      try {
        final text = await rootBundle.loadString(
          'assets/Data/day$dayNum/day$dayNum.txt',
        );
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.contains('stage:')) {
            localStage = line.split('stage:')[1].trim();
          }
          if (line.contains('requirement:')) {
            localWater = line.split('requirement:')[1].trim();
          }
        }
      } catch (e) {
        debugPrint(
          'RecommendationService: Failed to load daily asset for day $dayNum: $e',
        );
      }

      // 2. Compute nutrient recommendation using Supabase-backed algorithm
      String nutrientText = 'No nutrient application required today.';
      try {
        final nutrientState = await computeNutrientStateForDay(day: dayNum);
        nutrientText = buildNutrientRecommendationText(nutrientState);
      } catch (e) {
        debugPrint('RecommendationService: Nutrient computation failed: $e');
        nutrientText = 'Nutrient recommendation is temporarily unavailable.';
      }

      // 3. Fetch live water recommendation from Supabase
      dynamic apiData;
      try {
        debugPrint('═══ RecommendationService.getDailyRecommendation ═══');
        debugPrint(
          '📤 Sending to dynamic-function: action=recommend, user_id=${profile['user_id']}, day=$dayNum, is_today=${targetDay == null}',
        );

        final response = await _supabase.functions.invoke(
          'irrigation-recommendation',
          body: {
            'action': 'recommend',
            'user_id': profile['user_id'],
            'day': dayNum,
            'is_today': targetDay == null,
          },
        );

        debugPrint('📥 recommend response status: ${response.status}');
        debugPrint('📥 recommend response data: ${response.data}');

        if (response.status == 200 && response.data != null) {
          apiData = response.data;
          debugPrint('✅ SUCCESS! Received from Supabase: $apiData');
        } else {
          debugPrint(
            '❌ Recommendation error (Status ${response.status}): ${response.data}',
          );
        }
      } catch (e) {
        debugPrint('❌ Recommendation fetch failed: $e');
      }

      // 4. Construct merged response
      if (apiData != null) {
        final apiRec = RecommendationResponse.fromJson(
          Map<String, dynamic>.from(apiData as Map),
        );
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage, // Local anchor
          waterRequirement: apiRec.waterRequirement, // Dynamic live value
          nutrientApplication: nutrientText,
        );
      } else {
        // Fallback to local data if API fails
        return RecommendationResponse(
          day: dayNum.toString(),
          cropStage: localStage,
          waterRequirement: localWater,
          nutrientApplication: nutrientText,
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
      debugPrint('═══ RecommendationService.updateCarryBalance ═══');
      debugPrint(
        '📤 Sending to dynamic-function: action=update_balance, user_id=$userId, actual_watered_ml=$actualMl',
      );

      final response = await _supabase.functions.invoke(
        'dynamic-function',
        body: {
          'action': 'update_balance',
          'user_id': userId,
          'actual_watered_ml': actualMl,
        },
      );

      debugPrint('📥 update_balance response status: ${response.status}');
      debugPrint('📥 update_balance response data: ${response.data}');

      if (response.status != 200) {
        debugPrint('❌ updateCarryBalance failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error in updateCarryBalance: $e');
    }
  }
}
