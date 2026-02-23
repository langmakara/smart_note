import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/note_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/note_storage.dart';
import '../../../services/toast_service.dart';

class ModernNoteBottomSheet extends StatefulWidget {
  final Note? note;
  final Function(Note)? onNoteUpdated;

  const ModernNoteBottomSheet({super.key, this.note, this.onNoteUpdated});

  @override
  State<ModernNoteBottomSheet> createState() => _ModernNoteBottomSheetState();
}

class _ModernNoteBottomSheetState extends State<ModernNoteBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  Color _selectedColor = Colors.purple;
  String _selectedCategory = 'Personal';
  bool _isSaving = false;

  final List<Color> _colors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  final List<Map<String, dynamic>> _categoryIcons = [
    {'label': 'Personal', 'icon': Icons.person_outline},
    {'label': 'Work', 'icon': Icons.work_outline},
    {'label': 'Home', 'icon': Icons.home_outlined},
    {'label': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'label': 'Ideas', 'icon': Icons.lightbulb_outline},
    {'label': 'Important', 'icon': Icons.star_border},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      final note = widget.note!;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedColor = note.color;
      _selectedCategory = note.category;
    }
    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      ToastService.showWarning(message: 'Please add a title or content');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        color: _selectedColor,
        category: _selectedCategory,
        isPinned: widget.note?.isPinned ?? false,
      );

      if (widget.note != null) {
        await NoteStorage.instance.update(note);
        widget.onNoteUpdated?.call(note);
      } else {
        await NoteStorage.instance.create(note);
      }

      if (mounted) {
        Navigator.pop(context, note);
        ToastService.showSuccess(message: 'Note saved!');
        _hapticFeedback();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(message: 'Failed to save note');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _hapticFeedback() async {
    await HapticFeedback.lightImpact();
  }

  void _deleteNote() {
    if (widget.note == null) return;

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Note'),
          ],
        ),
        content: const Text('This note will be permanently deleted.'),
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
    ).then((confirmed) async {
      if (confirmed == true) {
        await NoteStorage.instance.delete(widget.note!.id);
        if (mounted) {
          Navigator.pop(context);
          ToastService.showSuccess(message: 'Note deleted');
          _hapticFeedback();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 16),
              _buildTitleInput(themeProvider),
              const SizedBox(height: 12),
              _buildContentInput(themeProvider),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildColorPicker(),
              const SizedBox(height: 20),
              _buildActionButtons(themeProvider),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitleInput(ThemeProvider themeProvider) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocusNode,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: themeProvider.textColor,
      ),
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: themeProvider.subtitleColor.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _contentFocusNode.requestFocus(),
    );
  }

  Widget _buildContentInput(ThemeProvider themeProvider) {
    return TextField(
      controller: _contentController,
      focusNode: _contentFocusNode,
      maxLines: null,
      minLines: 3,
      style: TextStyle(
        fontSize: 16,
        color: themeProvider.textColor,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Write your note...',
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeProvider.subtitleColor.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCategoryChips() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryIcons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categoryIcons[index];
          final isSelected = _selectedCategory == category['label'];

          return ChoiceChip(
            avatar: Icon(
              category['icon'] as IconData,
              size: 16,
              color: isSelected ? Colors.white : themeProvider.subtitleColor,
            ),
            label: Text(
              category['label'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : themeProvider.textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            selectedColor: _selectedColor,
            backgroundColor: themeProvider.dividerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = category['label'] as String);
                _hapticFeedback();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: _colors
                  .map((color) => _buildColorOption(color))
                  .toList(),
            ),
            if (widget.note != null)
              IconButton(
                onPressed: _deleteNote,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete note',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedColor = color);
        _hapticFeedback();
      },
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveNote,
            icon: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(
              widget.note != null ? 'Update' : 'Save',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
