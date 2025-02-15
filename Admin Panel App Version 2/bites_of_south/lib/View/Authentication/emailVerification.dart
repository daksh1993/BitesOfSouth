import 'package:bites_of_south/View/Dashboard.dart';
import 'package:flutter/material.dart';

class SendEmailConfirmation extends StatefulWidget {
  const SendEmailConfirmation({super.key});

  @override
  State<SendEmailConfirmation> createState() => _SendEmailConfirmationState();
}

class _SendEmailConfirmationState extends State<SendEmailConfirmation> {
  bool isEmailSent = false;

  void _sendVerificationEmail() {
    setState(() {
      isEmailSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent a email for verification'),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isEmailSent = false;
      });

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => DashboardScreen(),
      ));
    });
  }

  void _resendEmail() {
    // Resend email logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            Text("Email Verification", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Verify Your Email",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 10),
              Text(
                "A verification link has been sent to your email address. Please check your inbox and click on the link to verify your email.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmailSent ? Colors.grey : Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: isEmailSent ? null : _sendVerificationEmail,
                child: Text(
                  "Send Verification Email",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: isEmailSent ? _resendEmail : null,
                child: Text(
                  "Resend Email",
                  style:
                      TextStyle(color: isEmailSent ? Colors.blue : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
