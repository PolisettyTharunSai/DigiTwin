import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    // Check for new system notifications (like irrigation) before fetching
    await NotificationService.instance.checkSystemNotifications();

    final data = await NotificationService.instance.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
    // Mark all as read when opening the screen
    for (var n in data) {
      if (n['is_read'] == false) {
        await NotificationService.instance.markAsRead(n['id']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return _buildNotificationCard(n);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No notifications yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    final type = n['type'];
    final severity = n['severity'];
    
    IconData icon = Icons.notifications;
    Color iconColor = AppColors.primary;

    if (type == 'weather') {
      icon = Icons.cloud_outlined;
      if (severity == 'severe') iconColor = Colors.red;
      else if (severity == 'medium') iconColor = Colors.orange;
    } else if (type == 'log') {
      icon = Icons.assignment_outlined;
      iconColor = Colors.blue;
    } else if (type == 'irrigation' || type == 'recommendation') {
      icon = Icons.water_drop_outlined;
      iconColor = Colors.cyan;
    }

    final date = DateTime.parse(n['created_at']);
    final timeStr = DateFormat('MMM dd, hh:mm a').format(date.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      borderOnForeground: true,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          n['title'] ?? 'Alert',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n['message'] ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 6),
            Text(timeStr, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
