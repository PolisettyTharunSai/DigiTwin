import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Animated 2D / 3D pill toggle switch used in the HomeScreen.
/// Slides the active indicator between the two options.
class ViewToggle extends StatelessWidget {
  final bool show3DModel;
  final ValueChanged<bool> onToggle;

  const ViewToggle({
    super.key,
    required this.show3DModel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double pillWidth = (screenWidth - 200 - 8) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: GestureDetector(
        onTap: () => onToggle(!show3DModel),
        child: Container(
          height: 45,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              // Sliding active pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment:
                    show3DModel ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: pillWidth,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Labels
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '2D',
                        style: TextStyle(
                          color: !show3DModel
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '3D',
                        style: TextStyle(
                          color: show3DModel
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
