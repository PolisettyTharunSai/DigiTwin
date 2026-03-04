/// Holds all per-day data displayed on the HomeScreen.
class DayData {
  /// Raw text content loaded from the assets bundle for this day.
  final String rawText;

  /// Parsed crop stage (e.g. "Emergence").
  final String stage;

  /// Parsed water requirement string (e.g. "200 ml/plant").
  final String water;

  /// Parsed nutrient application string.
  final String nutrients;

  const DayData({
    required this.rawText,
    required this.stage,
    required this.water,
    required this.nutrients,
  });

  /// Parses a raw day-text string into structured [DayData].
  factory DayData.fromRawText(String text) {
    final lines = text.split('\n');
    String stage = 'Emergence';
    String water = '0 ml';
    String nutrients = 'None';

    for (final line in lines) {
      if (line.contains('stage:')) stage = line.split('stage:')[1].trim();
      if (line.contains('requirement:')) water = line.split('requirement:')[1].trim();
      if (line.contains('application:')) nutrients = line.split('application:')[1].trim();
    }

    return DayData(
      rawText: text,
      stage: stage,
      water: water,
      nutrients: nutrients,
    );
  }

  /// Fallback [DayData] returned when the assets file cannot be found.
  factory DayData.fallback() {
    return DayData.fromRawText(
      '• Crop stage: Emergence (Germination)\n'
      '• Water requirement: 0 ml/plant\n'
      '• Nutrient application: None',
    );
  }
}
