import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final List<String> monthNames;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.monthNames
  });

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    // កែសម្រួល logic ថ្ងៃទី១ ចំថ្ងៃច័ន្ទ (Flutter: Monday = 1, Sunday = 7)
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final leadingEmpty = firstOfMonth.weekday - 1;
    final totalDays = _daysInMonth(focusedMonth);
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: leadingEmpty + totalDays,
      itemBuilder: (context, index) {
        if (index < leadingEmpty) return const SizedBox.shrink();

        final dayNumber = index - leadingEmpty + 1;
        final isToday = today.year == focusedMonth.year &&
            today.month == focusedMonth.month &&
            today.day == dayNumber;

        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: $dayNumber ${monthNames[focusedMonth.month - 1]}'))
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isToday ? Colors.blueAccent.withOpacity(0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isToday ? Border.all(color: Colors.blueAccent) : null,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.blueAccent : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}