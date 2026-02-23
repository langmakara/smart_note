import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/todo_storage.dart';
import '../../../services/toast_service.dart';

class ModernTodoBottomSheet extends StatefulWidget {
  final Todo? todo;

  const ModernTodoBottomSheet({super.key, this.todo});

  @override
  State<ModernTodoBottomSheet> createState() => _ModernTodoBottomSheetState();
}

class _ModernTodoBottomSheetState extends State<ModernTodoBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  Color _selectedColor = Colors.blue;
  String _selectedPriority = 'Medium';
  bool _isSaving = false;

  final List<TodoItem> _items = [];
  final TextEditingController _newItemController = TextEditingController();

  final List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  final List<Map<String, dynamic>> _priorityIcons = [
    {'label': 'Low', 'icon': Icons.arrow_downward, 'color': Colors.green},
    {'label': 'Medium', 'icon': Icons.remove, 'color': Colors.blue},
    {'label': 'High', 'icon': Icons.arrow_upward, 'color': Colors.orange},
    {'label': 'Urgent', 'icon': Icons.priority_high, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      final todo = widget.todo!;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description;
      _selectedColor = todo.color;
      _selectedPriority = todo.priority;
      _items.addAll(todo.items);
    }
    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _newItemController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (_titleController.text.trim().isEmpty) {
      ToastService.showWarning(message: 'Please add a title');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final todo = Todo(
        id: widget.todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: widget.todo?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        color: _selectedColor,
        priority: _selectedPriority,
        items: _items,
        isCompleted: widget.todo?.isCompleted ?? false,
      );

      if (widget.todo != null) {
        await TodoStorage.instance.update(todo);
      } else {
        await TodoStorage.instance.create(todo);
      }

      if (mounted) {
        Navigator.pop(context, todo);
        ToastService.showSuccess(message: 'To-Do saved!');
        _hapticFeedback();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(message: 'Failed to save to-do');
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

  void _addItem() {
    if (_newItemController.text.trim().isEmpty) return;

    setState(() {
      _items.add(
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _newItemController.text.trim(),
          isCompleted: false,
        ),
      );
      _newItemController.clear();
    });
    _hapticFeedback();
  }

  void _toggleItem(String itemId) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          isCompleted: !_items[index].isCompleted,
        );
      }
    });
    _hapticFeedback();
  }

  void _removeItem(String itemId) {
    setState(() {
      _items.removeWhere((item) => item.id == itemId);
    });
  }

  void _deleteTodo() {
    if (widget.todo == null) return;

    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete To-Do'),
          ],
        ),
        content: const Text('This to-do will be permanently deleted.'),
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
        await TodoStorage.instance.delete(widget.todo!.id);
        if (mounted) {
          Navigator.pop(context);
          ToastService.showSuccess(message: 'To-Do deleted');
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
              _buildDescriptionInput(themeProvider),
              const SizedBox(height: 16),
              _buildPrioritySelector(),
              const SizedBox(height: 16),
              _buildChecklistSection(themeProvider),
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
        hintText: 'What needs to be done?',
        hintStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: themeProvider.subtitleColor.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => _descriptionFocusNode.requestFocus(),
    );
  }

  Widget _buildDescriptionInput(ThemeProvider themeProvider) {
    return TextField(
      controller: _descriptionController,
      focusNode: _descriptionFocusNode,
      maxLines: 2,
      style: TextStyle(
        fontSize: 16,
        color: themeProvider.textColor,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Add details (optional)',
        hintStyle: TextStyle(
          fontSize: 16,
          color: themeProvider.subtitleColor.withValues(alpha: 0.6),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _priorityIcons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final priority = _priorityIcons[index];
              final isSelected = _selectedPriority == priority['label'];

              return ChoiceChip(
                avatar: Icon(
                  priority['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : priority['color'] as Color,
                ),
                label: Text(
                  priority['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : themeProvider.textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                selectedColor: priority['color'] as Color,
                backgroundColor: themeProvider.dividerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(
                      () => _selectedPriority = priority['label'] as String,
                    );
                    _hapticFeedback();
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Checklist',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${_items.where((item) => item.isCompleted).length}/${_items.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selectedColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._items.map((item) => _buildChecklistItem(item, themeProvider)),
        _buildAddItemField(themeProvider),
      ],
    );
  }

  Widget _buildChecklistItem(TodoItem item, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleItem(item.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted
                      ? _selectedColor
                      : themeProvider.dividerColor,
                  width: 2,
                ),
                color: item.isCompleted ? _selectedColor : Colors.transparent,
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontSize: 15,
                color: item.isCompleted
                    ? themeProvider.subtitleColor
                    : themeProvider.textColor,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeItem(item.id),
            icon: Icon(
              Icons.close,
              size: 18,
              color: themeProvider.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemField(ThemeProvider themeProvider) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: themeProvider.dividerColor, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _newItemController,
            style: TextStyle(fontSize: 15, color: themeProvider.textColor),
            decoration: InputDecoration(
              hintText: 'Add an item',
              hintStyle: TextStyle(
                fontSize: 15,
                color: themeProvider.subtitleColor.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _addItem(),
          ),
        ),
        IconButton(
          onPressed: _addItem,
          icon: Icon(Icons.add, color: _selectedColor),
        ),
      ],
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
          children: _colors.map((color) => _buildColorOption(color)).toList(),
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
        if (widget.todo != null)
          IconButton(
            onPressed: _deleteTodo,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        const SizedBox(width: 8),
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
            onPressed: _isSaving ? null : _saveTodo,
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
              widget.todo != null ? 'Update' : 'Add To-Do',
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
