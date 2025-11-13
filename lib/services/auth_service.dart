import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  // Sign in method
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners(); // <-- tells all listening widgets to rebuild
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    notifyListeners();
  }
}