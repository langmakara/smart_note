import 'package:flutter/material.dart';

class ToastService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showWarning({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackBar(
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showBackupProgress({
    required String message,
    required double progress,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              value: progress,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );

    scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  static void showBackupComplete() {
    _showSnackBar(
      message: 'Backup completed successfully!',
      backgroundColor: Colors.green,
      icon: Icons.cloud_done,
    );
  }

  static void showSyncComplete() {
    _showSnackBar(
      message: 'Sync completed!',
      backgroundColor: Colors.green,
      icon: Icons.sync,
    );
  }

  static void _showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    );

    scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  static void hideCurrentSnackBar() {
    scaffoldKey.currentState?.hideCurrentSnackBar();
  }
}
