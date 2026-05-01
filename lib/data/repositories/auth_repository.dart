import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<void> signIn();
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(id: user.uid);
    });
  }

  @override
  Future<void> signIn() async {
    await _auth.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
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
    _current = const AppUser(id: 'mock-user');
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(_current);
  }
}
