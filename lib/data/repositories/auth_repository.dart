import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signIn();
  Future<void> signInAnonymously();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      final providerId = user.providerData.isNotEmpty ? user.providerData.first.providerId : '';
      return AppUser(
        id: user.uid,
        isAnonymous: user.isAnonymous,
        providerId: providerId,
      );
    });
  }

  @override
  Future<void> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn().timeout(const Duration(seconds: 12));
      if (googleUser == null) {
        await signInAnonymously();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (_) {
      await signInAnonymously();
    }
  }

  @override
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    _controller.add(_current);
  }

  AppUser? _current;
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> signIn() async {
    _current = const AppUser(id: 'mock-user', isAnonymous: true, providerId: '');
    _controller.add(_current);
  }

  @override
  Future<void> signInAnonymously() async {
    _current = const AppUser(id: 'mock-user', isAnonymous: true, providerId: '');
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(_current);
  }
}
