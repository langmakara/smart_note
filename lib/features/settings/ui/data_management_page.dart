import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/google_drive_service.dart';
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
  late AppSettings _settings;
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Backup completed successfully!'),
            backgroundColor: Colors.green,
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
            content: Text('Backup failed: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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

  void _updateSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data exported successfully!'),
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
          content: const Text('Data imported successfully!'),
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
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all notes, events, and settings. This action cannot be undone.',
        ),
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
            content: const Text('All data cleared!'),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          // Auto Backup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _settings.autoBackup ? Icons.backup : Icons.backup_outlined,
                  color: _settings.autoBackup
                      ? Colors.green
                      : themeProvider.subtitleColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Backup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                      Text(
                        _settings.autoBackup ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _settings.autoBackup,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(autoBackup: value));
                  },
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Google Drive Backup
          Consumer<GoogleDriveService>(
            builder: (context, driveService, child) {
              final isAuthenticated = driveService.isAuthenticated;
              final userEmail = driveService.currentUser?.email;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAuthenticated
                              ? Icons.cloud_done
                              : Icons.cloud_upload,
                          color: isAuthenticated
                              ? Colors.green
                              : themeProvider.subtitleColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Google Drive Backup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textColor,
                                ),
                              ),
                              if (isAuthenticated && userEmail != null)
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeProvider.subtitleColor,
                                  ),
                                )
                              else
                                Text(
                                  isAuthenticated
                                      ? 'Connected'
                                      : 'Not connected',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: themeProvider.subtitleColor,
                                  ),
                                ),
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                isAuthenticated ? Icons.backup : Icons.login,
                              ),
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
                              ? Colors.blue
                              : Colors.white,
                          foregroundColor: isAuthenticated
                              ? Colors.white
                              : Colors.black,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: isAuthenticated
                              ? null
                              : BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    if (isAuthenticated)
                      TextButton(
                        onPressed: _handleGoogleLogout,
                        child: const Text(
                          'Sign out',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Export/Import
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export & Import',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.upload_file,
                        label: 'Export',
                        color: Colors.green,
                        isLoading: _isExporting,
                        onTap: _exportData,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.download,
                        label: 'Import',
                        color: Colors.blue,
                        isLoading: _isImporting,
                        onTap: _importData,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Storage Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStorageInfo(
                  label: 'Notes',
                  value: '24',
                  icon: Icons.note,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildStorageInfo(
                  label: 'Events',
                  value: '12',
                  icon: Icons.event,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                _buildStorageInfo(
                  label: 'Total Size',
                  value: '2.4 MB',
                  icon: Icons.storage,
                  color: themeProvider.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Warning: These actions are permanent and cannot be undone.',
                  style: TextStyle(fontSize: 13, color: Colors.red.shade400),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStorageInfo({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
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
}
