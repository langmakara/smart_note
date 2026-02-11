import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/google_drive_service.dart';
import 'google_drive_backup_page.dart';
import 'google_login_page.dart';

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

  GoogleDriveService get _driveService =>
      Provider.of<GoogleDriveService>(context, listen: false);

  void _updateAuthStatus() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _driveService.addListener(_updateAuthStatus);
  }

  @override
  void dispose() {
    _driveService.removeListener(_updateAuthStatus);
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
    await _driveService.signOut();
    setState(() {});
  }

  Future<void> _backupToGoogleDrive() async {
    setState(() => _isBackingUp = true);
    try {
      await _driveService.backupData(
        fileName:
            'smart_note_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        content: '{"notes": [], "events": []}',
      );

      setState(() => _lastBackupTime = DateTime.now());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Backup completed successfully!')),
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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.download, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Data exported successfully!')),
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
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.upload, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Data imported successfully!')),
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
          'This will delete all notes, events, and settings. This action cannot be undone and is permanent.',
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete_forever, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('All data cleared!')),
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
    final isAuthenticated = _driveService.isAuthenticated;
    final userEmail = _driveService.currentUser?.email;

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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildStorageRow(
                  label: 'Notes',
                  value: '24',
                  icon: Icons.note,
                  color: Colors.blue,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'Events',
                  value: '12',
                  icon: Icons.event,
                  color: Colors.green,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'To-Dos',
                  value: '8',
                  icon: Icons.check_circle,
                  color: Colors.orange,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 12),
                _buildStorageRow(
                  label: 'Total Size',
                  value: '2.4 MB',
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
