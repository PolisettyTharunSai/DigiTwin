import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_page.dart';
import 'recommendations_page.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MyCropsPage(),
    SubscriptionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Di Twin 🌾'
              : _selectedIndex == 1
              ? 'My Crops'
              : 'Subscriptions',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture, color: Colors.green),
            label: 'Plant a Crop',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass, color: Colors.green),
            label: 'My Crops',
          ),
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions, color: Colors.green),
            label: 'Subscriptions',
          ),
        ],
      ),
    );
  }
}

class MyCropsPage extends StatefulWidget {
  const MyCropsPage({super.key});

  @override
  State<MyCropsPage> createState() => _MyCropsPageState();
}

class _MyCropsPageState extends State<MyCropsPage> {
  List<Map<String, dynamic>> _myCrops = [];

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cropsList = prefs.getStringList('my_crops') ?? [];
    setState(() {
      _myCrops = cropsList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_myCrops.isEmpty) {
      return Center(
        child: Text(
          'No crops planted yet 🌱',
          style: TextStyle(
            fontSize: 18,
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myCrops.length,
      itemBuilder: (context, index) {
        final crop = _myCrops[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.green.shade50,
          child: ListTile(
            leading: const Icon(
              Icons.agriculture,
              color: Colors.green,
              size: 40,
            ),
            title: Text(
              crop['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            subtitle: Text(
              'Planted on: ${DateTime.parse(crop['date']).toLocal().toString().split(' ')[0]}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecommendationsPage(
                    cropName: crop['name'],
                    plantingDate: DateTime.parse(crop['date']),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Manage your subscriptions here'));
  }
}
