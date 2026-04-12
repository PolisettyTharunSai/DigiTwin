import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/day_utils.dart';
import 'farmer_logs_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  String _cropPlantedFilter = 'All'; // 'All', 'Planted', 'Not Planted'
  String _locationFilter = 'All'; // 'All', 'With GPS', 'Without GPS'
  int? _dayFrom;
  int? _dayTo;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await _supabase
          .from('profile')
          .select()
          .eq('is_admin', false)
          .order('created_at');
      
      if (mounted) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(response);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final matchesSearch = name.contains(query) || email.contains(query);

        bool matchesCrop = true;
        if (_cropPlantedFilter == 'Planted') {
          matchesCrop = user['is_crop_planted'] == true;
        } else if (_cropPlantedFilter == 'Not Planted') {
          matchesCrop = user['is_crop_planted'] == false;
        }

        bool matchesLocation = true;
        if (_locationFilter == 'With GPS') {
          matchesLocation = user['latitude'] != null;
        } else if (_locationFilter == 'Without GPS') {
          matchesLocation = user['latitude'] == null;
        }

        bool matchesDayRange = true;
        if (user['is_crop_planted'] == true && user['planting_date'] != null) {
          final plantingDate = DateTime.parse(user['planting_date']);
          final currentDay = DayUtils.calculateTodayDay(plantingDate);
          if (_dayFrom != null && currentDay < _dayFrom!) matchesDayRange = false;
          if (_dayTo != null && currentDay > _dayTo!) matchesDayRange = false;
        } else if ((_dayFrom != null || _dayTo != null)) {
          // If filtering by day but crop not planted, exclude? 
          // Requirements say "filter on is_crop_planted" separately, 
          // but if day range is set, we probably only want planted ones.
          matchesDayRange = false;
        }

        return matchesSearch && matchesCrop && matchesLocation && matchesDayRange;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _cropPlantedFilter = 'All';
      _locationFilter = 'All';
      _dayFrom = null;
      _dayTo = null;
      _applyFilters();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Farmers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Crop Planted?', style: TextStyle(fontWeight: FontWeight.bold)),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'Planted', label: Text('Planted')),
                      ButtonSegment(value: 'Not Planted', label: Text('Not')),
                    ],
                    selected: {_cropPlantedFilter},
                    onSelectionChanged: (val) => setModalState(() => _cropPlantedFilter = val.first),
                  ),
                  const SizedBox(height: 16),
                  const Text('Planting Day Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'From Day', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: _dayFrom?.toString() ?? ''),
                          onChanged: (val) => _dayFrom = int.tryParse(val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'To Day', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: _dayTo?.toString() ?? ''),
                          onChanged: (val) => _dayTo = int.tryParse(val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Has Location?', style: TextStyle(fontWeight: FontWeight.bold)),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'With GPS', label: Text('GPS')),
                      ButtonSegment(value: 'Without GPS', label: Text('No GPS')),
                    ],
                    selected: {_locationFilter},
                    onSelectionChanged: (val) => setModalState(() => _locationFilter = val.first),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _clearFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                ),
              ],
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found matching filters.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final bool isPlanted = user['is_crop_planted'] == true;
                          String subtitle = "Not planted yet";
                          if (isPlanted) {
                            final plantingDateStr = user['planting_date'];
                            int day = 0;
                            if (plantingDateStr != null) {
                              day = DayUtils.calculateTodayDay(DateTime.parse(plantingDateStr));
                            }
                            subtitle = "${user['crop'] ?? 'Crop'} • Day $day";
                          }
                          
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  (user['name'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(user['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? 'No email'),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(subtitle, style: TextStyle(color: isPlanted ? AppColors.successGreen : Colors.grey)),
                                      if (user['latitude'] != null) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FarmerLogsScreen(farmer: user),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<Widget> chips = [];
    if (_cropPlantedFilter != 'All') {
      chips.add(_filterChip(_cropPlantedFilter, () => setState(() { _cropPlantedFilter = 'All'; _applyFilters(); })));
    }
    if (_locationFilter != 'All') {
      chips.add(_filterChip(_locationFilter, () => setState(() { _locationFilter = 'All'; _applyFilters(); })));
    }
    if (_dayFrom != null || _dayTo != null) {
      String label = "Day";
      if (_dayFrom != null) label += " $_dayFrom+";
      if (_dayTo != null) label += " up to $_dayTo";
      chips.add(_filterChip(label, () => setState(() { _dayFrom = null; _dayTo = null; _applyFilters(); })));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: chips,
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 14),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
