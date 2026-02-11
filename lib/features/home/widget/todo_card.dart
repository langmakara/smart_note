import 'package:flutter/material.dart';
import '../../../models/todo_model.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: todo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: todo.isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : todo.color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: todo.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              todo.title.isEmpty ? "Untitled" : todo.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: todo.isCompleted
                                    ? Colors.grey
                                    : todo.color,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: TextStyle(
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.grey[700],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onToggleDone,
                      icon: Icon(
                        todo.isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: todo.isCompleted ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      tooltip: todo.isCompleted
                          ? 'Mark as undone'
                          : 'Mark as done',
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            if (todo.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: todo.progress,
                  minHeight: 6,
                  backgroundColor: todo.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    todo.isCompleted ? Colors.green : todo.color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${todo.completedItems}/${todo.totalItems} completed',
                    style: TextStyle(
                      fontSize: 11,
                      color: todo.isCompleted ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                  if (todo.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(todo.createdAt),
                  style: TextStyle(
                    color: todo.color.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: todo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: todo.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
