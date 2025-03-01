import 'package:bites_of_south/View/Authentication/phoneScreen.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (isLoading) {}

    try {
      print("Attempting to log in with email: $email");

      // Step 1: Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: password,
        ),
      );

      // Step 2: Fetch admin details from Firestore
      QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userCredential.user!.email)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        DocumentSnapshot adminDoc = adminQuery.docs.first;

        if (adminDoc['role'] == 'admin') {
          var maskedphone =
              adminDoc['phone'].substring(adminDoc['phone'].length - 4);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerification(
                user: userCredential.user,
                maskedPhoneNumber: maskedphone,
              ),
            ),
          );
        } else {
          throw "Unauthorized access";
        }
      } else {
        throw "User record not found in Firestore";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging in: $e"),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Image(
                image: AssetImage("assets/round_logo.png"),
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).height / 24,
              ),
              backgroundColor: Colors.white,
            )
          : AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Image(
                image: AssetImage("assets/round_logo.png"),
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).height / 24,
              ),
              backgroundColor: Colors.green,
            ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child:
                  Lottie.asset("assets/loadin.json", width: 150, height: 150),
            )
          : SingleChildScrollView(
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
                    padding: EdgeInsets.only(
                        top: MediaQuery.sizeOf(context).height / 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Access your dashboard seamlessly\nManage, Monitor, Optimize.",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.sizeOf(context).height / 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, left: 20, right: 20),
                              child: Form(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Colors.grey,
                                        ),
                                        labelText: "Email",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.grey,
                                          ),
                                          labelText: "Password",
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          errorMaxLines: 4,
                                          errorStyle: TextStyle(height: 1.5)),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          minimumSize:
                                              Size(double.infinity, 50),
                                        ),
                                        onPressed: _login,
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text("Forgot Password?",
                                            style:
                                                TextStyle(color: Colors.blue)),
                                      ),
                                    ),
                                    if (isLoading)
                                      Center(
                                        child: Lottie.asset(
                                          'assets/loadin.json',
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                  ],
                                ),
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
