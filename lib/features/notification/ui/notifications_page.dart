import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/event_storage.dart';
import '../../../models/event_model.dart';
import '../widget/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _systemNotifications = const [];

  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventStorage.instance.readAllEvents();
      if (mounted) {
        setState(() {
          _events = events.where((e) => e.reminderMinutes != null).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(String type, ThemeProvider themeProvider) {
    switch (type) {
      case 'event':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return themeProvider.accentColor;
    }
  }

  String _formatNotificationTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _formatEventReminderTime(Event event) {
    final reminderTime = event.startTime.subtract(
      Duration(minutes: event.reminderMinutes ?? 0),
    );
    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.isNegative) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return 'In ${mins}m';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'In ${hours}h';
    } else {
      final days = difference.inDays;
      return 'In ${days}d';
    }
  }

  List<Map<String, dynamic>> get _unreadSystemNotifications {
    return _systemNotifications.where((n) => !(n["isRead"] as bool)).toList();
  }

  List<Event> get _upcomingEventReminders {
    final now = DateTime.now();
    return _events.where((e) {
      if (e.reminderMinutes == null) return false;
      final reminderTime = e.startTime.subtract(
        Duration(minutes: e.reminderMinutes!),
      );
      return reminderTime.isAfter(now) ||
          reminderTime.difference(now).inMinutes.abs() < 5;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> get _pastEventReminders {
    final now = DateTime.now();
    return _events.where((e) {
      if (e.reminderMinutes == null) return false;
      final reminderTime = e.startTime.subtract(
        Duration(minutes: e.reminderMinutes!),
      );
      return reminderTime.isBefore(now) &&
          reminderTime.difference(now).inMinutes.abs() >= 5;
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _systemNotifications.indexWhere((n) => n["id"] == id);
      if (index != -1) {
        _systemNotifications[index]["isRead"] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _systemNotifications) {
        notification["isRead"] = true;
      }
    });
  }

  void _deleteSystemNotification(String id) {
    setState(() {
      _systemNotifications.removeWhere((n) => n["id"] == id);
    });
  }

  Future<void> _refresh() async {
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final unreadCount =
        _unreadSystemNotifications.length + _upcomingEventReminders.length;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(themeProvider, unreadCount),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(themeProvider)
                  : _notificationsContent(themeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, int unreadCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unreadCount > 0
                        ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                        : 'All caught up!',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.subtitleColor,
                    ),
                  ),
                ],
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeProvider.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: Icon(
                          Icons.done_all,
                          size: 16,
                          color: themeProvider.accentColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: Text(
                          "Mark all read",
                          style: TextStyle(
                            color: themeProvider.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notificationsContent(ThemeProvider themeProvider) {
    final hasEventReminders =
        _upcomingEventReminders.isNotEmpty || _pastEventReminders.isNotEmpty;
    final hasSystemNotifications = _systemNotifications.isNotEmpty;

    if (!hasEventReminders && !hasSystemNotifications) {
      return _buildEmptyState(themeProvider);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: themeProvider.accentColor,
      backgroundColor: themeProvider.cardColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_upcomingEventReminders.isNotEmpty) ...[
            _buildSectionHeader(
              "Upcoming Reminders",
              _upcomingEventReminders.length,
              themeProvider,
              icon: Icons.schedule,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),
            ..._upcomingEventReminders.map((event) {
              return _buildEventReminderTile(
                event,
                themeProvider,
                isUpcoming: true,
              );
            }),
            const SizedBox(height: 20),
          ],
          if (_pastEventReminders.isNotEmpty) ...[
            _buildSectionHeader(
              "Past Reminders",
              _pastEventReminders.length,
              themeProvider,
              icon: Icons.history,
              iconColor: themeProvider.subtitleColor,
            ),
            const SizedBox(height: 12),
            ..._pastEventReminders.take(5).map((event) {
              return _buildEventReminderTile(
                event,
                themeProvider,
                isUpcoming: false,
              );
            }),
            const SizedBox(height: 20),
          ],
          if (_unreadSystemNotifications.isNotEmpty) ...[
            _buildSectionHeader(
              "Updates",
              _unreadSystemNotifications.length,
              themeProvider,
              icon: Icons.info_outline,
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            ..._unreadSystemNotifications.map((notification) {
              return NotificationTile(
                id: notification["id"] as String,
                title: notification["title"] as String,
                description: notification["description"] as String,
                time: _formatNotificationTime(notification["time"] as DateTime),
                icon: _getTypeIcon(notification["type"] as String),
                iconColor: _getTypeColor(
                  notification["type"] as String,
                  themeProvider,
                ),
                isRead: notification["isRead"] as bool,
                onTap: () => _markAsRead(notification["id"] as String),
                onDelete: () =>
                    _deleteSystemNotification(notification["id"] as String),
                themeProvider: themeProvider,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildEventReminderTile(
    Event event,
    ThemeProvider themeProvider, {
    required bool isUpcoming,
  }) {
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(event.title);
        }
        return false;
      },
      onDismissed: (direction) {
        EventStorage.instance.delete(event.id);
        setState(() {
          _events.removeWhere((e) => e.id == event.id);
        });
      },
      child: GestureDetector(
        onTap: () => _showEventDetails(event),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isUpcoming
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      event.color.withValues(alpha: 0.1),
                      event.color.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            color: isUpcoming ? null : themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUpcoming
                  ? event.color.withValues(alpha: 0.3)
                  : themeProvider.dividerColor.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: themeProvider.shadowColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [event.color.withValues(alpha: 0.9), event.color],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: event.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isUpcoming ? Icons.notifications_active : Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: themeProvider.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (event.description.isNotEmpty)
                      Text(
                        event.description,
                        style: TextStyle(
                          color: themeProvider.subtitleColor,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isUpcoming
                              ? event.color
                              : themeProvider.subtitleColor.withValues(
                                  alpha: 0.6,
                                ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isUpcoming
                              ? _formatEventReminderTime(event)
                              : _formatEventReminderTime(event),
                          style: TextStyle(
                            color: isUpcoming
                                ? event.color
                                : themeProvider.subtitleColor.withValues(
                                    alpha: 0.7,
                                  ),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: themeProvider.subtitleColor.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.startTime.day}/${event.startTime.month}',
                          style: TextStyle(
                            color: themeProvider.subtitleColor.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.dividerColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: themeProvider.subtitleColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    int count,
    ThemeProvider themeProvider, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: themeProvider.accentColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading...",
            style: TextStyle(color: themeProvider.subtitleColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: themeProvider.dividerColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 60,
              color: themeProvider.subtitleColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Notifications",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "No upcoming event reminders",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: themeProvider.subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }

  Future<bool> _showDeleteConfirmation(String title) async {
    final result = await showDialog<bool>(
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
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete'),
          ],
        ),
        content: Text('Remove reminder for "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildEventDetailsSheet(event),
    );
  }

  Widget _buildEventDetailsSheet(Event event) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeProvider.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.event, color: event.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor,
                          ),
                        ),
                        if (event.description.isNotEmpty)
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.subtitleColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.calendar_today,
                "Date",
                "${event.startTime.day}/${event.startTime.month}/${event.startTime.year}",
                themeProvider,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.access_time,
                "Time",
                "${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}",
                themeProvider,
              ),
              const SizedBox(height: 12),
              if (event.location != null)
                _buildDetailRow(
                  Icons.location_on,
                  "Location",
                  event.location!,
                  themeProvider,
                ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.notifications,
                "Reminder",
                event.reminderMinutes != null
                    ? "${event.reminderMinutes} min before"
                    : "None",
                themeProvider,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: themeProvider.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.dividerColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: themeProvider.subtitleColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.subtitleColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: themeProvider.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
