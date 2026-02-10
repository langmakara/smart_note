import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NotificationTile({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead
              ? themeProvider.cardColor
              : themeProvider.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: isRead ? Border.all(color: themeProvider.dividerColor) : null,
          boxShadow: isRead
              ? [
                  BoxShadow(
                    color: themeProvider.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: themeProvider.subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: themeProvider.subtitleColor.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
