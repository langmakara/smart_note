import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  GoogleSignInAccount? get currentUser => _currentUser;

  void initialize({required String webClientId, required String iosClientId}) {
    if (_isInitialized) return;

    _googleSignIn = GoogleSignIn(
      scopes: [drive.DriveApi.driveAppdataScope, 'email', 'profile'],
      clientId: webClientId,
    );

    _googleSignIn!.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      _isAuthenticated = account != null;
      notifyListeners();
    });

    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _googleSignIn = GoogleSignIn(
        scopes: [drive.DriveApi.driveAppdataScope, 'email', 'profile'],
      );
      _googleSignIn!.onCurrentUserChanged.listen((
        GoogleSignInAccount? account,
      ) {
        _currentUser = account;
        _isAuthenticated = account != null;
        notifyListeners();
      });
      _isInitialized = true;
    }
  }

  Future<void> signIn() async {
    await _ensureInitialized();

    try {
      if (_googleSignIn == null) {
        throw Exception('GoogleSignIn not initialized');
      }

      final user = await _googleSignIn!.signIn();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error signing in: $error');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<drive.DriveApi?> getDriveApi() async {
    if (!_isAuthenticated || _currentUser == null || _googleSignIn == null) {
      return null;
    }

    try {
      final authClient = await _googleSignIn!.authenticatedClient();
      if (authClient == null) {
        debugPrint('Failed to get authenticated client');
        return null;
      }
      return drive.DriveApi(authClient);
    } catch (error) {
      debugPrint('Error getting Drive API: $error');
      return null;
    }
  }

  Future<String?> backupData({
    required String fileName,
    required String content,
  }) async {
    final driveApi = await getDriveApi();
    if (driveApi == null) {
      throw Exception('Not authenticated');
    }

    try {
      final media = drive.Media(
        Stream.value(List<int>.from(content.codeUnits)),
        content.length,
      );

      final drive.File file = drive.File()
        ..name = fileName
        ..mimeType = 'application/json'
        ..parents = ['appDataFolder'];

      final response = await driveApi.files.create(file, uploadMedia: media);
      return response.id;
    } catch (error) {
      debugPrint('Error backing up data: $error');
      rethrow;
    }
  }

  Future<drive.FileList?> listBackupFiles() async {
    final driveApi = await getDriveApi();
    if (driveApi == null) {
      return null;
    }

    try {
      return await driveApi.files.list(
        q: "name contains 'smart_note_backup'",
        spaces: 'appDataFolder',
      );
    } catch (error) {
      debugPrint('Error listing files: $error');
      return null;
    }
  }

  Future<String?> downloadData(String fileId) async {
    final driveApi = await getDriveApi();
    if (driveApi == null) {
      return null;
    }

    try {
      final response = await driveApi.files.get(fileId) as drive.Media;
      return response.stream.toString();
    } catch (error) {
      debugPrint('Error downloading data: $error');
      return null;
    }
  }

  Future<bool> deleteBackupFile(String fileId) async {
    final driveApi = await getDriveApi();
    if (driveApi == null) {
      return false;
    }

    try {
      await driveApi.files.delete(fileId);
      return true;
    } catch (error) {
      debugPrint('Error deleting file: $error');
      return false;
    }
  }
}
