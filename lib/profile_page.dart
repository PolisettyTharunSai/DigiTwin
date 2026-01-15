import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscriptions.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _activeCropsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCropCount();
  }

  Future<void> _loadCropCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> cropsList = prefs.getStringList('my_crops') ?? [];
    setState(() {
      _activeCropsCount = cropsList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            100, // ✅ EXTRA BOTTOM PADDING (FIXES LOGOUT ISSUE)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👤 Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 36, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Venkata Praneeth",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "praneeth@email.com",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "+91 98765 43210",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 📊 STATS — FULL WIDTH & EQUAL SIZE
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Active Crops",
                      value: _activeCropsCount.toString(),
                      icon: Icons.grass,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(
                      title: "Alerts",
                      value: "2",
                      icon: Icons.notifications,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(
                      title: "Plan",
                      value: "Active",
                      icon: Icons.workspace_premium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ⚙️ Account Section
              Text(
                "Account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),

              _optionTile(
                context,
                icon: Icons.subscriptions,
                title: "My Subscriptions",
                subtitle: "View active and available plans",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionsPage(),
                    ),
                  );
                },
              ),

              _optionTile(
                context,
                icon: Icons.notifications_active,
                title: "Alerts & Notifications",
                subtitle: "Crop health and reminders",
                onTap: () {},
              ),

              _optionTile(
                context,
                icon: Icons.settings,
                title: "Settings",
                subtitle: "App preferences",
                onTap: () {},
              ),

              _optionTile(
                context,
                icon: Icons.logout,
                title: "Logout",
                subtitle: "Sign out of your account",
                onTap: () {},
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _optionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.green.shade600,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// 🔹 STAT CARD (EQUAL WIDTH GUARANTEED)
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green.shade600),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
