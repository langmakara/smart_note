import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/note_model.dart';
import '../../../providers/theme_provider.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;
  final Note Function(String title, String content, Color color) onSave;

  const NoteEditPage({
    super.key,
    this.note,
    required this.onSave,
  });

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color _selectedColor;
  final List<Color> _colorOptions = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? Colors.purple;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a title or content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final note = widget.onSave(
      _titleController.text.trim(),
      _contentController.text.trim(),
      _selectedColor,
    );
    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: TextStyle(
            color: themeProvider.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: themeProvider.accentColor),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      'Note Color',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colorOptions.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = color);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
                                        color: color.withOpacity(0.4),
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
              const SizedBox(height: 16),
              // Title Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Note Title',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 12),
              // Content Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Write your note here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  maxLines: 15,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
              const SizedBox(height: 16),
              // Info
              if (widget.note != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Created: ${_formatDate(widget.note!.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _selectedColor,
        onPressed: _saveNote,
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
