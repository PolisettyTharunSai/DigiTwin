import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';

/// Custom calendar dialog for picking a plantation cycle day.
/// Shows only dates within the planting cycle and highlights milestones.
class CustomCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime plantationDate;

  const CustomCalendarDialog({
    super.key,
    required this.initialDate,
    required this.plantationDate,
  });

  @override
  State<CustomCalendarDialog> createState() => _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends State<CustomCalendarDialog> {
  late DateTime _focusedDate;
  late PageController _pageController;
  late List<DateTime> _months;

  static const Color _highlightColor = AppColors.primary;

  /// Milestone days mapped to emoji stickers.
  final Map<int, String> _milestones = {
    1: '🌱',
    30: '🌿',
    60: '🥔',
    105: '🧺',
  };

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _months = _generateMonths();

    final int initialPage = _months.indexWhere(
      (m) => m.year == _focusedDate.year && m.month == _focusedDate.month,
    );
    _pageController = PageController(
      initialPage: initialPage != -1 ? initialPage : 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: 350,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: _highlightColor),
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _highlightColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: _highlightColor),
                  onPressed: () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Month grid pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _months.length,
                onPageChanged: (i) {
                  setState(() => _focusedDate = _months[i]);
                },
                itemBuilder: (context, index) {
                  return _buildMonthGrid(_months[index]);
                },
              ),
            ),
            const SizedBox(height: 10),

            // Milestone legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<DateTime> _generateMonths() {
    final List<DateTime> list = [];
    DateTime start = DateTime(
      widget.plantationDate.year,
      widget.plantationDate.month,
    );
    final DateTime end =
        widget.plantationDate.add(const Duration(days: 109));

    DateTime current = start;
    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      list.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return list;
  }

  Widget _buildMonthGrid(DateTime monthDate) {
    final int daysInMonth =
        DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final int firstWeekday =
        DateTime(monthDate.year, monthDate.month, 1).weekday;
    final int offset = firstWeekday % 7;

    return Column(
      children: [
        // Day-of-week headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayIndex = index - offset + 1;
              if (dayIndex < 1 || dayIndex > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(monthDate.year, monthDate.month, dayIndex);
              final isOutsideRange = date.isBefore(widget.plantationDate) ||
                  date.isAfter(
                    widget.plantationDate.add(const Duration(days: 108)),
                  );

              final dayOfCycle =
                  date.difference(widget.plantationDate).inDays + 1;
              final sticker = _milestones[dayOfCycle];

              final now = DateTime.now();
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              final isSelected = date.year == widget.initialDate.year &&
                  date.month == widget.initialDate.month &&
                  date.day == widget.initialDate.day;

              return GestureDetector(
                onTap: isOutsideRange
                    ? null
                    : () => Navigator.pop(context, date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _highlightColor
                        : (isOutsideRange ? Colors.grey.shade50 : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _highlightColor
                          : (isToday
                              ? _highlightColor.withOpacity(0.5)
                              : Colors.grey.shade100),
                      width: isToday ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _highlightColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        dayIndex.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isOutsideRange
                                  ? Colors.grey.shade300
                                  : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (sticker != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Text(
                            sticker,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _milestones.entries.map((e) {
          return Row(
            children: [
              Text(e.value, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                'Day ${e.key}',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
