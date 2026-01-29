import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/note_card.dart';
import '../../../models/note_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/note_storage.dart';
import 'note_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    
    try {
      final notes = await NoteStorage.instance.readAllNotes();
      if (!mounted) return;
      setState(() {
        _notes.clear();
        _notes.addAll(notes);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          onSave: (title, content, color) {
            final newNote = Note(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              content: content,
              createdAt: DateTime.now(),
              color: color,
            );
            return newNote;
          },
        ),
      ),
    );

    if (result != null && mounted) {
      await NoteStorage.instance.create(result);
      setState(() {
        _notes.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note created!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditPage(
          note: note,
          onSave: (title, content, color) {
            final updatedNote = note.copyWith(
              title: title,
              content: content,
              color: color,
              updatedAt: DateTime.now(),
            );
            return updatedNote;
          },
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteNote(String noteId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await NoteStorage.instance.delete(noteId);
              setState(() {
                _notes.removeWhere((note) => note.id == noteId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Note deleted"),
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

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
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
        actions: [
          IconButton(
            icon: Icon(
              _searchQuery.isNotEmpty ? Icons.close : Icons.search,
              color: themeProvider.subtitleColor,
            ),
            onPressed: () {
              if (_searchQuery.isNotEmpty) {
                setState(() => _searchQuery = '');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search, color: themeProvider.subtitleColor),
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
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 80,
                        color: themeProvider.subtitleColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No notes found'
                            : 'No notes yet',
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
                            : 'Tap + to create your first note',
                        style: TextStyle(color: themeProvider.subtitleColor.withOpacity(0.7)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Search Results (${_filteredNotes.length})'
                                : 'Recent Notes (${_filteredNotes.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                            if (_searchQuery.isEmpty)
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "View All",
                                  style: TextStyle(
                                    color: themeProvider.accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];
                            return NoteCard(
                              note: note,
                              onTap: () => _editNote(note),
                              onDelete: () => _deleteNote(note.id),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeProvider.accentColor,
        elevation: 4,
        onPressed: _addNote,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
