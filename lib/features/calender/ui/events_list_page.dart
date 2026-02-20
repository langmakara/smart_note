import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/event_storage.dart';
import '../../../services/notification_service.dart';
import '../../../services/toast_service.dart';
import '../widget/event_card.dart';
import '../../../features/home/widget/modern_event_bottom_sheet.dart';
import '../../../features/home/widget/event_detail_sheet.dart';

class EventsListPage extends StatefulWidget {
  final List<Event> events;
  final DateTime? selectedDate;
  final Function(Event) onAddEvent;
  final Function(Event) onEditEvent;
  final Function(String) onDeleteEvent;

  const EventsListPage({
    super.key,
    required this.events,
    this.selectedDate,
    required this.onAddEvent,
    required this.onEditEvent,
    required this.onDeleteEvent,
  });

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  String _searchQuery = '';
  Color? _filterColor;

  List<Event> get _filteredEvents {
    return widget.events.where((event) {
      final matchesSearch =
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesColor = _filterColor == null || event.color == _filterColor;
      final matchesDate =
          widget.selectedDate == null || event.isOnDate(widget.selectedDate!);
      return matchesSearch && matchesColor && matchesDate;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Map<DateTime, List<Event>> get _eventsByDate {
    final Map<DateTime, List<Event>> grouped = {};
    for (final event in _filteredEvents) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      grouped[date] = [...(grouped[date] ?? []), event];
    }
    return grouped;
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
          widget.selectedDate != null ? 'Events' : 'All Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: themeProvider.accentColor),
            onPressed: () => _addEvent(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: themeProvider.cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: themeProvider.subtitleColor,
                          ),
                          filled: true,
                          fillColor: themeProvider.searchFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    if (widget.selectedDate != null &&
                        _filteredEvents.isNotEmpty)
                      const SizedBox(width: 12),
                    if (widget.selectedDate != null &&
                        _filteredEvents.isNotEmpty)
                      IconButton(
                        onPressed: () => _confirmDeleteAllForDate(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        tooltip: 'Delete all events for this day',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Filter by color:',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildColorFilter(null, 'All', themeProvider),
                            const SizedBox(width: 4),
                            _buildColorFilter(
                              Colors.blue,
                              'Blue',
                              themeProvider,
                            ),
                            const SizedBox(width: 4),
                            _buildColorFilter(
                              themeProvider.accentColor,
                              'Accent',
                              themeProvider,
                            ),
                            const SizedBox(width: 4),
                            _buildColorFilter(
                              Colors.green,
                              'Green',
                              themeProvider,
                            ),
                            const SizedBox(width: 4),
                            _buildColorFilter(
                              Colors.orange,
                              'Orange',
                              themeProvider,
                            ),
                            const SizedBox(width: 4),
                            _buildColorFilter(Colors.red, 'Red', themeProvider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: themeProvider.subtitleColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.selectedDate != null
                              ? 'No events for this date'
                              : 'No events found',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add an event',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.subtitleColor.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _eventsByDate.length,
                    itemBuilder: (context, index) {
                      final date = _eventsByDate.keys.elementAt(index);
                      final events = _eventsByDate[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: themeProvider.accentColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: themeProvider.accentColor.withValues(
                                  alpha: 0.2,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _formatDate(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.accentColor.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...events.map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: EventCard(
                                event: event,
                                onTap: () => _viewEvent(context, event),
                                onDelete: () => _confirmDelete(event),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEvent(context),
        backgroundColor: themeProvider.accentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildColorFilter(
    Color? color,
    String label,
    ThemeProvider themeProvider,
  ) {
    final isSelected = _filterColor == color;
    return GestureDetector(
      onTap: () {
        setState(() => _filterColor = isSelected ? null : color);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? themeProvider.accentColor
              : themeProvider.searchFillColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: themeProvider.dividerColor),
        ),
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            if (color != null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : themeProvider.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } else if (eventDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    } else {
      return '${_getWeekdayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  void _addEvent(BuildContext context) {
    showModalBottomSheet<Event>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModernEventBottomSheet(
        selectedDate: widget.selectedDate,
        onEventCreated: (event) async {
          await EventStorage.instance.create(event);
          await NotificationService.instance.scheduleEventReminder(event);
          widget.onAddEvent(event);
          ToastService.showSuccess(message: 'Event "${event.title}" created!');
        },
      ),
    );
  }

  void _viewEvent(BuildContext context, Event event) {
    showEventDetailSheet(
      context,
      event,
      onEdit: () => _editEvent(context, event),
      onDelete: () => _confirmDelete(event),
      onToggleDone: () => _toggleDone(event),
    );
  }

  void _editEvent(BuildContext context, Event event) {
    showModalBottomSheet<Event>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModernEventBottomSheet(
        event: event,
        selectedDate: widget.selectedDate,
        onEventCreated: (updatedEvent) async {
          await EventStorage.instance.update(updatedEvent);
          await NotificationService.instance.cancelEventReminder(event.id);
          await NotificationService.instance.scheduleEventReminder(
            updatedEvent,
          );
          widget.onEditEvent(updatedEvent);
          ToastService.showSuccess(message: 'Event updated!');
        },
      ),
    );
  }

  void _toggleDone(Event event) async {
    final updatedEvent = event.copyWith(isDone: !event.isDone);
    await EventStorage.instance.update(updatedEvent);
    widget.onEditEvent(updatedEvent);
    ToastService.showSuccess(
      message: updatedEvent.isDone
          ? 'Event marked as done!'
          : 'Event marked as undone!',
    );
  }

  void _confirmDelete(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Event'),
          ],
        ),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await EventStorage.instance.delete(event.id);
              await NotificationService.instance.cancelEventReminder(event.id);
              widget.onDeleteEvent(event.id);
              if (!mounted) return;
              navigator.pop();
              ToastService.showError(message: 'Event deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllForDate() {
    final dateEvents = _filteredEvents;
    final dateText = widget.selectedDate != null
        ? _formatDate(widget.selectedDate!)
        : 'this filter';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_sweep, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete All Events'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all ${dateEvents.length} events for $dateText? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllForDate();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllForDate() async {
    final dateEvents = _filteredEvents;

    for (final event in dateEvents) {
      await EventStorage.instance.delete(event.id);
      await NotificationService.instance.cancelEventReminder(event.id);
      widget.onDeleteEvent(event.id);
    }

    ToastService.showError(message: '${dateEvents.length} events deleted');
  }
}
