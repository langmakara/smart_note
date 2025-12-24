import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calendar',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();

  static const List<String> _monthNames = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  void _addMonths(int months) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + months, 1);
    });
  }

  int _daysInMonth(DateTime month) {
    final nextMonth = (month.month == 12)
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);

    // Monday = 0, Sunday = 6
    final leadingEmpty = (firstOfMonth.weekday + 6) % 7;
    final totalDays = _daysInMonth(_focusedMonth);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _addMonths(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _addMonths(1),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Weekday header
            Row(
              children: [
                Expanded(child: Center(child: Text('Mon', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Tue', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Wed', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Thu', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Fri', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Sat', style: TextStyle(fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('Sun', style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 8),

            // Calendar grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemCount: leadingEmpty + totalDays,
                itemBuilder: (context, index) {
                  if (index < leadingEmpty) {
                    return const SizedBox.shrink();
                  }

                  final dayNumber = index - leadingEmpty + 1;

                  final isToday =
                      today.year == _focusedMonth.year &&
                      today.month == _focusedMonth.month &&
                      today.day == dayNumber;

                  return GestureDetector(
                    onTap: () {
                      final selected = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month,
                        dayNumber,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected: ${selected.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.blueAccent.withOpacity(0.3)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? Colors.blueAccent
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
