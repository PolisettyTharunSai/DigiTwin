import 'package:flutter/material.dart';
import 'subscriptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  /// 🌱 Get active crops count from SharedPreferences
  Future<int> _getActiveCropsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final crops = prefs.getStringList('my_crops') ?? [];
    return crops.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Test Farmer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "kisaan@email.com",
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

              /// 📊 Stats
              Row(
                children: [
                  /// 🌾 ACTIVE CROPS (dynamic)
                  Expanded(
                    child: FutureBuilder<int>(
                      future: _getActiveCropsCount(),
                      builder: (context, snapshot) {
                        final value =
                        snapshot.hasData ? snapshot.data.toString() : "...";
                        return _statCard(
                          "Active Crops",
                          value!,
                          Icons.grass,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                  _statCard("Alerts", "2", Icons.notifications),
                  const SizedBox(width: 12),
                  _statCard("Plan", "Active", Icons.workspace_premium),
                ],
              ),

              const SizedBox(height: 30),

              /// ⚙️ Options
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

  /// 📊 Stat card widget
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
        ],
      ),
      child: Column(
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// ⚙️ Option tile widget
  Widget _optionTile(
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
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
