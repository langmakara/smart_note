import 'package:flutter/material.dart';
import '../widget/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Mark all as read", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            "New",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          NotificationTile(
            title: "Reminder: Project Meeting",
            description: "Don't forget to check your notes for the meeting at 2:00 PM.",
            time: "2 mins ago",
            icon: Icons.notifications_active,
            iconColor: Colors.orange,
            isRead: false,
          ),
          NotificationTile(
            title: "New Feature Available!",
            description: "Now you can sync your notes with Google Drive.",
            time: "1 hour ago",
            icon: Icons.star,
            iconColor: Colors.purple,
            isRead: false,
          ),
          SizedBox(height: 20),
          Text(
            "Earlier",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          NotificationTile(
            title: "Security Update",
            description: "Your password was changed successfully.",
            time: "Yesterday",
            icon: Icons.security,
            iconColor: Colors.green,
            isRead: true,
          ),
          NotificationTile(
            title: "Subscription Renewal",
            description: "Your premium plan will renew in 3 days.",
            time: "2 days ago",
            icon: Icons.payment,
            iconColor: Colors.blue,
            isRead: true,
          ),
        ],
      ),
    );
  }
}