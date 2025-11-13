// lib/services/firebase_auth_methods.dart
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User, UserCredential, FirebaseAuthException;
import 'package:flutter/material.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== SIGN UP METHOD =====
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Verification email sent! Please check your inbox before logging in.",
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already registered.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'weak-password':
          errorMessage = "Password should be at least 6 characters.";
          break;
        default:
          errorMessage = "An error occurred: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle any other unexpected error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  // ===== SIGN IN METHOD =====
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email not verified! A new verification link has been sent.",
            ),
          ),
        );
        await _auth.signOut(); // Prevents going to Home
      } else {
        // Email verified ✅ → Navigate to Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No account found for this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        default:
          errorMessage = "An error occurred: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  // ===== SIGN OUT =====
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed out successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: $e")),
      );
    }
  }




}