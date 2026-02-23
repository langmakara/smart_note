import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/event_storage.dart';
import '../../../services/notification_service.dart';
import '../../../services/toast_service.dart';

class ModernEventBottomSheet extends StatefulWidget {
  final Event? event;
  final DateTime? selectedDate;
  final Function(Event)? onEventCreated;

  const ModernEventBottomSheet({
    super.key,
    this.event,
    this.selectedDate,
    this.onEventCreated,
  });

  @override
  State<ModernEventBottomSheet> createState() => _ModernEventBottomSheetState();
}

class _ModernEventBottomSheetState extends State<ModernEventBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  late DateTime _startDate;
  late TimeOfDay _startTimeOfDay;
  late TimeOfDay _endTimeOfDay;
  Color _selectedColor = Colors.blue;
  bool _isAllDay = false;
  String _selectedReminder = 'None';
  bool _isSaving = false;

  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
  ];

  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': 'None', 'value': 'None'},
    {'label': '10 min', 'value': '10'},
    {'label': '30 min', 'value': '30'},
    {'label': '1 hour', 'value': '60'},
    {'label': '1 day', 'value': '1440'},
    {'label': '1 week', 'value': '10080'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event?.title ?? '';
    _descriptionController.text = widget.event?.description ?? '';

    final now = widget.selectedDate ?? DateTime.now();
    _startDate = widget.event?.startTime ?? now;
    _startTimeOfDay = TimeOfDay.fromDateTime(
      widget.event?.startTime ?? DateTime(now.year, now.month, now.day, 9, 0),
    );
    _endTimeOfDay = TimeOfDay.fromDateTime(
      widget.event?.endTime ?? DateTime(now.year, now.month, now.day, 10, 0),
    );

    if (widget.event != null) {
      _selectedColor = widget.event!.color;
      _isAllDay = widget.event!.isAllDay;
      _selectedReminder = widget.event!.reminderMinutes?.toString() ?? 'None';
    }

    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _hapticFeedback() async {
    await HapticFeedback.lightImpact();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              primary: _selectedColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _hapticFeedback();
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTimeOfDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              primary: _selectedColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTimeOfDay = picked);
      if (_endTimeOfDay.hour < picked.hour ||
          (_endTimeOfDay.hour == picked.hour &&
              _endTimeOfDay.minute <= picked.minute)) {
        setState(
          () => _endTimeOfDay = TimeOfDay(
            hour: picked.hour + 1,
            minute: picked.minute,
          ),
        );
      }
      _hapticFeedback();
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTimeOfDay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _selectedColor,
              primary: _selectedColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTimeOfDay = picked);
      _hapticFeedback();
    }
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService.showWarning(message: 'Enter event title');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _isAllDay ? 0 : _startTimeOfDay.hour,
        _isAllDay ? 0 : _startTimeOfDay.minute,
      );

      final endDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _isAllDay ? 23 : _endTimeOfDay.hour,
        _isAllDay ? 59 : _endTimeOfDay.minute,
      );

      final event = Event(
        id:
            widget.event?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        color: _selectedColor,
        isAllDay: _isAllDay,
        location: null,
        reminderMinutes: _selectedReminder == 'None'
            ? null
            : int.parse(_selectedReminder),
      );

      if (widget.event != null) {
        await EventStorage.instance.update(event);
        await NotificationService.instance.cancelEventReminder(
          widget.event!.id,
        );
      } else {
        await EventStorage.instance.create(event);
      }

      await NotificationService.instance.scheduleEventReminder(event);
      widget.onEventCreated?.call(event);

      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(
          message: widget.event != null ? 'Event updated!' : 'Event created!',
        );
        _hapticFeedback();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(message: 'Failed to save');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _deleteEvent() {
    if (widget.event == null) return;

    showDialog<bool>(
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
        content: const Text('This event will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await EventStorage.instance.delete(widget.event!.id);
              await NotificationService.instance.cancelEventReminder(
                widget.event!.id,
              );
              if (!mounted) return;
              navigator.pop();
              navigator.pop();
              ToastService.showSuccess(message: 'Event deleted');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              const SizedBox(height: 24),
              _buildTitleField(themeProvider),
              const SizedBox(height: 20),
              _buildDateTimeSection(themeProvider),
              const SizedBox(height: 16),
              _buildDescriptionField(themeProvider),
              const SizedBox(height: 16),
              _buildReminderSection(themeProvider),
              const SizedBox(height: 16),
              _buildColorPicker(themeProvider),
              const SizedBox(height: 24),
              _buildButtons(),
              const SizedBox(height: 8),
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

  Widget _buildTitleField(ThemeProvider themeProvider) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: themeProvider.textColor,
      ),
      decoration: InputDecoration(
        hintText: 'Event title',
        hintStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: themeProvider.subtitleColor.withValues(alpha: 0.5),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.next,
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
              _buildDateTimeChip(
                icon: Icons.calendar_today,
                label: _formatDate(_startDate),
                onTap: _selectDate,
                isSelected: true,
                themeProvider: themeProvider,
              ),
              if (!_isAllDay) ...[
                const SizedBox(width: 8),
                _buildDateTimeChip(
                  icon: Icons.access_time,
                  label: _formatTime(_startTimeOfDay),
                  onTap: _selectStartTime,
                  isSelected: true,
                  themeProvider: themeProvider,
                ),
                const SizedBox(width: 8),
                _buildDateTimeChip(
                  icon: Icons.schedule,
                  label: _formatTime(_endTimeOfDay),
                  onTap: _selectEndTime,
                  isSelected: true,
                  themeProvider: themeProvider,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() => _isAllDay = !_isAllDay);
              _hapticFeedback();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: _isAllDay
                    ? _selectedColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isAllDay
                      ? _selectedColor
                      : themeProvider.dividerColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAllDay
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: _isAllDay
                        ? _selectedColor
                        : themeProvider.subtitleColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
    required ThemeProvider themeProvider,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: _selectedColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ThemeProvider themeProvider) {
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      style: TextStyle(fontSize: 14, color: themeProvider.textColor),
      decoration: InputDecoration(
        hintText: 'Add description',
        hintStyle: TextStyle(
          fontSize: 14,
          color: themeProvider.subtitleColor.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(
          Icons.notes,
          size: 18,
          color: themeProvider.subtitleColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeProvider.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildReminderSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedReminder == 'None'
                    ? themeProvider.dividerColor.withValues(alpha: 0.3)
                    : _selectedColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _selectedReminder == 'None'
                    ? Icons.notifications_off
                    : Icons.notifications_active,
                size: 18,
                color: _selectedReminder == 'None'
                    ? themeProvider.subtitleColor
                    : _selectedColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Reminder',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: themeProvider.textColor,
              ),
            ),
            const Spacer(),
            if (_selectedReminder != 'None')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _reminderOptions.firstWhere(
                        (o) => o['value'] == _selectedReminder,
                      )['label']
                      as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeProvider.dividerColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ..._reminderOptions.asMap().entries.map((entry) {
                final isSelected = _selectedReminder == entry.value['value'];
                final isLast = entry.key == _reminderOptions.length - 1;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(
                          () => _selectedReminder =
                              entry.value['value'] as String,
                        );
                        _hapticFeedback();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withValues(alpha: 0.15)
                                    : themeProvider.cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getReminderIcon(
                                  entry.value['value'] as String,
                                ),
                                size: 16,
                                color: isSelected
                                    ? _selectedColor
                                    : themeProvider.subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              entry.value['label'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? _selectedColor
                                    : themeProvider.textColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: themeProvider.subtitleColor,
                                        width: 2,
                                      ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) const SizedBox(height: 4),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getReminderIcon(String value) {
    switch (value) {
      case 'None':
        return Icons.notifications_off;
      case '10':
        return Icons.timer_10;
      case '30':
        return Icons.timer_3;
      case '60':
        return Icons.schedule;
      case '1440':
        return Icons.calendar_today;
      case '10080':
        return Icons.date_range;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildColorPicker(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: themeProvider.subtitleColor,
          ),
        ),
        Row(
          children: _colors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedColor = color);
                _hapticFeedback();
              },
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        if (widget.event != null)
          IconButton(
            onPressed: _deleteEvent,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
            ),
          ),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.event != null ? 'Update Event' : 'Create Event',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
