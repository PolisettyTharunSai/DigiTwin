import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../profile/screens/profile_screen.dart';

/// Header section shown at the top of the HomeScreen.
/// Displays the farmer greeting, planting date, and action icon buttons.
class HomeHeader extends StatelessWidget {
  final String farmerName;
  final DateTime? plantationDate;
  final bool hasTodayLogSubmitted;
  final String? avatarUrl;

  final VoidCallback onLogoutTap;
  final VoidCallback onDailyCheckTap;
  final VoidCallback onInstructionsTap;
  final VoidCallback onRecommendationsTap;
  final bool isAdmin;
  final VoidCallback? onAdminTap;

  const HomeHeader({
    super.key,
    required this.farmerName,
    required this.plantationDate,
    required this.hasTodayLogSubmitted,
    this.avatarUrl,
    required this.onLogoutTap,
    required this.onDailyCheckTap,
    required this.onInstructionsTap,
    required this.onRecommendationsTap,
    this.isAdmin = false,
    this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Edge: Menu Button
          _IconActionButton(
            icon: Icons.menu,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menu',
          ),
          const SizedBox(width: 12),
          
          // Middle: Greeting and Planting Date
          Expanded(
            child: _PlantingInfo(
              farmerName: farmerName,
              plantationDate: plantationDate,
            ),
          ),
          
          // Action Buttons
          _ActionButtons(
            hasTodayLogSubmitted: hasTodayLogSubmitted,
            onDailyCheckTap: onDailyCheckTap,
            onInstructionsTap: onInstructionsTap,
            onRecommendationsTap: onRecommendationsTap,
            isAdmin: isAdmin,
            onAdminTap: onAdminTap,
          ),
          
          const SizedBox(width: 10),
          
          // Right Edge: Profile Button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: UserAvatar(
              avatarUrl: avatarUrl,
              name: farmerName,
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _PlantingInfo extends StatelessWidget {
  final String farmerName;
  final DateTime? plantationDate;

  const _PlantingInfo({required this.farmerName, required this.plantationDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi $farmerName!',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Planted:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                plantationDate != null
                    ? DateFormat('dd MMM yyyy').format(plantationDate!)
                    : 'Not Set',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool hasTodayLogSubmitted;
  final VoidCallback onDailyCheckTap;
  final VoidCallback onInstructionsTap;
  final VoidCallback onRecommendationsTap;
  final bool isAdmin;
  final VoidCallback? onAdminTap;

  const _ActionButtons({
    required this.hasTodayLogSubmitted,
    required this.onDailyCheckTap,
    required this.onInstructionsTap,
    required this.onRecommendationsTap,
    this.isAdmin = false,
    this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAdmin && onAdminTap != null) ...[
          _IconActionButton(
            icon: Icons.admin_panel_settings,
            onPressed: onAdminTap!,
            tooltip: 'Admin Dashboard',
          ),
          const SizedBox(width: 10),
        ],
        _IconActionButton(
          icon: Icons.assignment_turned_in_outlined,
          onPressed: onDailyCheckTap,
          tooltip: "Today's Plant Check",
          badge: !hasTodayLogSubmitted,
        ),
      ],
    );
  }
}

/// A single rounded icon button used in the header action row.
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool badge;

  const _IconActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(icon, color: AppColors.primary),
            onPressed: onPressed,
            tooltip: tooltip,
          ),
          if (badge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
