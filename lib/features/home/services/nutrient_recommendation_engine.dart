import 'dart:collection';

/// Per-day nutrient schedule values loaded from Supabase.
class NutrientScheduleEntry {
  final int day;
  final double n;
  final double p;
  final double k;
  final String source;

  const NutrientScheduleEntry({
    required this.day,
    required this.n,
    required this.p,
    required this.k,
    required this.source,
  });
}

/// Nutrient amounts applied by user for a specific day.
class NutrientAppliedEntry {
  final int day;
  final double n;
  final double p;
  final double k;

  const NutrientAppliedEntry({
    required this.day,
    required this.n,
    required this.p,
    required this.k,
  });
}

/// Computation result for a target day.
class NutrientDayState {
  final int day;
  final double recommendedN;
  final double recommendedP;
  final double recommendedK;
  final double carryN;
  final double carryP;
  final double carryK;
  final String fertilizerSource;

  const NutrientDayState({
    required this.day,
    required this.recommendedN,
    required this.recommendedP,
    required this.recommendedK,
    required this.carryN,
    required this.carryP,
    required this.carryK,
    required this.fertilizerSource,
  });
}

class _PendingItem {
  double amount;
  int age;

  _PendingItem({required this.amount, required this.age});
}

/// Dart port of the provided Python nutrient algorithm.
///
/// Rules preserved exactly:
/// - FIFO pending queues per nutrient
/// - age-based decay
/// - threshold ignore and max cap on due totals
/// - daily flow: age -> enqueue schedule -> recommended -> apply -> carry
class NutrientRecommendationEngine {
  static const Map<String, double> threshold = {
    'N': 0.05,
    'P': 0.05,
    'K': 0.05,
  };

  static const Map<String, double> maxCap = {'N': 10.0, 'P': 8.0, 'K': 12.0};

  final Map<String, Queue<_PendingItem>> _history = {
    'N': Queue<_PendingItem>(),
    'P': Queue<_PendingItem>(),
    'K': Queue<_PendingItem>(),
  };

  double _decayFactor(int age) {
    if (age <= 2) return 1.0;
    if (age == 3) return 0.8;
    if (age == 4) return 0.5;
    return 0.0;
  }

  double _round4(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  void _ageAllNutrients() {
    for (final nutrient in const ['N', 'P', 'K']) {
      final agedQueue = Queue<_PendingItem>();
      for (final item in _history[nutrient]!) {
        final nextAge = item.age + 1;
        final decay = _decayFactor(nextAge);
        final nextAmount = item.amount * decay;
        if (nextAmount > 0) {
          agedQueue.add(
            _PendingItem(amount: _round4(nextAmount), age: nextAge),
          );
        }
      }
      _history[nutrient] = agedQueue;
    }
  }

  double _getTotalDue(String nutrient) {
    final queue = _history[nutrient]!;
    var total = 0.0;
    for (final item in queue) {
      total += item.amount;
    }
    total = total > maxCap[nutrient]! ? maxCap[nutrient]! : total;
    if (total < threshold[nutrient]!) return 0.0;
    return _round4(total);
  }

  void _applyNutrient(String nutrient, double appliedAmount) {
    var remaining = appliedAmount;
    final queue = _history[nutrient]!;

    while (queue.isNotEmpty && remaining > 0) {
      final oldest = queue.first;
      if (oldest.amount <= remaining) {
        remaining -= oldest.amount;
        queue.removeFirst();
      } else {
        oldest.amount = _round4(oldest.amount - remaining);
        remaining = 0;
      }
    }
  }

  NutrientDayState computeForDay({
    required int targetDay,
    required List<NutrientScheduleEntry> schedule,
    required List<NutrientAppliedEntry> applied,
  }) {
    if (targetDay < 1) {
      throw ArgumentError('targetDay must be >= 1');
    }

    final scheduleByDay = <int, NutrientScheduleEntry>{};
    for (final entry in schedule) {
      scheduleByDay[entry.day] = entry;
    }

    final appliedByDay = <int, NutrientAppliedEntry>{};
    for (final entry in applied) {
      appliedByDay[entry.day] = entry;
    }

    NutrientDayState? last;

    for (var day = 1; day <= targetDay; day++) {
      _ageAllNutrients();

      final daySchedule = scheduleByDay[day];
      final reqN = daySchedule?.n ?? 0.0;
      final reqP = daySchedule?.p ?? 0.0;
      final reqK = daySchedule?.k ?? 0.0;
      final source = daySchedule?.source ?? 'None';

      if (reqN > 0) {
        _history['N']!.add(_PendingItem(amount: reqN, age: 0));
      }
      if (reqP > 0) {
        _history['P']!.add(_PendingItem(amount: reqP, age: 0));
      }
      if (reqK > 0) {
        _history['K']!.add(_PendingItem(amount: reqK, age: 0));
      }

      final recN = _getTotalDue('N');
      final recP = _getTotalDue('P');
      final recK = _getTotalDue('K');

      final dayApplied = appliedByDay[day];
      final appliedN = dayApplied?.n ?? 0.0;
      final appliedP = dayApplied?.p ?? 0.0;
      final appliedK = dayApplied?.k ?? 0.0;

      _applyNutrient('N', appliedN);
      _applyNutrient('P', appliedP);
      _applyNutrient('K', appliedK);

      final carryN = _getTotalDue('N');
      final carryP = _getTotalDue('P');
      final carryK = _getTotalDue('K');

      last = NutrientDayState(
        day: day,
        recommendedN: recN,
        recommendedP: recP,
        recommendedK: recK,
        carryN: carryN,
        carryP: carryP,
        carryK: carryK,
        fertilizerSource: source,
      );
    }

    return last!;
  }
}
