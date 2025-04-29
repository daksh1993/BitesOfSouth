import 'package:bites_of_south/Controller/Authentication/login_auth_provider.dart';
import 'package:bites_of_south/View/Authentication/phoneScreen.dart';
import 'package:bites_of_south/View/Dashboard.dart';
import 'package:bites_of_south/View/Orders/orderspanel.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void _checkInitialLoginStatus() async {
    final authProvider = Provider.of<LoginAuthProvider>(context,
        listen: false); // Updated provider name
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAdmin = prefs.getBool('isAdmin') ?? false;
    if (await authProvider.checkIfAlreadyLoggedIn()) {
      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        prefs.setString("docId", "RWK4WxjFx3ojXoDCDnBB");
        print("docId: ${prefs.getString("docId")}");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CookOrderScreen()),
        );
      }
    }
  }

  void _resetPassword() {
    final authProvider = Provider.of<LoginAuthProvider>(context,
        listen: false); // Updated provider name
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
              await authProvider.resetPassword(
                emailController.text.trim(),
                context,
              );
              Navigator.pop(context);
            },
            child: Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkInitialLoginStatus();
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkInitialLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkInitialLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginAuthProvider>(
      // Updated provider name
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: authProvider.isLoading
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
                    fit: BoxFit.cover,
                    height: MediaQuery.sizeOf(context).height / 24,
                  ),
                  backgroundColor: Colors.green,
                ),
          body: authProvider.isLoading
              ? Center(
                  child: Container(
                    height: MediaQuery.sizeOf(context).height / 7,
                    child: Lottie.asset("assets/loadin.json"),
                  ),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Access your dashboard seamlessly\nManage, Monitor, Optimize.",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.sizeOf(context).height / 15),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 20, right: 20),
                                  child: Form(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                      BorderRadius.circular(
                                                          10)),
                                              errorMaxLines: 4,
                                              errorStyle:
                                                  TextStyle(height: 1.5)),
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
                                            onPressed: () {
                                              authProvider.login(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                                context: context,
                                                onPhoneVerification: (docId,
                                                    maskedPhone, user) async {
                                                
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PhoneNumberVerificationScreen(
                                                        user: user,
                                                        docId: docId,
                                                        maskedPhoneNumber:
                                                            maskedPhone,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
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
                                                style: TextStyle(
                                                    color: Colors.blue)),
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
      },
    );
  }
}
