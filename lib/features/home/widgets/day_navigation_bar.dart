import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Floating bottom navigation bar that lets the user step through crop days
/// and open the calendar picker.
class DayNavigationBar extends StatelessWidget {
  final int currentDay;
  final int maxDay;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onCalendarTap;

  const DayNavigationBar({
    super.key,
    required this.currentDay,
    required this.maxDay,
    required this.onPrevious,
    required this.onNext,
    required this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 30,
      right: 30,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavCircleButton(
              icon: Icons.chevron_left,
              onTap: currentDay > 1 ? onPrevious : null,
            ),
            // Day indicator with calendar icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Day $currentDay',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onCalendarTap,
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            _NavCircleButton(
              icon: Icons.chevron_right,
              onTap: currentDay < maxDay ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular navigation arrow button used in [DayNavigationBar].
class _NavCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
