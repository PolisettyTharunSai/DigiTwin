import 'package:flutter/material.dart';
import 'add_crops.dart';
import 'my_crops.dart';
import 'profile_page.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  /// 🔥 Start with My Crops
  int _selectedIndex = 1;

  /// 🔁 Key to force MyCropsPage rebuild
  Key _myCropsKey = UniqueKey();

  List<Widget> get _pages => [
    const SizedBox(), // HomePage is NOT here anymore
    MyCropsPage(key: _myCropsKey),
    InsightsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  /// ➕ Open HomePage as a window
  void _openPlantCropWindow() {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental close
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SizedBox(
            // ✅ Fix: Use ConstrainedBox to let height shrink-wrap content
            // instead of forcing a fixed height.
            width: MediaQuery.of(context).size.width * 0.95,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Stack(
                children: [
                  /// 🌱 Home Page Content
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: HomePage(
                      onPlantingConfirmed: () {
                        /// 🔥 FORCE REFRESH
                        setState(() {
                          _myCropsKey = UniqueKey();
                          _selectedIndex = 1;
                        });

                        Navigator.pop(context);
                      },
                    ),
                  ),

                  /// ❌ Close Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_selectedIndex],
          ),

          /// Custom Bottom Navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.agriculture,
            label: "My Crops",
            index: 1,
          ),

          /// ➕ Button
          GestureDetector(
            onTap: _openPlantCropWindow,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          _navItem(
            icon: Icons.person_2_outlined,
            label: "Profile",
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.green.shade600 : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.green.shade600 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}