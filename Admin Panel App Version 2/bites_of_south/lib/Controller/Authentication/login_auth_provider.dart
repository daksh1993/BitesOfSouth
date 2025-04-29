// login_auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

class LoginAuthProvider with ChangeNotifier {
  // Changed from AuthProvider
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<bool> checkIfAlreadyLoggedIn() async {
    print('Checking if user is already logged in');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool("loggedin") ?? false;
    print('Login status from SharedPreferences: $loggedIn');
    return loggedIn;
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    print('Starting password reset for email: $email');
    if (!EmailValidator.validate(email)) {
      print('Invalid email format');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email")),
      );
      return;
    }

    try {
      print('Sending password reset email');
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to $email")),
      );
    } catch (e) {
      print('Error in resetPassword: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
    required Function(String, String, User) onPhoneVerification,
  }) async {
    print('Starting login process for email: $email');
    isLoading = true;
    notifyListeners();

    if (!EmailValidator.validate(email)) {
      print('Invalid email format');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email")),
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      print('Attempting Firebase authentication');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Fetching user role from Firestore');
      QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userCredential.user!.email)
          .get();

      if (adminQuery.docs.isNotEmpty && adminQuery.docs.first['role'] != null) {
        print('User is authorized, preparing phone verification');
        String docId = adminQuery.docs.first.id;
        String maskedPhone = adminQuery.docs.first['phone']
            .substring(adminQuery.docs.first['phone'].length - 4);

        onPhoneVerification(docId, maskedPhone, userCredential.user!);
      } else {
        print('Unauthorized access detected');
        await _auth.signOut();
        throw "Unauthorized access: Only admins can log in";
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException occurred: ${e.code}');
      String errorMessage = "Authentication failed";

      switch (e.code) {
        case 'user-not-found':
          errorMessage = "Invalid email";
          break;
        case 'wrong-password':
          errorMessage = "Invalid password";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid email or password";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Try again later.";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }

      print('Showing error message: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      print('Unexpected error in login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      print('Login process completed');
      isLoading = false;
      notifyListeners();
    }
  }
}
