import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/todo_storage.dart';
import '../../../services/toast_service.dart';

void showTodoDetailSheet(
  BuildContext context,
  Todo todo, {
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  required VoidCallback onToggleItem,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => TodoDetailSheet(
      todo: todo,
      onEdit: onEdit,
      onDelete: onDelete,
      onToggleItem: onToggleItem,
    ),
  );
}

class TodoDetailSheet extends StatefulWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleItem;

  const TodoDetailSheet({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleItem,
  });

  @override
  State<TodoDetailSheet> createState() => _TodoDetailSheetState();
}

class _TodoDetailSheetState extends State<TodoDetailSheet> {
  late Todo _currentTodo;

  @override
  void initState() {
    super.initState();
    _currentTodo = widget.todo;
  }

  Future<void> _hapticFeedback() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> _toggleItem(String itemId) async {
    setState(() {
      final index = _currentTodo.items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _currentTodo.items[index] = _currentTodo.items[index].copyWith(
          isCompleted: !_currentTodo.items[index].isCompleted,
        );
      }
    });
    widget.onToggleItem();
    await _saveTodo();
    _hapticFeedback();
  }

  Future<void> _saveTodo() async {
    await TodoStorage.instance.update(_currentTodo);
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

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'Low':
        return '🟢 Low';
      case 'Medium':
        return '🔵 Medium';
      case 'High':
        return '🟠 High';
      case 'Urgent':
        return '🔴 Urgent';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final progress = _currentTodo.progress;

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
              const SizedBox(height: 16),
              if (_currentTodo.description.isNotEmpty)
                _buildDescription(themeProvider),
              const SizedBox(height: 16),
              _buildProgressIndicator(progress, themeProvider),
              if (_currentTodo.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildChecklist(themeProvider),
              ],
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _currentTodo.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTodo.title.isEmpty ? 'Untitled' : _currentTodo.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(),
                  if (_currentTodo.isCompleted) ...[
                    const SizedBox(width: 8),
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
                          Icon(Icons.check, size: 12, color: Colors.green),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _currentTodo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getPriorityLabel(_currentTodo.priority),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _currentTodo.color,
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentTodo.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _currentTodo.color.withValues(alpha: 0.1)),
      ),
      child: Text(
        _currentTodo.description,
        style: TextStyle(
          fontSize: 15,
          color: themeProvider.textColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress, ThemeProvider themeProvider) {
    final percent = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _currentTodo.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: _currentTodo.color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _currentTodo.isCompleted ? Colors.green : _currentTodo.color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentTodo.completedItems}/${_currentTodo.totalItems} items completed',
          style: TextStyle(fontSize: 13, color: themeProvider.subtitleColor),
        ),
      ],
    );
  }

  Widget _buildChecklist(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _currentTodo.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              setState(() {
                _currentTodo.items.removeAt(index);
              });
              await _saveTodo();
              widget.onToggleItem();
              ToastService.showInfo(message: 'Item removed');
            },
            child: _buildChecklistItem(item, themeProvider),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChecklistItem(TodoItem item, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _toggleItem(item.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeProvider.dividerColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isCompleted
                      ? Colors.green
                      : _currentTodo.color.withValues(alpha: 0.5),
                  width: 2,
                ),
                color: item.isCompleted ? Colors.green : Colors.transparent,
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
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
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
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
            value: _formatDate(_currentTodo.createdAt),
            themeProvider: themeProvider,
          ),
          if (_currentTodo.updatedAt != null) ...[
            const SizedBox(height: 12),
            Divider(color: themeProvider.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            _buildMetaRow(
              icon: Icons.update,
              label: 'Updated',
              value: _formatDate(_currentTodo.updatedAt!),
              themeProvider: themeProvider,
            ),
          ],
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
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
