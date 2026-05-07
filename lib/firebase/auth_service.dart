import 'package:firebase_auth/firebase_auth.dart';

import 'package:en_passant/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      return user == null ? null : UserModel.fromFirebaseUser(user);
    });
  }

  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthServiceException('Could not create your account.');
      }

      final cleanName = displayName?.trim();
      if (cleanName != null && cleanName.isNotEmpty) {
        await user.updateDisplayName(cleanName);
        await user.reload();
      }

      return UserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForAuthCode(error.code));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw AuthServiceException('Something went wrong. Please try again.');
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthServiceException('Could not sign you in.');
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForAuthCode(error.code));
    } on AuthServiceException {
      rethrow;
    } catch (_) {
      throw AuthServiceException('Something went wrong. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_messageForAuthCode(error.code));
    } catch (_) {
      throw AuthServiceException('Could not send the reset email.');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _messageForAuthCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already connected to an account.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled for this Firebase project.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthServiceException implements Exception {
  final String message;

  const AuthServiceException(this.message);

  @override
  String toString() => message;
}
