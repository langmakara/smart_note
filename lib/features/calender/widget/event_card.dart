import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: themeProvider.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              left: BorderSide(
                color: event.isDone ? Colors.green : event.color,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (event.isDone)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title.isEmpty ? 'Untitled' : event.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: event.isDone
                                ? themeProvider.subtitleColor
                                : themeProvider.textColor,
                            decoration: event.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.subtitleColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: themeProvider.subtitleColor.withValues(alpha: 0.7),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (event.isAllDay)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeProvider.searchFillColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'All Day',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.subtitleColor,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: themeProvider.subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  if (event.location != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: themeProvider.subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
