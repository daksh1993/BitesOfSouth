// import 'package:bites_of_south/View/Authentication/otpScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class PhoneVerification extends StatefulWidget {
//   final User? user;
//   final String maskedPhoneNumber; // Last 4 digits exposed

//   const PhoneVerification(
//       {super.key, this.user, required this.maskedPhoneNumber});

//   @override
//   State<PhoneVerification> createState() => _PhoneVerificationState();
// }

// class _PhoneVerificationState extends State<PhoneVerification> {
//   final TextEditingController _phoneController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _verifyPhoneNumber() async {
//     final phoneNumber = "${_phoneController.text.trim()}";
//     if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid 10-digit phone number.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     if (!phoneNumber.endsWith(widget.maskedPhoneNumber)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text('Entered phone number does not match the last 4 digits.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Sending OTP...'),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     try {
//       await _auth.verifyPhoneNumber(
//         forceResendingToken: null,
//         phoneNumber: "+91$phoneNumber",
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.signInWithCredential(credential);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("Phone number automatically verified")),
//           );
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//                 builder: (context) => OTPVerification( verificationId: '', user: widget.user)),
//           );
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification failed: ${e.message}")),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) =>
//                   OTPVerification(verificationId: verificationId, user: widget.user),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("OTP timed out. Try again.")),
//           );
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error verifying phone: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Image(
//           image: const AssetImage("assets/round_logo.png"),
//           fit: BoxFit.cover,
//           height: MediaQuery.sizeOf(context).height / 24,
//         ),
//         backgroundColor: Colors.green,
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               height: MediaQuery.sizeOf(context).height / 3,
//               decoration: const BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(18),
//                   bottomRight: Radius.circular(18),
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Is this you?",
//                       style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Enter your phone number ending with xxxxxx${widget.maskedPhoneNumber}",
//                       style: const TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(height: MediaQuery.sizeOf(context).height / 15),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(top: 20, left: 20, right: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 12),
//                             TextField(
//                               controller: _phoneController,
//                               keyboardType: TextInputType.phone,
//                               maxLength: 10,
//                               decoration: InputDecoration(
//                                 prefixIcon:
//                                     const Icon(Icons.phone, color: Colors.grey),
//                                 labelText: "Enter Full Phone Number",
//                                 labelStyle: const TextStyle(color: Colors.grey),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               onPressed: _verifyPhoneNumber,
//                               child: const Text(
//                                 "Verify",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:bites_of_south/View/Authentication/emailVerification.dart';
// import 'package:bites_of_south/View/Authentication/otpScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class PhoneVerification extends StatefulWidget {
//   final User? user;
//   final String maskedPhoneNumber; // Last 4 digits exposed

//   const PhoneVerification(
//       {super.key, this.user, required this.maskedPhoneNumber});

//   @override
//   State<PhoneVerification> createState() => _PhoneVerificationState();
// }

// class _PhoneVerificationState extends State<PhoneVerification> {
//   final TextEditingController _phoneController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   void _verifyPhoneNumber() async {
//     final phoneNumber = "${_phoneController.text.trim()}";
//     if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid 10-digit phone number.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     if (!phoneNumber.endsWith(widget.maskedPhoneNumber)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text('Entered phone number does not match the last 4 digits.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Sending OTP...'),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     try {
//       await _auth.verifyPhoneNumber(
//         forceResendingToken: null,
//         phoneNumber: "+91$phoneNumber",
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await widget.user!.linkWithCredential(credential);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text("Phone number automatically verified")),
//           );
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//                 builder: (context) =>
//                     SendEmailConfirmation(user: widget.user!)),
//           );
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification failed: ${e.message}")),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => OTPVerification(
//                   verificationId: verificationId,
//                   user: widget.user,
//                   phoneNumber: "+91${phoneNumber}"),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("OTP timed out. Try again.")),
//           );
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error verifying phone: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Image(
//           image: const AssetImage("assets/round_logo.png"),
//           fit: BoxFit.cover,
//           height: MediaQuery.sizeOf(context).height / 24,
//         ),
//         backgroundColor: Colors.green,
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               height: MediaQuery.sizeOf(context).height / 3,
//               decoration: const BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(18),
//                   bottomRight: Radius.circular(18),
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Is this you?",
//                       style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Enter your phone number ending with xxxxxx${widget.maskedPhoneNumber}",
//                       style: const TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(height: MediaQuery.sizeOf(context).height / 15),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(top: 20, left: 20, right: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 12),
//                             TextField(
//                               controller: _phoneController,
//                               keyboardType: TextInputType.phone,
//                               maxLength: 10,
//                               decoration: InputDecoration(
//                                 prefixIcon:
//                                     const Icon(Icons.phone, color: Colors.grey),
//                                 labelText: "Enter Full Phone Number",
//                                 labelStyle: const TextStyle(color: Colors.grey),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               onPressed: _verifyPhoneNumber,
//                               child: const Text(
//                                 "Verify",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PhoneVerificationScreen extends StatefulWidget {
//   final User user;
//   final String docId;
//   const PhoneVerificationScreen(
//       {required this.user, required this.docId, super.key});

//   @override
//   State<PhoneVerificationScreen> createState() =>
//       _PhoneVerificationScreenState();
// }

// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? _verificationId;
//   bool isLoading = false;
//   late String phoneNumber;

//   @override
//   void initState() {
//     super.initState();
//     _getPhoneAndSendOTP();
//   }

//   void _getPhoneAndSendOTP() async {
//     setState(() => isLoading = true);
//     DocumentSnapshot doc =
//         await _firestore.collection('users').doc(widget.docId).get();
//     phoneNumber = doc['phone'];

//     // Check if phone is already linked
//     bool isPhoneLinked = widget.user.providerData.any((provider) =>
//         provider.providerId == 'phone' && provider.phoneNumber == phoneNumber);

//     if (!isPhoneLinked) {
//       // If not linked, proceed with linking
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.currentUser!.linkWithCredential(credential);
//           _completeVerification();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification Failed: ${e.message}")),
//           );
//           setState(() => isLoading = false);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() {
//             _verificationId = verificationId;
//             isLoading = false;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     } else {
//       // If already linked, just verify without linking
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           // Auto-verification case
//           _completeVerification();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification Failed: ${e.message}")),
//           );
//           setState(() => isLoading = false);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() {
//             _verificationId = verificationId;
//             isLoading = false;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     }
//   }

//   void _verifyOTP() async {
//     setState(() => isLoading = true);
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: _otpController.text.trim(),
//       );

//       // Check if phone is already linked
//       bool isPhoneLinked = widget.user.providerData.any((provider) =>
//           provider.providerId == 'phone' &&
//           provider.phoneNumber == phoneNumber);

//       if (!isPhoneLinked) {
//         // Link if not already linked
//         await _auth.currentUser!.linkWithCredential(credential);
//       } else {
//         // If already linked, just verify the credential
//         await _auth.signInWithCredential(credential);
//       }

//       _completeVerification();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("OTP Verification Failed: $e")),
//       );
//       setState(() => isLoading = false);
//     }
//   }

//   void _completeVerification() async {
//     await _firestore.collection('users').doc(widget.docId).update({
//       'phoneVerified': true,
//       'isAuthenticated': true,
//       'lastLoginAt': FieldValue.serverTimestamp(),
//     });
//     Navigator.pushReplacementNamed(context, '/dashboard');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Phone")),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               "Enter the OTP sent to\n${phoneNumber.substring(phoneNumber.length - 4)}",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: "OTP",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _verifyOTP,
//               child: Text("Verify OTP"),
//             ),
//             if (isLoading) CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:bites_of_south/View/Authentication/otpScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PhoneNumberVerificationScreen extends StatefulWidget {
//   final User user;
//   final String docId;
//   final String maskedPhoneNumber;
//   const PhoneNumberVerificationScreen({
//     required this.user,
//     required this.docId,
//     required this.maskedPhoneNumber,
//     super.key,
//   });

//   @override
//   State<PhoneNumberVerificationScreen> createState() =>
//       _PhoneNumberVerificationScreenState();
// }

// class _PhoneNumberVerificationScreenState
//     extends State<PhoneNumberVerificationScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool isLoading = false;

//   void _verifyPhoneNumber() async {
//     setState(() => isLoading = true);
//     String enteredPhone = "+91" + _phoneController.text.trim();
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('users').doc(widget.docId).get();
//       String storedPhone = doc['phone'];
//       print("Stored phone: $storedPhone");

//       if (enteredPhone.endsWith(widget.maskedPhoneNumber) &&
//           enteredPhone == storedPhone) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => PhoneVerificationScreen(
//               user: widget.user,
//               docId: widget.docId,
//             ),
//           ),
//         );
//       } else {
//         print("Entered phone: $enteredPhone");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Phone number does not match")),
//         );
//       }
//     } catch (e) {
//       print(e);
//     }
//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Image(
//           image: NetworkImage(
//               "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec"),
//           fit: BoxFit.cover,
//           height: MediaQuery.sizeOf(context).height / 24,
//         ),
//         backgroundColor: Colors.green,
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               height: MediaQuery.sizeOf(context).height / 3,
//               decoration: const BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(18),
//                   bottomRight: Radius.circular(18),
//                 ),
//               ),
//             ),
//             Padding(
//               padding:
//                   EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Is this you?",
//                       style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Enter your phone number ending with xxxxxx${widget.maskedPhoneNumber}",
//                       style: const TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                   SizedBox(height: MediaQuery.sizeOf(context).height / 15),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(top: 20, left: 20, right: 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 12),
//                             TextField(
//                               controller: _phoneController,
//                               keyboardType: TextInputType.phone,
//                               maxLength: 10,
//                               decoration: InputDecoration(
//                                 prefixIcon:
//                                     const Icon(Icons.phone, color: Colors.grey),
//                                 labelText: "Enter Full Phone Number",
//                                 labelStyle: const TextStyle(color: Colors.grey),
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10)),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               onPressed: _verifyPhoneNumber,
//                               child: const Text(
//                                 "Verify",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:bites_of_south/Controller/Authentication/phone_auth_provider.dart';
import 'package:bites_of_south/View/Authentication/otpScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class PhoneNumberVerificationScreen extends StatefulWidget {
  final User user;
  final String docId;
  final String maskedPhoneNumber;
  const PhoneNumberVerificationScreen({
    required this.user,
    required this.docId,
    required this.maskedPhoneNumber,
    super.key,
  });

  @override
  State<PhoneNumberVerificationScreen> createState() =>
      _PhoneNumberVerificationScreenState();
}

class _PhoneNumberVerificationScreenState
    extends State<PhoneNumberVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PhoneValidityProvider>(
      builder: (context, phoneValidityProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Image(
              image: NetworkImage(
                  "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec"),
              fit: BoxFit.cover,
              height: MediaQuery.sizeOf(context).height / 24,
            ),
            backgroundColor: Colors.green,
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height / 3,
                  decoration: const BoxDecoration(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Is this you?",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Enter your phone number ending with xxxxxx${widget.maskedPhoneNumber}",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height / 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone,
                                        color: Colors.grey),
                                    labelText: "Enter Full Phone Number",
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  onPressed: phoneValidityProvider.isLoading
                                      ? null
                                      : () {
                                          phoneValidityProvider
                                              .verifyPhoneNumber(
                                            enteredPhone:
                                                _phoneController.text.trim(),
                                            docId: widget.docId,
                                            maskedPhoneNumber:
                                                widget.maskedPhoneNumber,
                                            context: context,
                                            onSuccess: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PhoneVerificationScreen(
                                                    user: widget.user,
                                                    docId: widget.docId,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                  child: phoneValidityProvider.isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          "Verify",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                                const SizedBox(height: 20),
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
      },
    );
  }
}
