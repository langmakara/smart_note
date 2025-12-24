import 'package:flutter/material.dart';
import '../widget/calendar_grid.dart'; // Import widget ខាងលើ

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
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + months, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _addMonths(-1)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _addMonths(1)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Weekday Headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                child: Center(
                  child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
              ))
                  .toList(),
            ),
            const Divider(),
            const SizedBox(height: 10),
            // ហៅ Widget មកប្រើ
            CalendarGrid(focusedMonth: _focusedMonth, monthNames: _monthNames),
          ],
        ),
      ),
    );
  }
}