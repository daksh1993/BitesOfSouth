import 'package:bites_of_south/View/Authentication/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String name = "Admin Test";
String email = "admintest@gmail.com";
String phone = "+91 1234567890";
String role = "admintest";
String lastLoginAt = "Not available";
String lastLogoutAt = "Not available";

Future<void> FetchProfile() async {
  SharedPreferences pref = await SharedPreferences.getInstance();

  String? userid = pref.getString("docId");
  if (userid != null) {
    DocumentSnapshot userProfile =
        await FirebaseFirestore.instance.collection('users').doc(userid).get();

    if (userProfile.exists) {
      name = userProfile['name'];
      email = userProfile['email'];
      phone = userProfile['phone'];
      role = userProfile['role'];
      lastLoginAt =
          (userProfile['lastLoginAt'] as Timestamp).toDate().toString();
      lastLogoutAt =
          (userProfile['lastLogoutAt'] as Timestamp).toDate().toString();
    } else {
      print("User profile does not exist");
    }
  } else {
    print("User not logged in");
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    FetchProfile();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade700,
              Colors.green.shade200,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(
                    //     Icons.edit,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildInfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                      ),
                      const SizedBox(height: 25),
                      _buildInfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone,
                      ),
                      const SizedBox(height: 25),
                      _buildInfoItem(
                        icon: Icons.access_time,
                        label: 'Last Login',
                        value: lastLoginAt,
                      ),
                      const SizedBox(height: 25),
                      _buildInfoItem(
                        icon: Icons.logout,
                        label: 'Last Logout',
                        value: lastLogoutAt,
                      ),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((_) async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              String? userid = pref.getString("docId");
                              if (userid != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userid)
                                    .update({
                                  'lastLogoutAt': FieldValue.serverTimestamp(),
                                });
                                pref.setString("docId", "");
                                pref.setBool("loggedin", false);
                              }

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 18),
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
