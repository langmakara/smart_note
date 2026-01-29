import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../widget/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "Reminder: Project Meeting",
      "description": "Don't forget to check your notes for the meeting at 2:00 PM.",
      "time": "2 mins ago",
      "icon": Icons.notifications_active,
      "iconColor": Colors.orange,
      "isRead": false,
    },
    {
      "title": "New Feature Available!",
      "description": "Now you can sync your notes with Google Drive.",
      "time": "1 hour ago",
      "icon": Icons.star,
      "iconColor": Colors.purple,
      "isRead": false,
    },
    {
      "title": "Security Update",
      "description": "Your password was changed successfully.",
      "time": "Yesterday",
      "icon": Icons.security,
      "iconColor": Colors.green,
      "isRead": true,
    },
    {
      "title": "Subscription Renewal",
      "description": "Your premium plan will renew in 3 days.",
      "time": "2 days ago",
      "icon": Icons.payment,
      "iconColor": Colors.blue,
      "isRead": true,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification["isRead"] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications marked as read"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]["isRead"] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Notification deleted"),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notifications.insert(index, _notifications[index]);
            });
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _newNotifications {
    return _notifications.where((n) => !n["isRead"]).toList();
  }

  List<Map<String, dynamic>> get _earlierNotifications {
    return _notifications.where((n) => n["isRead"]).toList();
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
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n["isRead"]))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                "Mark all as read",
                style: TextStyle(
                  color: themeProvider.accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: themeProvider.subtitleColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications",
                    style: TextStyle(
                      fontSize: 18,
                      color: themeProvider.subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're all caught up!",
                    style: TextStyle(color: themeProvider.subtitleColor.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_newNotifications.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "New",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _newNotifications.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._newNotifications.map((notification) {
                    final index = _notifications.indexOf(notification);
                    return NotificationTile(
                      title: notification["title"],
                      description: notification["description"],
                      time: notification["time"],
                      icon: notification["icon"],
                      iconColor: notification["iconColor"],
                      isRead: notification["isRead"],
                      onTap: () => _markAsRead(index),
                      onLongPress: () => _deleteNotification(index),
                    );
                  }),
                ],
                if (_earlierNotifications.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Earlier",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._earlierNotifications.map((notification) {
                    final index = _notifications.indexOf(notification);
                    return NotificationTile(
                      title: notification["title"],
                      description: notification["description"],
                      time: notification["time"],
                      icon: notification["icon"],
                      iconColor: notification["iconColor"],
                      isRead: notification["isRead"],
                      onTap: () {},
                      onLongPress: () => _deleteNotification(index),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
