import 'dart:async';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<void> signIn() async {
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  String? getUserEmail() => null;
  String? getUserDisplayName() => null;
  String? getUserPhotoUrl() => null;
}
