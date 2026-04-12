import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/day_utils.dart';
import '../../../shared/widgets/fullscreen_image_gallery.dart';
import '../../../shared/widgets/user_avatar.dart';

class FarmerLogsScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;

  const FarmerLogsScreen({
    super.key,
    required this.farmer,
  });

  @override
  State<FarmerLogsScreen> createState() => _FarmerLogsScreenState();
}

class _FarmerLogsScreenState extends State<FarmerLogsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allLogs = [];
  List<Map<String, dynamic>> _filteredLogs = [];

  // Filter states
  DateTime? _fromDate;
  DateTime? _toDate;
  bool? _wateredFilter; // null = All, true = Watered, false = Not Watered
  bool? _pestsFilter; // null = All, true = Pests, false = No Pests
  bool _hasImagesFilter = false;
  bool _hasFeedbackFilter = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final response = await _supabase
          .from('plant_daily_log')
          .select()
          .eq('user_id', widget.farmer['id'])
          .order('log_date', ascending: false);
      
      if (mounted) {
        setState(() {
          _allLogs = List<Map<String, dynamic>>.from(response);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        final logDate = DateTime.parse(log['log_date']);
        
        // Date range filter
        if (_fromDate != null && logDate.isBefore(_fromDate!)) return false;
        if (_toDate != null && logDate.isAfter(_toDate!.add(const Duration(days: 1)))) return false;

        // Watered filter
        if (_wateredFilter != null && log['watered'] != _wateredFilter) return false;

        // Pests filter
        if (_pestsFilter != null && log['pests_observed'] != _pestsFilter) return false;

        // Images filter
        if (_hasImagesFilter) {
          final images = log['images'] as List?;
          if (images == null || images.isEmpty) return false;
        }

        // Feedback filter
        if (_hasFeedbackFilter) {
          final feedback = log['feedback'] as String?;
          if (feedback == null || feedback.trim().isEmpty) return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _wateredFilter = null;
      _pestsFilter = null;
      _hasImagesFilter = false;
      _hasFeedbackFilter = false;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmer = widget.farmer;
    final bool isPlanted = farmer['is_crop_planted'] == true;
    int currentDay = 0;
    if (isPlanted && farmer['planting_date'] != null) {
      try {
        currentDay = DayUtils.calculateTodayDay(DateTime.parse(farmer['planting_date']));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(farmer['name'] ?? 'Farmer Logs', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSummary(farmer, isPlanted, currentDay),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Daily Log History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
              ),
            ),
            if (!_isLoading && _allLogs.isNotEmpty) _buildFilterSection(),
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_allLogs.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No logs submitted by this farmer.')))
            else if (_filteredLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Text('No logs match your filters'),
                      TextButton(onPressed: _clearAllFilters, child: const Text('Clear Filters')),
                    ],
                  ),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Showing ${_filteredLogs.length} of ${_allLogs.length} logs',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredLogs.length,
                itemBuilder: (context, index) {
                  return _buildLogEntry(_filteredLogs[index]);
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        // Date Range Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _datePickerField(
                  label: 'From',
                  date: _fromDate,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() { _fromDate = d; _applyFilters(); });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _datePickerField(
                  label: 'To',
                  date: _toDate,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() { _toDate = d; _applyFilters(); });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Filter Chips Row
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _filterChip('Watered', _wateredFilter == true, (v) {
                setState(() { _wateredFilter = v ? true : null; _applyFilters(); });
              }),
              _filterChip('Not Watered', _wateredFilter == false, (v) {
                setState(() { _wateredFilter = v ? false : null; _applyFilters(); });
              }),
              _filterChip('Pests Observed', _pestsFilter == true, (v) {
                setState(() { _pestsFilter = v ? true : null; _applyFilters(); });
              }),
              _filterChip('No Pests', _pestsFilter == false, (v) {
                setState(() { _pestsFilter = v ? false : null; _applyFilters(); });
              }),
              _filterChip('Has Images', _hasImagesFilter, (v) {
                setState(() { _hasImagesFilter = v; _applyFilters(); });
              }),
              _filterChip('Has Feedback', _hasFeedbackFilter, (v) {
                setState(() { _hasFeedbackFilter = v; _applyFilters(); });
              }),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _datePickerField({required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? label : DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(fontSize: 13, color: date == null ? Colors.grey : Colors.black87)),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, Function(bool) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildProfileSummary(Map<String, dynamic> farmer, bool isPlanted, int currentDay) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(
                  avatarUrl: farmer['avatar_url'],
                  name: farmer['name'] ?? 'Unknown',
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer['name'] ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(farmer['email'] ?? 'No email', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _summaryRow(Icons.agriculture, 'Crop', farmer['crop'] ?? 'Not specified'),
            _summaryRow(Icons.calendar_today, 'Planting Date', farmer['planting_date'] ?? 'Not planted'),
            _summaryRow(Icons.timeline, 'Growth Day', isPlanted ? 'Day $currentDay' : 'N/A'),
            _summaryRow(Icons.location_on, 'Location', 
              farmer['latitude'] != null ? '${farmer['latitude']}, ${farmer['longitude']}' : 'No GPS'),
            if (farmer['notes'] != null && farmer['notes'].toString().isNotEmpty)
              _summaryRow(Icons.note, 'Notes', farmer['notes']),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> log) {
    final dateStr = log['log_date'] ?? '';
    String formattedDate = dateStr;
    try {
      formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(dateStr));
    } catch (_) {}

    final watered = log['watered'] == true;
    final pests = log['pests_observed'] == true;
    final images = List<String>.from(log['images'] ?? []);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _statusBadge(watered ? Icons.check_circle : Icons.cancel, 
                           watered ? 'Watered' : 'Not Watered', 
                           watered ? AppColors.successGreen : AppColors.errorRed),
              const SizedBox(width: 8),
              _statusBadge(pests ? Icons.bug_report : Icons.verified, 
                           pests ? 'Pests' : 'No Pests', 
                           pests ? AppColors.warningOrange : AppColors.successGreen),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (watered)
                  _detailRow('Water Amount', '${log['water_amount'] ?? 'N/A'} ${log['water_unit'] ?? ''}'),
                if (pests)
                  _detailRow('Pest Notes', log['pest_notes'] ?? 'None'),
                if (log['feedback'] != null && log['feedback'].toString().isNotEmpty)
                  _detailRow('Feedback', log['feedback']),
                
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullscreenImageGallery(images: images, initialIndex: i),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: NetworkImage(images[i]), fit: BoxFit.cover),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
