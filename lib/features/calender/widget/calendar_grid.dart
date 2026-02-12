import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final List<String> monthNames;
  final Function(DateTime)? onDateSelected;
  final DateTime? selectedDate;
  final List<Event> events;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.monthNames,
    this.onDateSelected,
    this.selectedDate,
    this.events = const [],
  });

  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final leadingEmpty = firstOfMonth.weekday - 1;
    final totalDays = _daysInMonth(focusedMonth);
    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: leadingEmpty + totalDays,
      itemBuilder: (context, index) {
        if (index < leadingEmpty) return const SizedBox.shrink();

        final dayNumber = index - leadingEmpty + 1;
        final date = DateTime(focusedMonth.year, focusedMonth.month, dayNumber);
        final isToday =
            today.year == focusedMonth.year &&
            today.month == focusedMonth.month &&
            today.day == dayNumber;
        final isSelected =
            selectedDate != null &&
            selectedDate!.year == focusedMonth.year &&
            selectedDate!.month == focusedMonth.month &&
            selectedDate!.day == dayNumber;

        final dayEvents = events
            .where((event) => event.isOnDate(date))
            .toList();

        final isWeekend = date.weekday >= 6;

        return GestureDetector(
          onTap: () {
            if (onDateSelected != null) {
              onDateSelected!(date);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? themeProvider.accentColor
                  : isToday
                  ? themeProvider.searchFillColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? themeProvider.accentColor
                        : isWeekend
                        ? themeProvider.subtitleColor.withValues(alpha: 0.7)
                        : themeProvider.textColor,
                  ),
                ),
                if (dayEvents.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayEvents.take(2).map((event) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : event.color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
