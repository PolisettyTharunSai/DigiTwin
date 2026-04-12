import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Coming Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
