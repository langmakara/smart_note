import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../widget/event_card.dart';
import 'event_edit_page.dart';

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
      final matchesSearch = event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesColor = _filterColor == null || event.color == _filterColor;
      final matchesDate = widget.selectedDate == null || event.isOnDate(widget.selectedDate!);
      return matchesSearch && matchesColor && matchesDate;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Map<DateTime, List<Event>> get _eventsByDate {
    final Map<DateTime, List<Event>> grouped = {};
    for (final event in _filteredEvents) {
      final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
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
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: themeProvider.cardColor,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: Icon(Icons.search, color: themeProvider.subtitleColor),
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
                const SizedBox(height: 12),
                // Color Filter
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
                            _buildColorFilter(Colors.blue, 'Blue', themeProvider),
                            const SizedBox(width: 4),
                            _buildColorFilter(themeProvider.accentColor, 'Accent', themeProvider),
                            const SizedBox(width: 4),
                            _buildColorFilter(Colors.green, 'Green', themeProvider),
                            const SizedBox(width: 4),
                            _buildColorFilter(Colors.orange, 'Orange', themeProvider),
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
          // Events List
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: themeProvider.subtitleColor.withOpacity(0.5),
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
                            color: themeProvider.subtitleColor.withOpacity(0.7),
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
                          // Date Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: themeProvider.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: themeProvider.accentColor.withValues(alpha: 0.2), width: 0.5),
                            ),
                            child: Text(
                              _formatDate(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.accentColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Events for this date
                          ...events.map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: EventCard(
                              event: event,
                              onTap: () => _editEvent(context, event),
                              onDelete: () => _confirmDelete(event),
                            ),
                          )),
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

  Widget _buildColorFilter(Color? color, String label, ThemeProvider themeProvider) {
    final isSelected = _filterColor == color;
    return GestureDetector(
      onTap: () {
        setState(() => _filterColor = isSelected ? null : color);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? themeProvider.accentColor : themeProvider.searchFillColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: themeProvider.dividerColor),
        ),
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  void _addEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventEditPage(
          selectedDate: widget.selectedDate,
          onSave: (event) {
            widget.onAddEvent(event);
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

  void _editEvent(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventEditPage(
          event: event,
          onSave: (updatedEvent) {
            widget.onEditEvent(updatedEvent);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Event "${updatedEvent.title}" updated!'),
                backgroundColor: Colors.blue,
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

  void _confirmDelete(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteEvent(event.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event "${event.title}" deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
