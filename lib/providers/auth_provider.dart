import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:en_passant/firebase/auth_service.dart';
import 'package:en_passant/firebase/firestore_service.dart';
import 'package:en_passant/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  StreamSubscription<UserModel?>? _authSubscription;
  UserModel? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;

  AuthProvider({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _authSubscription = _authService.authStateChanges().listen(
      _completeInitialization,
      onError: (_) {
        _completeInitialization(_safeCurrentUser());
      },
    );
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!_isInitializing) return;
      _completeInitialization(_safeCurrentUser());
    });
  }

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _completeInitialization(UserModel? user) {
    if (_isDisposed) return;
    _user = user;
    _isInitializing = false;
    notifyListeners();
  }

  UserModel? _safeCurrentUser() {
    try {
      return _authService.currentUser;
    } on Object {
      return null;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return _runAuthAction(() async {
      final createdUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _saveProfileSafely(createdUser);
      _user = createdUser;
    });
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      final signedInUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      await _saveProfileSafely(signedInUser);
      _user = signedInUser;
    });
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on AuthServiceException catch (error) {
      _errorMessage = error.message;
      return false;
    } on Object {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _errorMessage = null;
    } on Object {
      _errorMessage = 'Could not sign out. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _errorMessage = null;
    _setLoading(true);
    try {
      await action();
      return true;
    } on AuthServiceException catch (error) {
      _errorMessage = error.message;
      return false;
    } on Object {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveProfileSafely(UserModel user) async {
    try {
      await _firestoreService.createOrUpdateUser(user);
    } on Object {
      // Auth remains the source of truth; profile sync can recover later.
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}
