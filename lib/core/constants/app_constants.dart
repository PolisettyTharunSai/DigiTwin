/// App-wide constants for the DigiTwin project.
class AppConstants {
  AppConstants._();

  // ── Plantation cycle ──────────────────────────────────────────────────────
  /// Total number of days in the crop growth cycle.
  static const int TOTAL_CROP_DAYS = 109;

  /// Days before which no visual data (images/3D) is available.
  static const int VISUAL_DATA_START_DAY = 30;

  /// The real-world date corresponding to Day 31 (adjustedDay = 1) in the dataset.
  static const String DATASET_START_DATE = '2025-12-10';

  // ── CDN / Asset URLs ──────────────────────────────────────────────────────
  /// Base URL for extracted frame images (2D carousel).
  static const String IMAGE_BASE_URL =
      'https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/Data/potato_extracted_frames_comp';

  /// Base URL for 3D GLB model files.
  static const String MODEL_BASE_URL =
      'https://raw.githubusercontent.com/PolisettyTharunSai/DigiTwin/Data/models';

  /// Total number of images per day in the carousel.
  static const int IMAGES_PER_DAY = 10;

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const String PREF_FARMER_NAME = 'farmerName';
  static const String PREF_PLANTING_DATE = 'plantingDate';
  static const String PREF_IS_CROP_PLANTED = 'isCropPlanted';
  static const String PREF_PLANTING_DATA = 'plantingData';
  static const String PREF_LAST_DAILY_CHECK_DATE = 'last_daily_check_date';
  static const String PREF_HAS_TODAY_LOG_SUBMITTED = 'has_today_log_submitted';

  // ── Supabase table / bucket names ─────────────────────────────────────────
  static const String TABLE_PROFILE = 'profile';
  static const String TABLE_PLANT_DAILY_LOG = 'plant_daily_log';
  static const String STORAGE_BUCKET_MODELS = 'models';
}
