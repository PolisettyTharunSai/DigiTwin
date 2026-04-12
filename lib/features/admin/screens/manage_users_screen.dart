import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/day_utils.dart';
import '../../../shared/widgets/user_avatar.dart';
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
  final TextEditingController _dayFromController = TextEditingController();
  final TextEditingController _dayToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dayFromController.dispose();
    _dayToController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await _supabase
          .from('profile')
          .select('*, avatar_url')
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
    final dayFrom = int.tryParse(_dayFromController.text);
    final dayTo = int.tryParse(_dayToController.text);

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
        if (dayFrom != null || dayTo != null) {
          if (user['is_crop_planted'] == true && user['planting_date'] != null) {
            try {
              final plantingDate = DateTime.parse(user['planting_date']);
              final currentDay = DayUtils.calculateTodayDay(plantingDate);
              if (dayFrom != null && currentDay < dayFrom) matchesDayRange = false;
              if (dayTo != null && currentDay > dayTo) matchesDayRange = false;
            } catch (_) {
              matchesDayRange = false;
            }
          } else {
            matchesDayRange = false;
          }
        }

        return matchesSearch && matchesCrop && matchesLocation && matchesDayRange;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _cropPlantedFilter = 'All';
      _locationFilter = 'All';
      _dayFromController.clear();
      _dayToController.clear();
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
                      const Text('Filter Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Crop Planted?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildSegmentedControl(['All', 'Planted', 'Not Planted'], _cropPlantedFilter, (val) {
                    setModalState(() => _cropPlantedFilter = val);
                  }),
                  const SizedBox(height: 16),
                  const Text('Planting Day Range', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dayFromController,
                          decoration: const InputDecoration(labelText: 'Day from', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _dayToController,
                          decoration: const InputDecoration(labelText: 'Day to', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Has GPS?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildSegmentedControl(['All', 'With GPS', 'Without GPS'], _locationFilter, (val) {
                    setModalState(() => _locationFilter = val);
                  }),
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

  Widget _buildSegmentedControl(List<String> options, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (val) => onSelect(opt),
          selectedColor: AppColors.primary.withOpacity(0.2),
          labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.black87),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
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
                      hintText: 'Search name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
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
          _buildActiveFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No farmers found matching filters.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final bool isPlanted = user['is_crop_planted'] == true;
                          String subtitle = "Not planted yet";
                          if (isPlanted && user['planting_date'] != null) {
                            try {
                              final day = DayUtils.calculateTodayDay(DateTime.parse(user['planting_date']));
                              subtitle = "${user['crop'] ?? 'Crop'} • Day $day";
                            } catch (_) {}
                          }
                          
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: UserAvatar(
                                avatarUrl: user['avatar_url'],
                                name: user['name'] ?? 'Unknown',
                                radius: 24,
                              ),
                              title: Text(user['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? 'No email', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(subtitle, style: TextStyle(color: isPlanted ? AppColors.successGreen : Colors.grey, fontSize: 12)),
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

  Widget _buildActiveFilterChips() {
    final List<Widget> chips = [];
    if (_cropPlantedFilter != 'All') {
      chips.add(_filterChip(_cropPlantedFilter, () => setState(() { _cropPlantedFilter = 'All'; _applyFilters(); })));
    }
    if (_locationFilter != 'All') {
      chips.add(_filterChip(_locationFilter, () => setState(() { _locationFilter = 'All'; _applyFilters(); })));
    }
    final dayFrom = _dayFromController.text;
    final dayTo = _dayToController.text;
    if (dayFrom.isNotEmpty || dayTo.isNotEmpty) {
      String label = "Day";
      if (dayFrom.isNotEmpty) label += " $dayFrom+";
      if (dayTo.isNotEmpty) label += " to $dayTo";
      chips.add(_filterChip(label, () => setState(() { _dayFromController.clear(); _dayToController.clear(); _applyFilters(); })));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
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
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 14),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
