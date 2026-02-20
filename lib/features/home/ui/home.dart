import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/note_card.dart';
import '../widget/todo_card.dart';
import '../widget/modern_note_bottom_sheet.dart';
import '../widget/modern_todo_bottom_sheet.dart';
import '../widget/note_detail_sheet.dart';
import '../widget/todo_detail_sheet.dart';
import '../../../models/note_model.dart';
import '../../../models/todo_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/note_storage.dart';
import '../../../services/todo_storage.dart';
import '../../../services/toast_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Note> _notes = [];
  final List<Todo> _todos = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final notes = await NoteStorage.instance.readAllNotes();
      final todos = await TodoStorage.instance.readAllTodos();
      if (!mounted) return;
      setState(() {
        _notes.clear();
        _notes.addAll(notes);
        _todos.clear();
        _todos.addAll(todos);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.note_alt,
                  label: 'Note',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _addNote();
                  },
                ),
                _buildOptionButton(
                  icon: Icons.check_circle,
                  label: 'To-Do',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _addTodo();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: themeProvider.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    final result = await showModalBottomSheet<Note>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ModernNoteBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _notes.insert(0, result);
      });
    }
  }

  Future<void> _addTodo() async {
    final result = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ModernTodoBottomSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _todos.insert(0, result);
      });
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await showModalBottomSheet<Note>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModernNoteBottomSheet(
        note: note,
        onNoteUpdated: (updatedNote) {
          setState(() {
            final index = _notes.indexWhere((n) => n.id == note.id);
            if (index != -1) {
              _notes[index] = updatedNote;
            }
          });
        },
      ),
    );

    if (result != null && mounted) {
      await NoteStorage.instance.update(result);
      setState(() {
        final index = _notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _notes[index] = result;
        }
      });
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ModernTodoBottomSheet(todo: todo),
    );

    if (result != null && mounted) {
      await TodoStorage.instance.update(result);
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = result;
        }
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text("Delete Note"),
          ],
        ),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await NoteStorage.instance.delete(noteId);
              setState(() {
                _notes.removeWhere((note) => note.id == noteId);
              });
              if (!mounted) return;
              navigator.pop();
              ToastService.showError(message: 'Note deleted');
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewNote(Note note) {
    showNoteDetailSheet(
      context,
      note,
      onEdit: () => _editNote(note),
      onDelete: () => _deleteNote(note.id),
    );
  }

  Future<void> _deleteTodo(String todoId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete To-Do"),
        content: const Text("Are you sure you want to delete this to-do?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final dialogContext = context;
              await TodoStorage.instance.delete(todoId);
              setState(() {
                _todos.removeWhere((todo) => todo.id == todoId);
              });
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(dialogContext);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(
                  content: Text("To-Do deleted"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<dynamic> get _filteredItems {
    List<dynamic> items = [];

    if (_selectedType == 'all' || _selectedType == 'notes') {
      items.addAll(_notes);
    }
    if (_selectedType == 'all' || _selectedType == 'todos') {
      items.addAll(_todos);
    }

    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      if (item is Note) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.content.toLowerCase().contains(_searchQuery.toLowerCase());
      } else if (item is Todo) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return false;
    }).toList();
  }

  int get _totalCount {
    if (_selectedType == 'notes') return _notes.length;
    if (_selectedType == 'todos') return _todos.length;
    return _notes.length + _todos.length;
  }

  void _viewTodo(Todo todo) {
    showTodoDetailSheet(
      context,
      todo,
      onEdit: () => _editTodo(todo),
      onDelete: () => _deleteTodo(todo.id),
      onToggleItem: () => _toggleTodoDone(todo),
    );
  }

  Future<void> _toggleTodoDone(Todo todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await TodoStorage.instance.update(updatedTodo);
    setState(() {
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.appBarColor,
        title: Text(
          "Smart Notes",
          style: TextStyle(
            color: themeProvider.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search notes, to-dos...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.subtitleColor,
                    ),
                    filled: true,
                    fillColor: themeProvider.searchFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    _buildTypeFilter('All', 'all'),
                    const SizedBox(width: 8),
                    _buildTypeFilter('Notes', 'notes'),
                    const SizedBox(width: 8),
                    _buildTypeFilter('To-Dos', 'todos'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getEmptyIcon(),
                    size: 80,
                    color: themeProvider.subtitleColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No results found'
                        : _getEmptyTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      color: themeProvider.subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : _getEmptySubtitle(),
                    style: TextStyle(
                      color: themeProvider.subtitleColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (_searchQuery.isNotEmpty) ...[
                    Text(
                      'Results ($_totalCount)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Text(
                      'Recent ($_totalCount)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: _filteredItems.isEmpty && _searchQuery.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: themeProvider.subtitleColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: themeProvider.subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              if (item is Note) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NoteCard(
                                    note: item,
                                    onView: () => _viewNote(item),
                                    onEdit: () => _editNote(item),
                                    onDelete: () => _deleteNote(item.id),
                                  ),
                                );
                              } else if (item is Todo) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TodoCard(
                                    todo: item,
                                    onView: () => _viewTodo(item),
                                    onEdit: () => _editTodo(item),
                                    onDelete: () => _deleteTodo(item.id),
                                    onToggleDone: () => _toggleTodoDone(item),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeProvider.accentColor,
        elevation: 4,
        onPressed: _showAddOptions,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTypeFilter(String label, String type) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? themeProvider.accentColor
              : themeProvider.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? themeProvider.accentColor
                : themeProvider.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : themeProvider.textColor,
          ),
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    if (_selectedType == 'todos') return Icons.check_circle_outline;
    if (_selectedType == 'notes') return Icons.note_alt_outlined;
    return Icons.lightbulb_outline;
  }

  String _getEmptyTitle() {
    if (_selectedType == 'todos') return 'No to-dos yet';
    if (_selectedType == 'notes') return 'No notes yet';
    return 'Nothing yet';
  }

  String _getEmptySubtitle() {
    if (_selectedType == 'todos') return 'Tap + to create your first to-do';
    if (_selectedType == 'notes') return 'Tap + to create your first note';
    return 'Tap + to create your first item';
  }
}
