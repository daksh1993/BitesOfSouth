// import 'package:bites_of_south/View/Authentication/emailVerification.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// class OTPVerification extends StatefulWidget {
//   final String verificationId;
//   final User? user;
//   final String phoneNumber; // Add phoneNumber as a parameter

//   const OTPVerification({
//     super.key,
//     required this.verificationId,
//     required this.user,
//     required this.phoneNumber, // Initialize phoneNumber
//   });

//   @override
//   State<OTPVerification> createState() => _OTPVerificationState();
// }

// class _OTPVerificationState extends State<OTPVerification> {
//   final List<TextEditingController> _otpControllers =
//       List.generate(6, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

//   late String _currentVerificationId;

//   @override
//   void initState() {
//     super.initState();
//     _currentVerificationId = widget.verificationId;
//   }

//   void _resendOTP() async {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Resending OTP...")),
//     );

//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: widget.phoneNumber, // Use the passed phone number
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           try {
//             await widget.user!.linkWithCredential(credential);
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("Error linking credential: $e")),
//             );
//           }
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("OTP Resend Failed: ${e.message}")),
//           );
//         },
//         codeSent: (String newVerificationId, int? resendToken) {
//           setState(() {
//             _currentVerificationId = newVerificationId;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("OTP Resent Successfully!")),
//           );
//         },
//         codeAutoRetrievalTimeout: (String newVerificationId) {
//           setState(() {
//             _currentVerificationId = newVerificationId;
//           });
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   void _verifyOTP() async {
//     String otp = _otpControllers.map((controller) => controller.text).join();
//     if (otp.isEmpty || otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter a valid 6-digit OTP")),
//       );
//       return;
//     }

//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _currentVerificationId,
//         smsCode: otp,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Verified phone number successfully.')),
//       );
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => SendEmailConfirmation(user: widget.user),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error verifying OTP: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
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
//         scrollDirection: Axis.vertical,
//         child: Stack(
//           children: [
//             Container(
//               height: MediaQuery.sizeOf(context).height / 3,
//               decoration: BoxDecoration(
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
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 0),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Text(
//                       "Enter OTP",
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
//                       "A verification code has been sent to your registered number.",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
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
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: List.generate(
//                                 6,
//                                 (index) => SizedBox(
//                                   width: 40,
//                                   child: TextField(
//                                     controller: _otpControllers[index],
//                                     focusNode: _focusNodes[index],
//                                     keyboardType: TextInputType.number,
//                                     textAlign: TextAlign.center,
//                                     maxLength: 1,
//                                     decoration: const InputDecoration(
//                                       counterText: "",
//                                       border: OutlineInputBorder(),
//                                     ),
//                                     onChanged: (value) {
//                                       if (value.isNotEmpty && index < 5) {
//                                         FocusScope.of(context).requestFocus(
//                                             _focusNodes[index + 1]);
//                                       } else if (value.isEmpty && index > 0) {
//                                         FocusScope.of(context).requestFocus(
//                                             _focusNodes[index - 1]);
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 minimumSize: const Size(double.infinity, 50),
//                               ),
//                               onPressed: _verifyOTP,
//                               child: const Text(
//                                 "Verify OTP",
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: TextButton(
//                                 onPressed: _resendOTP,
//                                 child: const Text(
//                                   "Resend OTP",
//                                   style: TextStyle(color: Colors.blue),
//                                 ),
//                               ),
//                             ),
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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final User user;
  final String docId;
  const PhoneVerificationScreen(
      {required this.user, required this.docId, super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;
  bool isLoading = false;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _getPhoneAndSendOTP();
  }

  Future<void> _getPhoneAndSendOTP() async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(widget.docId).get();
      setState(() {
        phoneNumber = doc['phone'];
      });

      // Always send OTP, even if phone number is already linked
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _handleCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone Verification Failed: ${e.message}")),
          );
          setState(() => isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            isLoading = false;
          });
          print("otp sent");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching phone number: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    setState(() => isLoading = true);
    try {
      String otp = _otpControllers.map((controller) => controller.text).join();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _handleCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verification Failed: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleCredential(PhoneAuthCredential credential) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Check if a phone number is already linked
        if (currentUser.phoneNumber != null) {
          if (currentUser.phoneNumber == phoneNumber) {
            // Phone number matches, verify the credential by signing in
            await _auth.signInWithCredential(credential);
            await _completeVerification();
          } else {
            // A different phone number is linked, inform the user
            throw FirebaseAuthException(
              code: 'provider-already-linked',
              message:
                  'A different phone number is already linked to this account.',
            );
          }
        } else {
          // No phone number linked yet, link it
          await currentUser.linkWithCredential(credential);
          await _completeVerification();
        }
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException && e.code == 'provider-already-linked') {
        errorMessage =
            "A different phone number is already linked to this account.";
      } else {
        errorMessage = "Failed to verify phone number: $e";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _completeVerification() async {
    await _firestore.collection('users').doc(widget.docId).update({
      'phoneVerified': true,
      'isAuthenticated': true,
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Phone number verified successfully")),
    );
    // print(_auth.currentUser.toString());
    // DocumentSnapshot userDoc = await _firestore
    //     .collection('users')
    //     .where('email', isEqualTo: _auth.currentUser!.email)
    //     .limit(1)
    //     .get()
    //     .then((snapshot) => snapshot.docs.first);

    // String docId = userDoc.id;
    // print(userDoc.data());

    // print(docId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('docId', widget.docId);
    await prefs.setBool("loggedin", true);

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Image(
          image: NetworkImage(
              "https://firebasestorage.googleapis.com/v0/b/bitesofsouth-a38f4.firebasestorage.app/o/round_logo.png?alt=media&token=57af3ab9-1836-46a9-a1c9-130275ef1bec"),
          // image: AssetImage("assets/round_logo.png"),
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
              padding:
                  EdgeInsets.only(top: MediaQuery.sizeOf(context).height / 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      phoneNumber == null
                          ? "Fetching phone number..."
                          : "A verification code has been sent to ${phoneNumber!.substring(phoneNumber!.length - 4)}",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height / 15),
                  if (phoneNumber != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  6,
                                  (index) => SizedBox(
                                    width: 40,
                                    child: TextField(
                                      controller: _otpControllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      decoration: const InputDecoration(
                                        counterText: "",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          FocusScope.of(context).requestFocus(
                                              _focusNodes[index + 1]);
                                        } else if (value.isEmpty && index > 0) {
                                          FocusScope.of(context).requestFocus(
                                              _focusNodes[index - 1]);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: _verifyOTP,
                                child: const Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _getPhoneAndSendOTP,
                                  child: const Text(
                                    "Resend OTP",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              if (isLoading)
                                Container(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.2,
                                  child: Lottie.asset("assets/loadin.json"),
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
