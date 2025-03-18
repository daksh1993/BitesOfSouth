// phone_auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PhoneValidityProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // Verify phone number against Firestore data
  Future<void> verifyPhoneNumber({
    required String enteredPhone,
    required String docId,
    required String maskedPhoneNumber,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    print('Starting phone number verification');
    isLoading = true;
    notifyListeners();

    String fullPhone = "+91" + enteredPhone.trim();
    print('Formatted phone number: $fullPhone');

    try {
      print('Fetching user document from Firestore with docId: $docId');
      DocumentSnapshot doc = await _firestore.collection('users').doc(docId).get();
      String storedPhone = doc['phone'];
      print('Stored phone number: $storedPhone');

      if (fullPhone.endsWith(maskedPhoneNumber) && fullPhone == storedPhone) {
        print('Phone number verification successful');
        onSuccess();
      } else {
        print('Phone number verification failed');
        print('Entered phone: $fullPhone');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone number does not match")),
        );
      }
    } catch (e) {
      print('Error in phone verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      print('Phone verification process completed');
      isLoading = false;
      notifyListeners();
    }
  }
}