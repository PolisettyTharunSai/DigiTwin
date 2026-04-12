import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(avatarUrl!),
        child: null, // No child needed if background image is used
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
