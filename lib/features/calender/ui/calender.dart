import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
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

  List<Event> _getEventsForDate(DateTime date) {
    return _events.where((event) => event.isOnDate(date)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () => _addMonths(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () => _addMonths(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected Date Display
          if (_selectedDate != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_selectedDate!.day} ${_monthNames[_selectedDate!.month - 1]} ${_selectedDate!.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() => _selectedDate = null);
                    },
                  ),
                ],
              ),
            ),
            // Events for Selected Date
            if (_getEventsForDate(_selectedDate!).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.today, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${_getEventsForDate(_selectedDate!).length} Event(s)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _viewEvents(context),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._getEventsForDate(_selectedDate!).take(3).map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: event.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!event.isAllDay)
                                  Text(
                                    '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _weekdayNames
                  .map(
                    (day) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Calendar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CalendarGrid(
                focusedMonth: _focusedMonth,
                monthNames: _monthNames,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  final dayEvents = _getEventsForDate(date);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        dayEvents.isNotEmpty
                            ? '${date.day} ${_monthNames[date.month - 1]}: ${dayEvents.length} event(s)'
                            : 'Selected: ${date.day} ${_monthNames[date.month - 1]} ${date.year}',
                      ),
                      backgroundColor: dayEvents.isNotEmpty ? Colors.green : Colors.purple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add_circle_outline,
                    label: 'Add Event',
                    onTap: () => _addEvent(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.today,
                    label: 'View Events',
                    onTap: () => _viewEvents(context),
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.purple),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
