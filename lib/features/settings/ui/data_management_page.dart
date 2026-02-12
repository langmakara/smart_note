import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../models/note_model.dart';
import '../../../models/event_model.dart';
import '../../../models/todo_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/hive_database.dart';
import '../../../services/note_storage.dart';
import '../../../services/event_storage.dart';
import '../../../services/todo_storage.dart';
import 'google_drive_backup_page.dart';
import 'google_login_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class DataManagementPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const DataManagementPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isBackingUp = false;
  DateTime? _lastBackupTime;
  int _notesCount = 0;
  int _eventsCount = 0;
  int _todosCount = 0;
  GoogleDriveService? _driveService;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
    _driveService = Provider.of<GoogleDriveService>(context, listen: false);
    _driveService?.addListener(_updateAuthStatus);
  }

  Future<void> _loadStorageStats() async {
    final notes = await HiveDatabase.instance.getNotesCount();
    final events = await HiveDatabase.instance.getEventsCount();
    final todos = await HiveDatabase.instance.getTodosCount();
    if (mounted) {
      setState(() {
        _notesCount = notes;
        _eventsCount = events;
        _todosCount = todos;
      });
    }
  }

  void _updateAuthStatus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _driveService?.removeListener(_updateAuthStatus);
    super.dispose();
  }

  String get _lastBackupFormatted {
    if (_lastBackupTime == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(_lastBackupTime!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${_lastBackupTime!.day}/${_lastBackupTime!.month}/${_lastBackupTime!.year}';
  }

  Future<void> _handleGoogleLogin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GoogleLoginPage(onLoginSuccess: () => Navigator.pop(context, true)),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _handleGoogleLogout() async {
    await _driveService!.signOut();
    setState(() {});
  }

  Future<void> _backupToGoogleDrive() async {
    setState(() => _isBackingUp = true);
    try {
      final notes = await NoteStorage.instance.readAllNotes();
      final events = await EventStorage.instance.readAllEvents();
      final todos = await TodoStorage.instance.readAllTodos();

      final backupData = {
        'notes': notes.map((note) => note.toJson()).toList(),
        'events': events.map((event) => event.toJson()).toList(),
        'todos': todos.map((todo) => todo.toJson()).toList(),
        'backupDate': DateTime.now().toIso8601String(),
      };

      await _driveService!.backupData(
        fileName:
            'smart_note_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        content: jsonEncode(backupData),
      );

      setState(() => _lastBackupTime = DateTime.now());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Backup completed successfully! (${notes.length} notes, ${events.length} events, ${todos.length} todos)',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Backup failed: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _backupToGoogleDrive,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final notes = await NoteStorage.instance.readAllNotes();
      final events = await EventStorage.instance.readAllEvents();
      final todos = await TodoStorage.instance.readAllTodos();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'notes': notes.map((note) => note.toJson()).toList(),
        'events': events.map((event) => event.toJson()).toList(),
        'todos': todos.map((todo) => todo.toJson()).toList(),
      };

      final jsonString = jsonEncode(exportData);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Data',
        fileName:
            'smart_note_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);

        if (mounted) {
          setState(() => _isExporting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data exported successfully! (${notes.length} notes, ${events.length} events, ${todos.length} todos)',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isExporting = false);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Export failed: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Data',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        final notesData = data['notes'] as List? ?? [];
        final eventsData = data['events'] as List? ?? [];
        final todosData = data['todos'] as List? ?? [];

        for (final noteJson in notesData) {
          await NoteStorage.instance.create(Note.fromJson(noteJson));
        }
        for (final eventJson in eventsData) {
          await EventStorage.instance.create(Event.fromJson(eventJson));
        }
        for (final todoJson in todosData) {
          await TodoStorage.instance.create(Todo.fromJson(todoJson));
        }

        await _loadStorageStats();

        if (mounted) {
          setState(() => _isImporting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data imported successfully! (${notesData.length} notes, ${eventsData.length} events, ${todosData.length} todos)',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isImporting = false);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isImporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Import failed: $error')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 12),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will delete all notes, events, and todos. This action cannot be undone and is permanent.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await HiveDatabase.instance.clearAllData();
        await _loadStorageStats();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('All data cleared successfully!')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to clear data: $error')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.appBarColor,
        elevation: 1,
        title: Text(
          'Data Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.accentColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(themeProvider, 'Backup & Sync'),
          const SizedBox(height: 12),
          _buildGoogleDriveCard(themeProvider),
          const SizedBox(height: 16),
          _buildSectionHeader(themeProvider, 'Data Operations'),
          const SizedBox(height: 12),
          _buildExportImportCard(themeProvider),
          const SizedBox(height: 16),
          _buildSectionHeader(themeProvider, 'Storage'),
          const SizedBox(height: 12),
          _buildStorageInfoCard(themeProvider),
          const SizedBox(height: 24),
          _buildDangerZone(themeProvider),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeProvider themeProvider, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: themeProvider.subtitleColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGoogleDriveCard(ThemeProvider themeProvider) {
    final isAuthenticated = _driveService?.isAuthenticated ?? false;
    final userEmail = _driveService?.currentUser?.email;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isAuthenticated
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAuthenticated ? Icons.cloud_done : Icons.cloud_upload,
                        size: 24,
                        color: isAuthenticated ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Drive',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAuthenticated
                                ? userEmail ?? 'Connected'
                                : 'Not connected',
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.subtitleColor,
                            ),
                          ),
                          if (isAuthenticated) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 14,
                                  color: themeProvider.subtitleColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Last backup: $_lastBackupFormatted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAuthenticated
                        ? (_isBackingUp ? null : _backupToGoogleDrive)
                        : _handleGoogleLogin,
                    icon: _isBackingUp
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(isAuthenticated ? Icons.backup : Icons.login),
                    label: Text(
                      _isBackingUp
                          ? 'Backing up...'
                          : isAuthenticated
                          ? 'Backup Now'
                          : 'Sign in with Google',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAuthenticated
                          ? themeProvider.accentColor
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAuthenticated)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: themeProvider.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoogleDriveBackupPage(),
                          ),
                        );
                      },
                      child: const Text('Manage Backup'),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: themeProvider.dividerColor,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _handleGoogleLogout,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExportImportCard(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.swap_horiz, color: themeProvider.accentColor),
                    const SizedBox(width: 12),
                    Text(
                      'Export & Import',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Transfer your data to other devices',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.download,
                    label: 'Export',
                    color: Colors.green,
                    isLoading: _isExporting,
                    onTap: _exportData,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.upload,
                    label: 'Import',
                    color: Colors.blue,
                    isLoading: _isImporting,
                    onTap: _importData,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Widget _buildStorageInfoCard(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.storage, color: themeProvider.accentColor),
                const SizedBox(width: 12),
                Text(
                  'Storage Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _loadStorageStats,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildStorageRow(
                  label: 'Notes',
                  value: _notesCount.toString(),
                  icon: Icons.note,
                  color: Colors.blue,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'Events',
                  value: _eventsCount.toString(),
                  icon: Icons.event,
                  color: Colors.green,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'To-Dos',
                  value: _todosCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.orange,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'Total Items',
                  value: (_notesCount + _eventsCount + _todosCount).toString(),
                  icon: Icons.cloud,
                  color: themeProvider.accentColor,
                  themeProvider: themeProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeProvider.textColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red[400]),
                const SizedBox(width: 12),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[400],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: These actions are permanent and cannot be undone.',
                  style: TextStyle(fontSize: 13, color: Colors.red[300]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
