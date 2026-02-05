import 'dart:convert';

class PlantingData {
  final String farmerName;
  final String crop;
  final String date;
  final double latitude;
  final double longitude;
  final bool isExact;
  final String notes;

  PlantingData({
    required this.farmerName,
    required this.crop,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.isExact,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'farmerName': farmerName,
      'crop': crop,
      'date': date,
      'latitude': latitude,
      'longitude': longitude,
      'isExact': isExact,
      'notes': notes,
    };
  }

  factory PlantingData.fromJson(Map<String, dynamic> json) {
    return PlantingData(
      farmerName: json['farmerName'] ?? '',
      crop: json['crop'] ?? 'Wheat',
      date: json['date'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isExact: json['isExact'] ?? true,
      notes: json['notes'] ?? '',
    );
  }
}
