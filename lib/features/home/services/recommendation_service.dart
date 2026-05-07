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

  /// Single edge function used for both recommend + update_balance actions.
  static const String _functionName = 'dynamic-function';

  // ── Profile ──────────────────────────────────────────────────────────────

  /// Reads planting_date + is_crop_planted from the profile table.
  /// Returns user_id, the resolved crop day (1-based, clamped), and
  /// the raw planting_date for internal use.
  Future<Map<String, dynamic>> _readProfile({int? targetDay}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final row = await _supabase
        .from('profile')
        .select('planting_date, is_crop_planted')
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

  // ── Nutrient helpers (all private) ───────────────────────────────────────

  Future<List<NutrientScheduleEntry>> _loadNutrientSchedule(
      int upToDay,
      ) async {
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
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
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

  /// Runs the NutrientRecommendationEngine for [day].
  /// Priority: Supabase schedule → CSV asset.
  /// Throws if neither source yields any data.
  Future<NutrientDayState> _computeNutrientState(
      String userId,
      int day, {
        double? overrideN,
        double? overrideP,
        double? overrideK,
      }) async {
    var schedule = <NutrientScheduleEntry>[];

    // 1. Try Supabase
    try {
      schedule = await _loadNutrientSchedule(day);
    } catch (e) {
      debugPrint(
        'RecommendationService: Supabase nutrient schedule failed: $e',
      );
    }

    // 2. Fall back to bundled CSV asset
    if (schedule.isEmpty) {
      try {
        schedule = await _loadNutrientScheduleFromCsvAsset(day);
      } catch (e) {
        debugPrint(
          'RecommendationService: CSV nutrient asset fallback failed: $e',
        );
      }
    }

    if (schedule.isEmpty) {
      throw Exception(
        'No nutrient schedule found in Supabase or local CSV asset.',
      );
    }

    var applied = await _loadAppliedLogs(userId, day);

    // If overrides are provided, we assume they are for the target 'day'.
    if (overrideN != null || overrideP != null || overrideK != null) {
      applied = applied.where((e) => e.day != day).toList();
      applied.add(NutrientAppliedEntry(
        day: day,
        n: overrideN ?? 0.0,
        p: overrideP ?? 0.0,
        k: overrideK ?? 0.0,
      ));
    }

    final engine = NutrientRecommendationEngine();
    return engine.computeForDay(
      targetDay: day,
      schedule: schedule,
      applied: applied,
    );
  }

  /// Converts a [NutrientDayState] into a human-readable string.
  String _buildNutrientText(NutrientDayState state) {
    final allZero =
        state.recommendedN == 0 &&
            state.recommendedP == 0 &&
            state.recommendedK == 0;

    if (allZero) {
      return 'No nutrient application required today. '
          'Carry: N ${state.carryN} g, P2O5 ${state.carryP} g, K2O ${state.carryK} g.';
    }

    final sourceText =
    state.fertilizerSource.trim().isEmpty ||
        state.fertilizerSource.toLowerCase() == 'none'
        ? ''
        : ' Source: ${state.fertilizerSource}.';

    return 'Apply N ${state.recommendedN} g, P2O5 ${state.recommendedP} g, '
        'K2O ${state.recommendedK} g.$sourceText '
        'Carry after application (if exactly followed): '
        'N ${state.carryN} g, P2O5 ${state.carryP} g, K2O ${state.carryK} g.';
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns the crop day (1-based) for a specific [date].
  Future<int> getCropDayForDate(DateTime date) async {
    final profile = await _readProfile();
    final plantingDate = profile['planting_date'] as DateTime;
    return _calculateCropDay(plantingDate, referenceDate: date);
  }

  /// Public wrapper for computing nutrient state, allowing for value overrides.
  Future<NutrientDayState> computeNutrientStateForDay({
    required int day,
    double? overrideAppliedN,
    double? overrideAppliedP,
    double? overrideAppliedK,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    return _computeNutrientState(
      userId,
      day,
      overrideN: overrideAppliedN,
      overrideP: overrideAppliedP,
      overrideK: overrideAppliedK,
    );
  }

  /// Returns today's (or a historical [targetDay]'s) recommendation.
  ///
  /// Data sources in priority order:
  ///   • Stage      → local .txt asset (always)
  ///   • Water      → edge function live value  →  local .txt asset
  ///   • Nutrients  → NutrientRecommendationEngine (Supabase → CSV)
  ///                   → local .txt asset as last resort
  Future<RecommendationResponse> getDailyRecommendation({
    int? targetDay,
  }) async {
    try {
      final profile = await _readProfile(targetDay: targetDay);
      final int dayNum = profile['day'];
      final String userId = profile['user_id'];

      // ── Step 1: Local .txt asset (stage + fallback water/nutrients) ──────
      String localStage = 'Emergence';
      String localWater = '0 ml';
      String localNutrients = 'No nutrient application required today.';
      try {
        final text = await rootBundle.loadString(
          'assets/Data/day$dayNum/day$dayNum.txt',
        );
        for (final line in text.split('\n')) {
          if (line.contains('stage:')) {
            localStage = line.split('stage:')[1].trim();
          }
          if (line.contains('requirement:')) {
            localWater = line.split('requirement:')[1].trim();
          }
          if (line.contains('application:')) {
            localNutrients = line.split('application:')[1].trim();
          }
        }
      } catch (e) {
        debugPrint(
          'RecommendationService: No .txt asset for day $dayNum — using defaults.',
        );
      }

      // ── Step 2: Nutrient engine (Supabase/CSV → .txt fallback) ──────────
      String nutrientText = localNutrients; // start with .txt fallback
      try {
        final state = await _computeNutrientState(userId, dayNum);
        nutrientText = _buildNutrientText(state); // overwrite only on success
      } catch (e) {
        debugPrint(
          'RecommendationService: Nutrient engine failed — using .txt fallback: $e',
        );
      }

      // ── Step 3: Live water from edge function ────────────────────────────
      debugPrint('═══ RecommendationService.getDailyRecommendation ═══');
      debugPrint(
        '📤 Sending to $_functionName: action=recommend, '
            'user_id=$userId, day=$dayNum, is_today=${targetDay == null}',
      );

      dynamic apiData;
      try {
        final response = await _supabase.functions.invoke(
          _functionName,
          body: {
            'action': 'recommend',
            'user_id': userId,
            'day': dayNum,
            'is_today': targetDay == null,
          },
        );

        debugPrint(
          '📥 $_functionName response status: ${response.status}',
        );
        debugPrint(
          '📥 $_functionName response data: ${response.data}',
        );

        if (response.status == 200 && response.data != null) {
          apiData = response.data;
          debugPrint('✅ SUCCESS! Received from Supabase: $apiData');
        } else {
          debugPrint(
            '❌ Recommendation error (Status ${response.status}): ${response.data}',
          );
        }
      } catch (e) {
        debugPrint('❌ Recommendation fetch failed — using local water: $e');
      }

      // ── Step 4: Build merged response ────────────────────────────────────
      final liveWater = apiData != null
          ? RecommendationResponse.fromJson(
        Map<String, dynamic>.from(apiData as Map),
      ).waterRequirement
          : localWater;

      return RecommendationResponse(
        day: dayNum.toString(),
        cropStage: localStage,       // always local
        waterRequirement: liveWater, // live → local fallback
        nutrientApplication: nutrientText, // engine → .txt fallback
      );
    } catch (e) {
      debugPrint('❌ Error in getDailyRecommendation: $e');
      rethrow;
    }
  }

  /// Called after a plant_daily_log insert to update the irrigation
  /// carry balance on the edge function.
  ///
  /// Converts [waterAmount] + [waterUnit] to ml before sending.
  /// Sends 0 ml when [watered] is false regardless of amount.
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
      debugPrint(
        '📤 Sending to $_functionName: action=update_balance, '
            'user_id=$userId, actual_watered_ml=$actualMl',
      );

      final response = await _supabase.functions.invoke(
        _functionName,
        body: {
          'action': 'update_balance',
          'user_id': userId,
          'actual_watered_ml': actualMl,
        },
      );

      debugPrint(
        '📥 update_balance response status: ${response.status}',
      );
      debugPrint(
        '📥 update_balance response data: ${response.data}',
      );

      if (response.status != 200) {
        debugPrint('❌ updateCarryBalance failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Error in updateCarryBalance: $e');
    }
  }
}
