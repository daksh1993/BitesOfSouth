import 'package:bites_of_south/View/Authentication/phoneScreen.dart';
import 'package:bites_of_south/View/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _passwordVisible = false;
  void _CheckIfAlreadyLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("loggedin") == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ),
      );
    } else {
      print("Not Logged In");
    }
  }

  void _resetPassword() async {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reset Password"),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Enter your email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String email = emailController.text.trim();
              if (!EmailValidator.validate(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a valid email")),
                );
                return;
              }
              try {
                await _auth.sendPasswordResetEmail(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password reset link sent to $email")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: Text("Send"),
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() => isLoading = true);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userCredential.user!.email)
          .get();

      if (adminQuery.docs.isNotEmpty && adminQuery.docs.first['role'] != null) {
        String docId = adminQuery.docs.first.id;
        String maskedPhone = adminQuery.docs.first['phone']
            .substring(adminQuery.docs.first['phone'].length - 4);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneNumberVerificationScreen(
              user: userCredential.user!,
              docId: docId,
              maskedPhoneNumber: maskedPhone,
            ),
          ),
        );
      } else {
        await _auth.signOut();
        throw "Unauthorized access: Only admins can log in";
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      String errorMessage = "Authentication failed";

      if (e.code == 'user-not-found') {
        errorMessage = "Invalid email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Invalid password";
      } else if (e.code == 'invalid-credential') {
        errorMessage =
            "Invalid email or password"; // General message for malformed credentials
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many failed attempts. Try again later.";
      } else {
        errorMessage = "Error: ${e.message}";
      }
      print(errorMessage);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _CheckIfAlreadyLoggedIn();
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _CheckIfAlreadyLoggedIn();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _CheckIfAlreadyLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                image: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec"),
                // image: AssetImage("assets/round_logo.png"),
                fit: BoxFit.cover,
                height: MediaQuery.sizeOf(context).height / 24,
              ),
              backgroundColor: Colors.green,
            ),
      body: isLoading
          ? Center(
              child: Container(
                  height: MediaQuery.sizeOf(context).height / 7,
                  child: Lottie.asset("assets/loadin.json")),
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
                                        prefixIcon: Icon(Icons.email,
                                            color: Colors.grey),
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
                                      obscureText:
                                          _passwordVisible ? false : true,
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                          prefixIcon: Icon(Icons.lock,
                                              color: Colors.grey),
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
                                        onPressed: _resetPassword,
                                        child: Text("Forgot Password?",
                                            style:
                                                TextStyle(color: Colors.blue)),
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
