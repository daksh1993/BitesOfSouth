// item_detail_auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetailAuthProvider with ChangeNotifier {
  bool isLoading = false;

  // Update item availability in Firestore
  Future<void> updateAvailability({
    required String itemId,
    required bool newValue,
    required BuildContext context,
    required Function(bool) onSuccess,
  }) async {
    print('Starting updateAvailability for itemId: $itemId with value: $newValue');
    isLoading = true;
    notifyListeners();

    try {
      print('Updating availability in Firestore');
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(itemId)
          .update({'availability': newValue});
      
      print('Availability updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Availability updated to ${newValue ? 'Enabled' : 'Disabled'} successfully!"),
        ),
      );
      onSuccess(newValue);
    } catch (e) {
      print('Error updating availability: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating availability: $e")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
      print('updateAvailability completed');
    }
  }

  // Update item details in Firestore
  Future<void> updateItemDetails({
    required String itemId,
    required Map<String, dynamic> updatedItem,
    required BuildContext context,
    required Function(Map<String, dynamic>) onSuccess,
  }) async {
    print('Starting updateItemDetails for itemId: $itemId');
    isLoading = true;
    notifyListeners();

    try {
      print('Updating item details in Firestore');
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(itemId)
          .update(updatedItem);
      
      print('Item updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item updated successfully!")),
      );
      onSuccess(updatedItem);
    } catch (e) {
      print('Error updating item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
      print('updateItemDetails completed');
    }
  }
}