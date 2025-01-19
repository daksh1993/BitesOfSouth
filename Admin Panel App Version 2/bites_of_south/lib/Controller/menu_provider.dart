import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:bites_of_south/Modal/menu_item.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  // Fetch menu items from Firestore
  Future<void> fetchMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance.collection('menu').get();
      _menuItems = snapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new item to the menu
  Future<void> addMenuItem(MenuItem item) async {
    try {
      await FirebaseFirestore.instance.collection('menu').add(item.toMap());
      _menuItems.add(item); // Update the list locally
      notifyListeners();
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImageToStorage(File image) async {
    try {
      final fileName = Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('menu_images/$fileName');
      await ref.putFile(image);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }
}