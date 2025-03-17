import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class AddAdminScreen extends StatefulWidget {
  @override
  _AddAdminScreenState createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool isLoading = false;

  String _generateRandomPassword(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        length, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> _sendEmail(
      String email, String name, String phone, String password) async {
    final smtpServer = gmail('bitesofsouth@gmail.com', 'jigehxuyppxpkzjo');
    final message = Message()
      ..from = Address('bitesofsouth@gmail.com', 'BitesOfSouth')
      ..recipients.add(email)
      ..subject = 'Your Admin Account Credentials'
      ..text = '''
Dear $name,

This mail is sent to you by BitesOfSouth. Below are your admin account details:

Email: $email
Temporary Password: $password
Phone number: $phone

Please change this password as soon as possible by clicking on 'Forgot Password' on the login screen.

Steps to reset password:
1. Open the app and go to the login screen.
2. Click on 'Forgot Password' below the password field.
3. You will receive a verification link on your registered email.
4. Follow the link to reset your password and set a new one.

Best Regards,
BitesOfSouth Team''';

    try {
      await send(message, smtpServer);
      print(message.text);
      print("mail Sent");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Email sent to $email, Please check Spam folder also")),
      );
    } catch (e) {
      print('Failed to send email: $e');
    }
  }

  void _confirmAdminDetails() {
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String role = _roleController.text.trim();

    if (!EmailValidator.validate(email) ||
        phone.isEmpty ||
        name.isEmpty ||
        role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields correctly")));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Admin Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $name"),
              Text("Email: $email"),
              Text("Phone: +91$phone"),
              Text("Role: $role"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addAdmin();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _addAdmin() async {
    setState(() => isLoading = true);
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String role = _roleController.text.trim();
    String password = _generateRandomPassword(8);

    if (!EmailValidator.validate(email) ||
        phone.isEmpty ||
        name.isEmpty ||
        role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly")),
      );
      setState(() => isLoading = false);
      return;
    }
    print(password);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phone': "+91" + phone,
        'role': role,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneVerified': false,
        'otpEnabled': true,
        'isAuthenticated': false,
      });

      await _sendEmail(email, name, phone, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding admin: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Admin")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefix: Text("+91 "),
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _confirmAdminDetails,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Add Admin"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
