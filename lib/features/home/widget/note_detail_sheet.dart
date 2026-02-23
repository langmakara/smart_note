import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/note_model.dart';
import '../../../providers/theme_provider.dart';

void showNoteDetailSheet(
  BuildContext context,
  Note note, {
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) =>
        NoteDetailSheet(note: note, onEdit: onEdit, onDelete: onDelete),
  );
}

class NoteDetailSheet extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteDetailSheet({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

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
              if (note.content.isNotEmpty) ...[
                _buildContent(themeProvider),
                const SizedBox(height: 20),
              ],
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
          decoration: BoxDecoration(color: note.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                  height: 1.3,
                ),
              ),
              if (note.category.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: note.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: note.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: note.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: note.color.withValues(alpha: 0.1)),
      ),
      child: Text(
        note.content,
        style: TextStyle(
          fontSize: 16,
          color: themeProvider.textColor,
          height: 1.6,
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
            value: _formatDate(note.createdAt),
            themeProvider: themeProvider,
          ),
          if (note.updatedAt != null) ...[
            const SizedBox(height: 12),
            Divider(color: themeProvider.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            _buildMetaRow(
              icon: Icons.update,
              label: 'Updated',
              value: _formatDate(note.updatedAt!),
              themeProvider: themeProvider,
            ),
          ],
          if (note.isPinned) ...[
            const SizedBox(height: 12),
            Divider(color: themeProvider.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            _buildMetaRow(
              icon: Icons.push_pin,
              label: 'Status',
              value: 'Pinned',
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
              onEdit();
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
              onDelete();
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
