import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/event_model.dart';
import '../../../providers/theme_provider.dart';

class EventEditPage extends StatefulWidget {
  final Event? event;
  final DateTime? selectedDate;
  final Function(Event) onSave;

  const EventEditPage({
    super.key,
    this.event,
    this.selectedDate,
    required this.onSave,
  });

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startTime;
  late DateTime _endTime;
  late Color _selectedColor;
  bool _isAllDay = false;

  final List<Color> _eventColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');

    if (widget.event != null) {
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
      _selectedColor = widget.event!.color;
      _isAllDay = widget.event!.isAllDay;
    } else {
      final now = widget.selectedDate ?? DateTime.now();
      _startTime = DateTime(now.year, now.month, now.day, 9, 0);
      _endTime = DateTime(now.year, now.month, now.day, 10, 0);
      _selectedColor = Colors.blue;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate(DateTime date) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        _endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = Event(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        color: _selectedColor,
        isAllDay: _isAllDay,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
      );
      widget.onSave(event);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.event != null ? 'Edit Event' : 'Add Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'Enter event title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter event description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Location (Optional)',
                hint: 'Enter event location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              // All Day Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: themeProvider.accentColor),
                    const SizedBox(width: 12),
                    const Text(
                      'All Day Event',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() => _isAllDay = value);
                      },
                      activeColor: themeProvider.accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeButton(
                            label: 'Date',
                            value:
                                '${_startTime.day}/${_startTime.month}/${_startTime.year}',
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(_startTime),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!_isAllDay) ...[
                          Expanded(
                            child: _buildDateTimeButton(
                              label: 'Start',
                              value:
                                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                              icon: Icons.access_time,
                              onTap: _selectStartTime,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateTimeButton(
                              label: 'End',
                              value:
                                  '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                              icon: Icons.access_time,
                              onTap: _selectEndTime,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _eventColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = color);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.event != null ? 'Update Event' : 'Create Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: themeProvider.accentColor),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(color: themeProvider.accentColor),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Material(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: themeProvider.accentColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'delete');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
