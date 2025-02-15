import 'package:bites_of_south/View/Authentication/phoneScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _verifyEmail() {
    if (_formKey.currentState!.validate()) {
      // Add your email and password verification logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifying...')),
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
            // Curved Background using Container
            Container(
              height: MediaQuery.sizeOf(context).height /
                  3, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18), // Curved bottom left
                  bottomRight: Radius.circular(18), // Curved bottom right
                ),
              ),
            ),

            // Content
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  // Space for the logo

                  // Logo
                  // Center(
                  //   child: CircleAvatar(
                  //     radius: 50,
                  //     backgroundImage: Image.asset("assets/round_logo.png").image,
                  //     // AssetImage('round_logo.png'), // Replace with your logo
                  //   ),
                  // ),

                  // const SizedBox(height: 10),

                  // // App Name
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
                  SizedBox(height: MediaQuery.sizeOf(context).height / 15),

                  // Registration Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   height: 15,
                            // ),
                            // // Title
                            // Text(
                            //   "Register New Device",
                            //   style: TextStyle(
                            //       fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green),

                            // ),
                            const SizedBox(height: 12),

                            // Email Field
                            TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                ),
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Password Field
                            TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: Size(double.infinity,
                                      50), // Adjust height as needed
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PhoneVerification()),
                                  );
                                },
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text("Forgot Password?",
                                    style: TextStyle(color: Colors.blue)),
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
