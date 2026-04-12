// MANUAL SETUP REQUIRED before running:
// 1. Supabase Dashboard → Storage → Create bucket named 'avatars' → set to Public
// 2. Storage → Policies → avatars bucket → add policies:
//    SELECT: true (public read)
//    INSERT: auth.uid()::text = (storage.foldername(name))[1]
//    UPDATE: auth.uid()::text = (storage.foldername(name))[1]
//    DELETE: auth.uid()::text = (storage.foldername(name))[1]
// 3. SQL Editor → run: ALTER TABLE public.profile ADD COLUMN IF NOT EXISTS avatar_url text;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/day_utils.dart';
import '../../../core/services/avatar_service.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../onboarding/screens/get_started_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('profile')
          .select()
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _profile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final file = File(pickedFile.path);
      final publicUrl = await AvatarService.uploadAvatar(userId, file);

      if (mounted) {
        setState(() {
          _profile!['avatar_url'] = publicUrl;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading avatar: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile'), backgroundColor: AppColors.primary),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile'), backgroundColor: AppColors.primary),
        body: const Center(child: Text('Profile not found')),
      );
    }

    final String name = _profile!['name'] ?? 'User';
    final String email = _profile!['email'] ?? 'No email';
    final String? avatarUrl = _profile!['avatar_url'];
    final bool isPlanted = _profile!['is_crop_planted'] == true;
    
    int currentDay = 0;
    if (isPlanted && _profile!['planting_date'] != null) {
      try {
        currentDay = DayUtils.calculateTodayDay(DateTime.parse(_profile!['planting_date']));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      UserAvatar(
                        avatarUrl: avatarUrl,
                        name: name,
                        radius: 48,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
            Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _infoRow(Icons.agriculture, 'Crop', _profile!['crop'] ?? 'Not set'),
            _infoRow(Icons.calendar_today, 'Planting Date', 
                _profile!['planting_date'] != null 
                ? DateFormat('dd MMM yyyy').format(DateTime.parse(_profile!['planting_date']))
                : 'Not planted yet'),
            _infoRow(Icons.timeline, 'Growth Day', isPlanted ? 'Day $currentDay' : '—'),
            _infoRow(Icons.location_on, 'Location', 
                _profile!['latitude'] != null 
                ? '${_profile!['latitude']}, ${_profile!['longitude']}' 
                : 'No GPS'),
            _infoRow(Icons.note, 'Notes', _profile!['notes'] ?? '—'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
