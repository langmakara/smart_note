import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/event_storage.dart';
import '../../../services/notification_service.dart';
import '../../../services/toast_service.dart';
import '../../../features/home/widget/modern_event_bottom_sheet.dart';
import '../widget/calendar_grid.dart';
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
    _loadEvents();
    _selectedDate = DateTime.now();
  }

  Future<void> _loadEvents() async {
    final events = await EventStorage.instance.readAllEvents();
    if (mounted) {
      setState(() {
        _events = events;
      });
    }
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
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
    showModalBottomSheet<Event>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernEventBottomSheet(
        selectedDate: _selectedDate,
        onEventCreated: (event) async {
          await EventStorage.instance.create(event);
          await NotificationService.instance.scheduleEventReminder(event);
          setState(() => _events.add(event));
          ToastService.showSuccess(message: 'Event "${event.title}" created!');
        },
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
          onAddEvent: (event) async {
            await EventStorage.instance.create(event);
            await NotificationService.instance.scheduleEventReminder(event);
            setState(() => _events.add(event));
          },
          onEditEvent: (event) async {
            await EventStorage.instance.update(event);
            await NotificationService.instance.cancelEventReminder(event.id);
            await NotificationService.instance.scheduleEventReminder(event);
            setState(() {
              final index = _events.indexWhere((e) => e.id == event.id);
              if (index != -1) {
                _events[index] = event;
              }
            });
          },
          onDeleteEvent: (eventId) async {
            await NotificationService.instance.cancelEventReminder(eventId);
            await EventStorage.instance.delete(eventId);
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

    final selectedDayEvents = _events
        .where(
          (event) => _selectedDate != null && event.isOnDate(_selectedDate!),
        )
        .toList();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(themeProvider),
            _buildWeekdayHeader(themeProvider),
            Expanded(
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
            _buildSelectedDateInfo(themeProvider, selectedDayEvents),
            _buildBottomBar(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.subtitleColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _navButton(
                icon: Icons.chevron_left,
                onPressed: () => _addMonths(-1),
                themeProvider: themeProvider,
              ),
              const SizedBox(width: 8),
              _navButton(
                icon: Icons.chevron_right,
                onPressed: () => _addMonths(1),
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }
  // Helper method to create navigation buttons
  Widget _navButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.searchFillColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: themeProvider.textColor),
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: _weekdayNames.asMap().entries.map((entry) {
          final isWeekend = entry.key >= 5;
          return Expanded(
            child: Center(
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isWeekend
                      ? themeProvider.subtitleColor.withValues(alpha: 0.6)
                      : themeProvider.subtitleColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedDateInfo(
    ThemeProvider themeProvider,
    List<Event> events,
  ) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final dayOfWeek = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    ).weekday;
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final formattedDate =
        '${weekdayNames[dayOfWeek - 1]}, ${_monthNames[_selectedDate!.month - 1]} ${_selectedDate!.day}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.searchFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeProvider.accentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${events.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  events.isEmpty
                      ? 'No events'
                      : '${events.length} event${events.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          if (events.isNotEmpty)
            TextButton(
              onPressed: () => _viewEvents(context),
              child: Text(
                'View All',
                style: TextStyle(
                  color: themeProvider.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.today,
                label: 'Today',
                onTap: _goToToday,
                themeProvider: themeProvider,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Event',
                onTap: () => _addEvent(context),
                isPrimary: true,
                themeProvider: themeProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? themeProvider.accentColor
              : themeProvider.searchFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : themeProvider.textColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isPrimary ? Colors.white : themeProvider.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
