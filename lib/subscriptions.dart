import 'package:flutter/material.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  bool showActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Subscriptions"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔁 Toggle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _toggleButton(
                    label: "Active Plans",
                    selected: showActive,
                    onTap: () => setState(() => showActive = true),
                  ),
                  _toggleButton(
                    label: "Available Plans",
                    selected: !showActive,
                    onTap: () => setState(() => showActive = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(child: showActive ? _activePlans() : _availablePlans()),
          ],
        ),
      ),
    );
  }

  /// 🔘 Toggle Button
  Widget _toggleButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.green.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= ACTIVE PLANS =================
  Widget _activePlans() {
    return ListView(
      children: [
        _activePlanCard(
          title: "Premium Crop Intelligence",
          daysLeft: 18,
          renewalDate: "26 Jan 2026",
        ),
        _activePlanCard(
          title: "AR Crop Monitoring",
          daysLeft: 45,
          renewalDate: "22 Feb 2026",
        ),
      ],
    );
  }

  Widget _activePlanCard({
    required String title,
    required int daysLeft,
    required String renewalDate,
  }) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, Icons.verified, Colors.green),
          const SizedBox(height: 14),
          _infoRow("Status", "Active"),
          _infoRow("Days Remaining", "$daysLeft days"),
          _infoRow("Next Renewal", renewalDate),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text("Manage Subscription"),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= AVAILABLE PLANS =================
  Widget _availablePlans() {
    return ListView(
      children: [
        _availablePlanCard(
          title: "Basic Advisory Plan",
          price: 499,
          offerEnds: "20 Jan 2026",
          support: "Email Support",
          idealFor: "Small farms",
        ),
        _availablePlanCard(
          title: "Pro Yield Boost Plan",
          price: 999,
          offerEnds: "25 Jan 2026",
          support: "Priority Support",
          idealFor: "Medium farms",
        ),
        _availablePlanCard(
          title: "Enterprise Farm Suite",
          price: 1999,
          offerEnds: "05 Feb 2026",
          support: "Dedicated Manager",
          idealFor: "Large farms",
        ),
      ],
    );
  }

  Widget _availablePlanCard({
    required String title,
    required int price,
    required String offerEnds,
    required String support,
    required String idealFor,
  }) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, Icons.workspace_premium, Colors.green.shade600),
          const SizedBox(height: 12),

          Text(
            "₹ $price / year",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(height: 12),

          _infoRow("Offer Valid Till", offerEnds),
          _infoRow("Customer Support", support),
          _infoRow("Ideal For", idealFor),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white, // 👈 text forced to white
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text("Subscribe"),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= COMMON UI =================
  Widget _cardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}