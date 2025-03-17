// import 'package:bites_of_south/View/Authentication/phoneScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class EmailVerificationScreen extends StatefulWidget {
//   const EmailVerificationScreen({ super.key});

//   @override
//   State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
// }

// class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _sendVerificationEmail();
//   }

//   void _sendVerificationEmail() async {
//     try {
//       await widget.user.sendEmailVerification();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Verification email sent")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to send verification email: $e")),
//       );
//     }
//   }

//   void _checkEmailVerification() async {
//     setState(() => isLoading = true);

//     // Reload user to update Firebase Auth state
//     User updatedUser = _auth.currentUser!;

//     // Check Firestore status
//     DocumentSnapshot doc = await _firestore.collection('users').doc(widget.docId).get();
//     bool emailVerifiedInFirestore = doc['emailVerified'];

//     // if (updatedUser.emailVerified && emailVerifiedInFirestore) {
//     //   // Both are true, proceed
//     //   Navigator.pushReplacement(
//     //     context,
//     //     MaterialPageRoute(
//     //       builder: (context) => PhoneVerificationScreen(
//     //         user: updatedUser,
//     //         docId: widget.docId,
//     //       ),
//     //     ),
//     //   );
//     // } else if (updatedUser.emailVerified && !emailVerifiedInFirestore) {
//     //   // Firebase Auth is verified, update Firestore and proceed
//     //   await _firestore.collection('users').doc(widget.docId).update({
//     //     'emailVerified': true,
//     //   });
//     //   Navigator.pushReplacement(
//     //     context,
//     //     MaterialPageRoute(
//     //       builder: (context) => PhoneVerificationScreen(
//     //         user: updatedUser,
//     //         docId: widget.docId,
//     //       ),
//     //     ),
//     //   );
//     // } else {
//     //   // Email not verified in Firebase Auth
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(content: Text("Please verify your email first")),
//     //   );
//     //   setState(() => isLoading = false);
//     // }


//     if(emailVerifiedInFirestore){
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PhoneVerificationScreen(
//             user: updatedUser,
//             docId: widget.docId,
//           ),
//         ),
//       );
//     } else if(!emailVerifiedInFirestore){
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please verify your email first")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Email")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "A verification email has been sent to\n${widget.user.email}",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _checkEmailVerification,
//               child: Text("I've Verified My Email"),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: _sendVerificationEmail,
//               child: Text("Resend Verification Email"),
//             ),
//             if (isLoading) CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }