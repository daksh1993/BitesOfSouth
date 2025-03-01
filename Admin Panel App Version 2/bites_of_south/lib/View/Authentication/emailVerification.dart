import 'dart:async';

import 'package:bites_of_south/View/Dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SendEmailConfirmation extends StatefulWidget {
  final User? user;
  const SendEmailConfirmation({super.key, required this.user});

  @override
  State<SendEmailConfirmation> createState() => _SendEmailConfirmationState();
}

class _SendEmailConfirmationState extends State<SendEmailConfirmation> {
  bool isEmailSent = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    print("User Info: ${widget.user}");
    print("User Email: ${widget.user?.email}");
    // _checkEmailVerified();
    // Listen for authentication state changes
  }

  @override
  void dispose() {
    // _authStateSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  bool _checkEmailVerified() {
    User? user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      print("✅ Email is verified. Navigating to Dashboard...");

      _navigateToDashboard();
      return true;
    } else {
      print("❌ Email is not verified.");
      return false;
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return; // Ensure the widget is still mounted
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No user logged in. Please log in again.")),
        );
        return;
      }

      await currentUser.reload(); // Refresh Firebase state
      await currentUser.sendEmailVerification();

      print("✅ Verification email sent to: ${currentUser.email}");

      setState(() => isEmailSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Verification email sent to ${currentUser.email}. Please check spam folder.")),
      );
      for (int i = 0; i < 1000; i++) {
        var emailveri = false;
        print("Waiting for email verification...");
        Future.delayed(Duration(seconds: 4), () {
          emailveri = _checkEmailVerified();
        });
        if (emailveri == false) {
          break;
        }
      }
    } catch (e) {
      print("❌ Error sending email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send email: ${e.toString()}")),
      );
    }
  }

  Future<void> _resendEmail() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) return;

    try {
      await currentUser.reload();
      await currentUser.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Verification email resent. Please check your inbox.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend email: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image(
          image: AssetImage("assets/round_logo.png"),
          fit: BoxFit.cover,
          height: MediaQuery.sizeOf(context).height / 24,
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height / 3,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Email Verification",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "A verification link has been sent to your email address.\n"
                      "Please check your inbox and click on the link to verify your email.",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height / 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/email.json',
                              height: 250,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isEmailSent ? Colors.grey : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed:
                                  isEmailSent ? null : _sendVerificationEmail,
                              child: Text(
                                "Send Verification Email",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: _resendEmail,
                              child: Text(
                                "Resend Email",
                                style: TextStyle(
                                  color:
                                      isEmailSent ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
