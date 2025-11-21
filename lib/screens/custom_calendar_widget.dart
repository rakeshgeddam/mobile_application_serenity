import 'package:flutter/material.dart';

class CustomCalendarWidget extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Map<String, List<dynamic>> eventMap;

  const CustomCalendarWidget({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.eventMap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final startWeekday = DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;
    final today = DateTime.now();

    // Prepare grid of dates (with empty "slots" before the 1st day)
    final List<Widget> dateTiles = [];
    for (var i = 1; i < startWeekday; i++) {
      dateTiles.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final hasEvent = eventMap[key] != null && eventMap[key]!.isNotEmpty;

      dateTiles.add(
        GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF547E74)
                  : isToday
                      ? const Color(0xFFD1F1E7)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasEvent)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF547E74),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
                  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var d in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
            Expanded(
              child: Center(
                child: Text(d, style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),

            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: dateTiles,
            ),
          ],
        ),
      ),
    );
  }
}
