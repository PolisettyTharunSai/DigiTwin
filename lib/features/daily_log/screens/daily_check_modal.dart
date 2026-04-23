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

/// Bottom-sheet modal for the daily plant health check.
/// Allows the farmer to log watering, observations, photos, and notes.
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
  final TextEditingController _feedbackController = TextEditingController();
  List<dynamic> _images = [];

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _alreadySubmittedToday = false;
  bool _isEditing = false;
  bool _isCheckingStatus = true;

  Map<String, dynamic>? _existingLogData;

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
    _feedbackController.dispose();
    super.dispose();
  }

  // ── Logic ─────────────────────────────────────────────────────────────────

  /// Checks SharedPreferences and then Supabase to determine if today's log exists.
  Future<void> _checkSubmissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? cached = prefs.getBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED);

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
            _existingLogData = response;

            // Pre-fill form fields with existing data
            watered = response['watered'];
            if (watered == true) {
              _waterAmountController.text =
                  response['water_amount']?.toString() ?? '';
              _selectedWaterUnit = response['water_unit'] ?? 'ml';
            }
            pestsObserved = response['pests_observed'] ?? false;
            _pestNotesController.text = response['pest_notes'] ?? '';
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

  /// Validates, uploads images, and submits (or updates) the daily log.
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

      // Upload new images; keep existing URL strings as-is
      final List<String> imageUrls = [];
      for (final image in _images) {
        if (image is String) {
          imageUrls.add(image);
        } else if (image is XFile) {
          final fileName =
              'public/${user.id}/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
          await supabase.storage.from(AppConstants.STORAGE_BUCKET_MODELS).upload(
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

      // Delete old photos that were removed during editing
      if (_alreadySubmittedToday && _existingLogData != null) {
        final List<String> oldImages =
            List<String>.from(_existingLogData!['images'] ?? []);
        final toDelete = oldImages.where((u) => !imageUrls.contains(u));

        for (final url in toDelete) {
          try {
            final storagePath =
                url.split('${AppConstants.STORAGE_BUCKET_MODELS}/').last;
            await supabase.storage
                .from(AppConstants.STORAGE_BUCKET_MODELS)
                .remove([storagePath]);
          } catch (e) {
            debugPrint('DailyCheckModal: Error deleting old image — $e');
          }
        }
      }

      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final double? waterAmountValue = double.tryParse(_waterAmountController.text);
      final bool isWatered = watered ?? false;

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
      };

      // Use DailyLogService to submit, which handles the carry balance update internally.
      await DailyLogService.instance.submitLog(logData);

      // Update local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.PREF_LAST_DAILY_CHECK_DATE, today);
      await prefs.setBool(AppConstants.PREF_HAS_TODAY_LOG_SUBMITTED, true);

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar(
          _alreadySubmittedToday
              ? 'Daily log updated successfully!'
              : 'Daily log submitted successfully!',
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

            // Already-submitted warning banner
            if (_alreadySubmittedToday) _buildAlreadySubmittedBanner(),

            const SizedBox(height: 16),

            // Form sections (only when submitting or editing)
            if (!_alreadySubmittedToday || _isEditing) ...[
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
              _buildFeedbackSection(),
              const SizedBox(height: 14),
              _buildPhotoSection(),
              const SizedBox(height: 26),
            ],

            // Submit / Edit button
            _buildSubmitButton(),
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
            color: AppColors.primary.withOpacity(0.12),
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
                  const Expanded(
                    child: Text(
                      'Daily Plant Check',
                      style: TextStyle(
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
                "Log today's care, water, and observations.",
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

  Widget _buildAlreadySubmittedBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have already submitted a log for today. '
              'Submitting again will update your existing entry.',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
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
                          ? Image.network(img, width: 82, height: 82, fit: BoxFit.cover)
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
                          child: Icon(Icons.close, size: 12, color: Colors.white),
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
      child: _isCheckingStatus
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : (_alreadySubmittedToday && !_isEditing
                      ? () => setState(() => _isEditing = true)
                      : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _alreadySubmittedToday
                          ? (_isEditing
                              ? "Update Today's Log"
                              : "Edit today's log")
                          : "Submit Today's Log",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
    );
  }
}
