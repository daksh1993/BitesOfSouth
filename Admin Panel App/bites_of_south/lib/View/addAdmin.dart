import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lottie/lottie.dart';
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
  String? _selectedRole; // To store dropdown value
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email sent to $email, please check spam folder"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Failed to send email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send email")),
      );
    }
  }

  void _confirmAdminDetails() {
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();

    if (!EmailValidator.validate(email) ||
        phone.isEmpty ||
        name.isEmpty ||
        _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Confirm Details",
              style: TextStyle(color: Colors.green[800])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $name", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Email: $email", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Phone: +91$phone", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Role: $_selectedRole", style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
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
    String password = _generateRandomPassword(8);

    if (!EmailValidator.validate(email) ||
        phone.isEmpty ||
        name.isEmpty ||
        _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields correctly")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phone': "+91" + phone,
        'role': _selectedRole,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneVerified': false,
        'otpEnabled': true,
        'isAuthenticated': false,
      });

      await _sendEmail(email, name, phone, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Admin added successfully"),
          backgroundColor: Colors.green,
        ),
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
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Add New Admin",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  "Create Admin Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    hintText: "Enter name",
                    prefixIcon: Icon(Icons.person, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "Enter email",
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter phone number",
                    prefixIcon: Icon(Icons.phone, color: Colors.green),
                    prefixText: "+91 ",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: "Role",
                    prefixIcon: Icon(Icons.work, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  hint: Text("Select role"),
                  items: ['admin', 'cook'].map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _confirmAdminDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? Lottie.asset(
                          'assets/loadin.json',
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        )
                      : Text(
                          "Add Admin",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
