import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/event_storage.dart';

void showEventDetailSheet(
  BuildContext context,
  Event event, {
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required VoidCallback onToggleDone,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => EventDetailSheet(
      event: event,
      onEdit: onEdit,
      onDelete: onDelete,
      onToggleDone: onToggleDone,
    ),
  );
}

class EventDetailSheet extends StatefulWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const EventDetailSheet({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  State<EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends State<EventDetailSheet> {
  late Event _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  Future<void> _hapticFeedback() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> _toggleDone() async {
    setState(() {
      _currentEvent = _currentEvent.copyWith(isDone: !_currentEvent.isDone);
    });
    widget.onToggleDone();
    await _saveEvent();
    _hapticFeedback();
  }

  Future<void> _saveEvent() async {
    await EventStorage.instance.update(_currentEvent);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(themeProvider),
              const SizedBox(height: 20),
              if (_currentEvent.description.isNotEmpty)
                _buildDescription(themeProvider),
              const SizedBox(height: 16),
              _buildDateTimeSection(themeProvider),
              const SizedBox(height: 16),
              if (_currentEvent.location != null &&
                  _currentEvent.location!.isNotEmpty)
                _buildLocation(themeProvider),
              const SizedBox(height: 16),
              _buildMetaInfo(themeProvider),
              const SizedBox(height: 24),
              _buildActions(context, themeProvider),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleDone,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _currentEvent.isDone
                    ? Colors.green
                    : _currentEvent.color.withValues(alpha: 0.5),
                width: 2,
              ),
              color: _currentEvent.isDone ? Colors.green : Colors.transparent,
            ),
            child: _currentEvent.isDone
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentEvent.title.isEmpty ? 'Untitled' : _currentEvent.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _currentEvent.isDone
                      ? themeProvider.subtitleColor
                      : themeProvider.textColor,
                  decoration: _currentEvent.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              if (_currentEvent.isDone) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentEvent.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _currentEvent.color.withValues(alpha: 0.1)),
      ),
      child: Text(
        _currentEvent.description,
        style: TextStyle(
          fontSize: 15,
          color: _currentEvent.isDone
              ? themeProvider.subtitleColor
              : themeProvider.textColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDateTimeTile(
                icon: Icons.calendar_today,
                label: 'Date',
                value: _formatDate(_currentEvent.startTime),
                themeProvider: themeProvider,
              ),
              if (!_currentEvent.isAllDay) ...[
                const SizedBox(width: 10),
                _buildDateTimeTile(
                  icon: Icons.access_time,
                  label: 'Start',
                  value: _formatTime(_currentEvent.startTime),
                  themeProvider: themeProvider,
                ),
                const SizedBox(width: 10),
                _buildDateTimeTile(
                  icon: Icons.schedule,
                  label: 'End',
                  value: _formatTime(_currentEvent.endTime),
                  themeProvider: themeProvider,
                ),
              ],
            ],
          ),
          if (_currentEvent.isAllDay) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _currentEvent.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentEvent.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: _currentEvent.color),
                  const SizedBox(width: 8),
                  Text(
                    'All Day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _currentEvent.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: themeProvider.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: _currentEvent.color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: themeProvider.subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: themeProvider.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeProvider.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 18, color: themeProvider.subtitleColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentEvent.location!,
              style: TextStyle(fontSize: 14, color: themeProvider.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMetaRow(
            icon: Icons.calendar_today,
            label: 'Created',
            value: _formatDate(_currentEvent.startTime),
            themeProvider: themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: themeProvider.subtitleColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: themeProvider.subtitleColor),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onEdit();
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleDone,
            icon: Icon(
              _currentEvent.isDone ? Icons.undo : Icons.check_circle,
              size: 18,
            ),
            label: Text(_currentEvent.isDone ? 'Undone' : 'Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentEvent.isDone
                  ? Colors.orange
                  : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onDelete();
          },
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
