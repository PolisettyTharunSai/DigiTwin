import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/daily_log_sections.dart';
import '../services/daily_log_service.dart';
import 'daily_log_detail_screen.dart';

/// Bottom-sheet modal for the daily plant health check.
/// Allows the farmer to log watering, observations, photos, and notes.
/// If already submitted, shows the read-only log for today.
class DailyCheckModal extends StatefulWidget {
  /// Whether today's log was already submitted (passed from HomeScreen).
  final bool initialAlreadySubmitted;

  const DailyCheckModal({super.key, required this.initialAlreadySubmitted});

  @override
  State<DailyCheckModal> createState() => _DailyCheckModalState();
}

class _DailyCheckModalState extends State<DailyCheckModal> {
  // ── Form state ────────────────────────────────────────────────────────────
  bool? watered;
  final TextEditingController _waterAmountController = TextEditingController();
  String _selectedWaterUnit = 'ml';
  bool pestsObserved = false;
  final TextEditingController _pestNotesController = TextEditingController();
  final TextEditingController _nitrogenAppliedController =
      TextEditingController();
  final TextEditingController _phosphorusAppliedController =
      TextEditingController();
  final TextEditingController _potassiumAppliedController =
      TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> _images = [];

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _alreadySubmittedToday = false;
  bool _isCheckingStatus = true;
  Map<String, dynamic>? _todayLogData;

  @override
  void initState() {
    super.initState();
    _alreadySubmittedToday = widget.initialAlreadySubmitted;
    _checkSubmissionStatus();
  }

