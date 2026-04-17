import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _profile;

  // Form Fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  String _currentLocale = 'en';
  bool _exploreAllDays = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndProfile();
  }

  Future<void> _loadSettingsAndProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLocale = prefs.getString('appLanguage') ?? 'en';
      _exploreAllDays = prefs.getBool('explore_all_days') ?? false;

      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final profileRes = await _supabase.from('profile').select().eq('id', userId).single();
        if (mounted) {
          _profile = profileRes;
          _nameController.text = _profile!['name'] ?? '';
          _emailController.text = _supabase.auth.currentUser?.email ?? _profile!['email'] ?? '';
          _notesController.text = _profile!['notes'] ?? '';
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Email cannot be empty')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{
        'name': _nameController.text,
        'email': _emailController.text,
        'notes': _notesController.text,
      };

      await _supabase.from('profile').update(updates).eq('id', userId);

      // Update Auth Email / Password if changed
      UserAttributes attributes = UserAttributes();
      bool updateAuth = false;

      if (_emailController.text != _supabase.auth.currentUser?.email) {
        attributes.email = _emailController.text;
        updateAuth = true;
      }
      
      if (_passwordController.text.isNotEmpty) {
        attributes.password = _passwordController.text;
        updateAuth = true;
      }

      if (updateAuth) {
        await _supabase.auth.updateUser(attributes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving variations: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleExploreDays(bool value) async {
    setState(() => _exploreAllDays = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('explore_all_days', value);
  }

  Future<void> _changeLanguage(String code) async {
    setState(() => _currentLocale = code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', code);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.primary),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isPlanted = (_profile?['is_crop_planted'] == true);
    final plantingDate = _profile?['planting_date'] != null 
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(_profile!['planting_date'])) 
        : 'Not planted yet';
    final crop = _profile?['crop'] ?? 'Not set';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
            const SizedBox(height: 12),
            
            // Language Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.translate, color: AppColors.primary),
              title: const Text('App Language'),
              trailing: DropdownButton<String>(
                value: _currentLocale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
                  DropdownMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
                  DropdownMenuItem(value: 'te', child: Text('తెలుగు (Telugu)')),
                  DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ (Kannada)')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                  DropdownMenuItem(value: 'pa', child: Text('ਪੰਜਾਬੀ (Punjabi)')),
                  DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી (Gujarati)')),
                  DropdownMenuItem(value: 'bn', child: Text('বাংলা (Bengali)')),
                  DropdownMenuItem(value: 'ml', child: Text('മലയാളം (Malayalam)')),
                  DropdownMenuItem(value: 'ur', child: Text('اردو (Urdu)')),
                ],
                onChanged: (code) {
                  if (code != null) _changeLanguage(code);
                },
              ),
            ),
            const Divider(),

            // Explore Days Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Enable Exploring Timeline', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('Allow navigating through crop timeline in sidebar.'),
              value: _exploreAllDays,
              onChanged: _toggleExploreDays,
            ),
            const SizedBox(height: 24),
            
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
            const SizedBox(height: 12),
            
            // Non-editable fields
            Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.grey.shade200,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text('Crop: $crop', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Planting Date: $plantingDate', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('Non-editable fields.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                 ],
               ),
            ),
            const SizedBox(height: 16),

            // Editable fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password (leave blank to keep)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
