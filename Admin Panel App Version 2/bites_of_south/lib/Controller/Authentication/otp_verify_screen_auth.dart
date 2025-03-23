// otp_verify_screen_auth.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerifyScreenAuth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String? _verificationId;
  String? phoneNumber;

  // Fetch phone number and send OTP
  Future<void> getPhoneAndSendOTP({
    required String docId,
    required BuildContext context,
  }) async {
    print('Starting getPhoneAndSendOTP');
    isLoading = true;
    notifyListeners();

    try {
      print('Fetching user document with docId: $docId');
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(docId).get();
      phoneNumber = doc['phone'];
      print('Phone number fetched: $phoneNumber');

      print('Sending OTP to $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto-verification completed');
          await _handleCredential(credential, docId, context);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone Verification Failed: ${e.message}")),
          );
          isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent successfully, verificationId: $verificationId');
          _verificationId = verificationId;
          isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto-retrieval timeout, verificationId: $verificationId');
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print('Error fetching phone number: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching phone number: $e")),
      );
      isLoading = false;
      notifyListeners();
    }
  }

  // Verify entered OTP
  Future<void> verifyOTP({
    required String otp,
    required String docId,
    required BuildContext context,
  }) async {
    print('Starting OTP verification with code: $otp');
    isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _handleCredential(credential, docId, context);
    } catch (e) {
      print('OTP Verification Failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verification Failed: $e")),
      );
      isLoading = false;
      notifyListeners();
    }
  }

  // Handle the authentication credential
  Future<void> _handleCredential(
    PhoneAuthCredential credential,
    String docId,
    BuildContext context,
  ) async {
    print('Handling credential');
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (currentUser.phoneNumber != null) {
          if (currentUser.phoneNumber == phoneNumber) {
            print('Phone number matches, signing in');
            await _auth.signInWithCredential(credential);
            await _completeVerification(docId, context);
          } else {
            print('Different phone number detected');
            throw FirebaseAuthException(
              code: 'provider-already-linked',
              message:
                  'A different phone number is already linked to this account.',
            );
          }
        } else {
          print('Linking new phone number');
          await currentUser.linkWithCredential(credential);
          await _completeVerification(docId, context);
        }
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      String errorMessage =
          e is FirebaseAuthException && e.code == 'provider-already-linked'
              ? "A different phone number is already linked to this account."
              : "Failed to verify phone number: $e";
      print('Error in handleCredential: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      isLoading = false;
      notifyListeners();
    }
  }

  // Complete the verification process
  Future<void> _completeVerification(String docId, BuildContext context) async {
    print('Completing verification');
    try {
      await _firestore.collection('users').doc(docId).update({
        'phoneVerified': true,
        'isAuthenticated': true,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('docId', docId);
      await prefs.setBool("loggedin", true);
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(docId).get();
      String role = (userDoc.data() as Map<String, dynamic>)['role'] as String;
      print('Role: $role');
      if (role == 'admin') {
        await prefs.setBool("isAdmin", true);
      } else {
        await prefs.setBool("isAdmin", false);
      }

      print('Verification completed successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number verified successfully")),
      );
      bool isAdmin = prefs.getBool('isAdmin') ?? false;
      print('isAdmin: $isAdmin');
      if (isAdmin) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.popAndPushNamed(context, '/cookpage');
      }
    } catch (e) {
      print('Error completing verification: $e');
      throw e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
