import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../profile/screens/profile_screen.dart';
import 'manage_users_screen.dart';
import 'data_export_screen.dart';
import 'manage_tickets_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _adminProfile;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('profile')
            .select()
            .eq('id', userId)
            .single();
        
        if (mounted) {
          setState(() {
            _adminProfile = response;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _adminProfile?['name'] ?? 'Admin';
    final avatarUrl = _adminProfile?['avatar_url'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _fetchAdminData()),
              child: UserAvatar(
                avatarUrl: avatarUrl,
                name: name,
                radius: 18,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreetingCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Management Tools',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                  ),
                  const SizedBox(height: 16),
                  
                  // Changed to a vertical list of wide cards to reduce empty space
                  _buildWideFeatureCard(
                    context,
                    title: 'Manage Users',
                    subtitle: 'View, filter & inspect registered farmers',
                    icon: Icons.people_alt_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                  ),
                  const SizedBox(height: 12),
                  _buildWideFeatureCard(
                    context,
                    title: 'Support Tickets',
                    subtitle: 'Manage and respond to user help requests',
                    icon: Icons.confirmation_number_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTicketsScreen())),
                  ),
                  const SizedBox(height: 12),
                  _buildWideFeatureCard(
                    context,
                    title: 'Data Export',
                    subtitle: 'Export logs and system data to CSV / JSON',
                    icon: Icons.download_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportScreen())),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGreetingCard() {
    final name = _adminProfile?['name'] ?? 'Admin';
    final avatarUrl = _adminProfile?['avatar_url'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          UserAvatar(
            avatarUrl: avatarUrl,
            name: name,
            radius: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'System Control Panel',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkBrown),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