  @override
  void dispose() {
    _waterAmountController.dispose();
    _pestNotesController.dispose();
    _nitrogenAppliedController.dispose();
    _phosphorusAppliedController.dispose();
    _potassiumAppliedController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  double _parseNonNegativeDouble(String raw) {
    final parsed = double.tryParse(raw.trim()) ?? 0.0;
    if (parsed.isNaN || parsed.isInfinite) return 0.0;
    return parsed < 0 ? 0.0 : parsed;
  }

  String _valueOrZero(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? '0' : value;
  }

  // ── Logic ─────────────────────────────────────────────────────────────────

  /// Checks SharedPreferences and then Supabase to determine if today's log exists.
  Future<void> _checkSubmissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? cached = prefs.getBool(
      AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED,
    );

    if (!_alreadySubmittedToday && cached == true) {
      if (mounted) setState(() => _alreadySubmittedToday = true);
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await supabase
          .from(AppConstants.TABLE_PLANT_DAILY_LOG)
          .select()
          .eq('user_id', user.id)
          .eq('log_date', today)
          .maybeSingle();

      if (response != null) {
        if (mounted) {
          setState(() {
            _alreadySubmittedToday = true;
            _todayLogData = response;

            // Pre-fill form fields for read-only display
            watered = response['watered'];
            if (watered == true) {
              _waterAmountController.text =
                  response['water_amount']?.toString() ?? '0';
              _selectedWaterUnit = response['water_unit'] ?? 'ml';
            }
            pestsObserved = response['pests_observed'] ?? false;
            _pestNotesController.text = response['pest_notes'] ?? '';
            _nitrogenAppliedController.text =
                response['nutrient_n_applied_g']?.toString() ?? '0';
            _phosphorusAppliedController.text =
                response['nutrient_p_applied_g']?.toString() ?? '0';
            _potassiumAppliedController.text =
                response['nutrient_k_applied_g']?.toString() ?? '0';
            _feedbackController.text = response['feedback'] ?? '';
            _images = List<dynamic>.from(response['images'] ?? []);
          });
        }
      } else if (cached == true) {
        // DB says no record but cache says submitted — reset cache
        if (mounted) setState(() => _alreadySubmittedToday = false);
        await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, false);
      }
    } catch (e) {
      debugPrint('DailyCheckModal: Error checking submission status — $e');
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  /// Opens the device image picker and appends selected images.
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.isNotEmpty && mounted) {
      setState(() => _images.addAll(picked));
    }
  }

  /// Validates, uploads images, and submits the daily log.
  Future<void> _submit() async {
    if (watered == null) {
      _showSnackBar('Please answer if you watered the plant.');
      return;
    }
    if (watered == true && _waterAmountController.text.trim().isEmpty) {
      _showSnackBar('Please enter the amount of water used.');
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Upload new images
      final List<String> imageUrls = [];
      List<int>? imageBytesForAnalysis;
      for (final image in _images) {
        if (image is String) {
          imageUrls.add(image);
        } else if (image is XFile) {
          imageBytesForAnalysis ??= await image.readAsBytes();
          final fileName =
              'public/${user.id}/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          await supabase.storage
              .from(AppConstants.STORAGE_BUCKET_MODELS)
              .upload(
                fileName,
                File(image.path),
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
          final publicUrl = supabase.storage
              .from(AppConstants.STORAGE_BUCKET_MODELS)
              .getPublicUrl(fileName);
          imageUrls.add(publicUrl);
        }
      }

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final double? waterAmountValue = double.tryParse(
        _waterAmountController.text,
      );
      final bool isWatered = watered ?? false;
      final double appliedN = _parseNonNegativeDouble(
        _nitrogenAppliedController.text,
      );
      final double appliedP = _parseNonNegativeDouble(
        _phosphorusAppliedController.text,
      );
      final double appliedK = _parseNonNegativeDouble(
        _potassiumAppliedController.text,
      );

      final logData = {
        'user_id': user.id,
        'log_date': today,
        'watered': isWatered,
        'pests_observed': pestsObserved,
        'pest_notes': _pestNotesController.text,
        'feedback': _feedbackController.text,
        'images': imageUrls,
        'water_amount': isWatered ? waterAmountValue : null,
        'water_unit': isWatered ? _selectedWaterUnit : null,
        'nutrient_n_applied_g': appliedN,
        'nutrient_p_applied_g': appliedP,
        'nutrient_k_applied_g': appliedK,
      };

      await DailyLogService.instance.submitLog(
        logData,
        imageBytes: imageBytesForAnalysis,
      );

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
      await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, true);

      if (mounted) {
        // Instead of popping, we could show the read-only view immediately.
        // But for simplicity and UI flow consistency, we pop and let the HomeScreen
        // re-trigger or update. Alternatively, we just set the state here.
        setState(() {
          _alreadySubmittedToday = true;
          _isSubmitting = false;
          _images = imageUrls;
          _todayLogData = logData;
        });
        _showSnackBar('Daily log submitted successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal header
            _buildModalHeader(),

            if (_isCheckingStatus)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_alreadySubmittedToday)
              _buildReadOnlyView()
            else ...[
              const SizedBox(height: 16),
              WateringSection(
                watered: watered,
                waterAmountController: _waterAmountController,
                selectedWaterUnit: _selectedWaterUnit,
                onWateredChanged: (val) {
                  if (mounted) setState(() => watered = val);
                },
                onUnitChanged: (val) {
                  if (mounted) setState(() => _selectedWaterUnit = val);
                },
              ),
              const SizedBox(height: 14),
              ObservationSection(
                pestsObserved: pestsObserved,
                pestNotesController: _pestNotesController,
                onPestsChanged: (val) {
                  if (mounted) setState(() => pestsObserved = val);
                },
              ),
              const SizedBox(height: 14),
              NutrientApplicationSection(
                nitrogenController: _nitrogenAppliedController,
                phosphorusController: _phosphorusAppliedController,
                potassiumController: _potassiumAppliedController,
              ),
              const SizedBox(height: 14),
              _buildFeedbackSection(),
              const SizedBox(height: 14),
              _buildPhotoSection(),
              const SizedBox(height: 26),
              _buildSubmitButton(),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildModalHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_florist, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _alreadySubmittedToday
                          ? 'Today\'s Log'
                          : 'Daily Plant Check',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _alreadySubmittedToday
                    ? "Here is what you logged for today."
                    : "Log today's care, water, and observations.",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSuccessBanner(),
        const SizedBox(height: 20),

        _buildInfoRow(
          'Watered',
          (watered ?? false)
              ? 'Yes, ${_waterAmountController.text} $_selectedWaterUnit'
              : 'No',
        ),
        const SizedBox(height: 16),

        _buildInfoRow('Pests Observed', pestsObserved ? 'Yes' : 'No'),
        if (pestsObserved && _pestNotesController.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Notes: ${_pestNotesController.text}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
        const SizedBox(height: 16),

        _buildInfoRow(
          'Nutrients Applied',
          'N: ${_valueOrZero(_nitrogenAppliedController)}g, '
              'P: ${_valueOrZero(_phosphorusAppliedController)}g, '
              'K: ${_valueOrZero(_potassiumAppliedController)}g',
        ),
        const SizedBox(height: 16),

        if (_feedbackController.text.isNotEmpty) ...[
          _buildInfoRow('Feedback', _feedbackController.text),
          const SizedBox(height: 16),
        ],

        if (_images.isNotEmpty) ...[
          const Text(
            'Photos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final img = _images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildReadOnlyImage(img),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (_canOpenAnalysisSummary) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _openAnalysisSummary,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('View AI Summary'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _canOpenAnalysisSummary {
    final status = _todayLogData?['image_analysis_status']
        ?.toString()
        .toLowerCase()
        .trim();
    return status == 'completed';
  }

  void _openAnalysisSummary() {
    final log = _todayLogData;
    if (log == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyLogDetailScreen(log: log)),
    );
  }

  Widget _buildReadOnlyImage(dynamic img) {
    if (img is String) {
      return Image.network(
        img,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _brokenImageBox(),
      );
    }

    if (img is XFile) {
      return Image.file(
        File(img.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _brokenImageBox(),
      );
    }

    return _brokenImageBox();
  }

  Widget _brokenImageBox() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Daily log submitted successfully!',
              style: TextStyle(
                color: Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback / Notes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              hintText: "How's your plant doing overall?",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return frostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Photos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._images.map(
                (img) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: img is String
                          ? Image.network(
                              img,
                              width: 82,
                              height: 82,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File((img as XFile).path),
                              width: 82,
                              height: 82,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) setState(() => _images.remove(img));
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Add-photo button
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(Icons.add_a_photo, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Submit Today's Log",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
