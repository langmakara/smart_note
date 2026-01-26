import 'package:flutter/material.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final List<String> monthNames;
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.monthNames,
    this.onDateSelected,
    this.selectedDate,
  });

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
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
        final date = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
        final isToday = today.year == focusedMonth.year &&
            today.month == focusedMonth.month &&
            today.day == dayNumber;
        final isSelected = selectedDate != null &&
            selectedDate!.year == focusedMonth.year &&
            selectedDate!.month == focusedMonth.month &&
            selectedDate!.day == dayNumber;

        return GestureDetector(
          onTap: () {
            if (onDateSelected != null) {
              onDateSelected!(date);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.purple
                  : isToday
                      ? Colors.blueAccent.withOpacity(0.2)
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 2)
                  : isToday
                      ? Border.all(color: Colors.blueAccent)
                      : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? Colors.blueAccent
                          : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}