import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../widget/calendar_grid.dart';
import 'event_edit_page.dart';
import 'events_list_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  // Sample events for demonstration
  void _loadSampleEvents() {
    final now = DateTime.now();
    _events = [
      Event(
        id: '1',
        title: 'Team Meeting',
        description: 'Weekly team sync',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
        color: Colors.blue,
        location: 'Conference Room A',
      ),
      Event(
        id: '4',
        title: 'Planning Meeting',
        description: 'Sprint planning session',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 11, 0),
        color: Colors.purple,
        location: 'Conference Room B',
      ),
      Event(
        id: '2',
        title: 'Lunch Break',
        description: 'Team lunch',
        startTime: DateTime(now.year, now.month, now.day + 1, 12, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 13, 0),
        color: Colors.green,
      ),
      Event(
        id: '3',
        title: 'Project Deadline',
        description: 'Submit final report',
        startTime: DateTime(now.year, now.month, now.day + 3, 17, 0),
        endTime: DateTime(now.year, now.month, now.day + 3, 18, 0),
        color: Colors.orange,
      ),
    ];
  }

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  void _addMonths(int months) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + months,
        1,
      );
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  void _addEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventEditPage(
          selectedDate: _selectedDate,
          onSave: (event) {
            setState(() => _events.add(event));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Event "${event.title}" created!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _viewEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsListPage(
          events: _events,
          selectedDate: _selectedDate,
          onAddEvent: (event) {
            setState(() => _events.add(event));
          },
          onEditEvent: (event) {
            setState(() {
              final index = _events.indexWhere((e) => e.id == event.id);
              if (index != -1) {
                _events[index] = event;
              }
            });
          },
          onDeleteEvent: (eventId) {
            setState(() {
              _events.removeWhere((e) => e.id == eventId);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: Text(
          '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_left, color: themeProvider.subtitleColor),
            onPressed: () => _addMonths(-1),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: themeProvider.subtitleColor),
            onPressed: () => _addMonths(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.only(
              left: 16, 
              right: 16, 
              top: 20.0,
              bottom: 0,
            ),
            child: Row(
              children: _weekdayNames
                  .map(
                    (day) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: themeProvider.searchFillColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeProvider.dividerColor, width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: themeProvider.subtitleColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Calendar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CalendarGrid(
                focusedMonth: _focusedMonth,
                monthNames: _monthNames,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
                selectedDate: _selectedDate,
                events: _events,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Actions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildQuickAction(
                      icon: Icons.add_circle_outline,
                      label: 'Add Event',
                      onTap: () => _addEvent(context),
                      themeProvider: themeProvider,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildQuickAction(
                      icon: Icons.today,
                      label: 'View Events',
                      onTap: () => _viewEvents(context),
                      themeProvider: themeProvider,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
