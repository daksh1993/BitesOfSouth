// menu_load_auth.dart
import 'package:bites_of_south/Modal/item_details_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuLoadAuth with ChangeNotifier {
  List<ItemDetailsModal> _itemDetails = [];
  Map<String, List<ItemDetailsModal>> _groupedItems = {};
  bool _isLoading = false;

  List<ItemDetailsModal> get itemDetails => _itemDetails;
  Map<String, List<ItemDetailsModal>> get groupedItems => _groupedItems;
  bool get isLoading => _isLoading;

  // Fetch menu items from Firestore
  Future<void> fetchMenuItems() async {
    print('Starting fetchMenuItems');
    _isLoading = true;
    notifyListeners();

    try {
      print('Fetching menu items from Firestore');
      final snapshot = await FirebaseFirestore.instance.collection('menu').get();
      _itemDetails = snapshot.docs
          .map((doc) => ItemDetailsModal.fromFirestore(doc))
          .toList();
      print('Fetched ${_itemDetails.length} items');
      _groupItemsByCategory();
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      print('fetchMenuItems completed');
    }
  }

  // Group items by category
  void _groupItemsByCategory() {
    print('Grouping items by category');
    _groupedItems.clear();
    for (var item in _itemDetails) {
      if (_groupedItems.containsKey(item.category)) {
        _groupedItems[item.category]!.add(item);
      } else {
        _groupedItems[item.category] = [item];
      }
    }
    print('Grouped into ${_groupedItems.length} categories');
    notifyListeners();
  }

  // Filter items based on search text
  void filterItems(String searchText) {
    print('Filtering items with search text: $searchText');
    _groupedItems.clear();
    if (searchText.isEmpty) {
      _groupItemsByCategory();
    } else {
      for (var item in _itemDetails) {
        if (item.title.toLowerCase().contains(searchText.toLowerCase())) {
          if (_groupedItems.containsKey(item.category)) {
            _groupedItems[item.category]!.add(item);
          } else {
            _groupedItems[item.category] = [item];
          }
        }
      }
    }
    print('Filtered into ${_groupedItems.length} categories');
    notifyListeners();
  }

  // Delete selected items from Firestore
  Future<void> deleteSelectedItems(Set<String> selectedItems) async {
    print('Starting deleteSelectedItems for ${selectedItems.length} items');
    _isLoading = true;
    notifyListeners();

    try {
      for (String itemId in selectedItems) {
        print('Deleting item with ID: $itemId');
        await FirebaseFirestore.instance.collection('menu').doc(itemId).delete();
      }
      print('Items deleted successfully');
      await fetchMenuItems(); // Refresh after deletion
    } catch (e) {
      print("Error deleting items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      print('deleteSelectedItems completed');
    }
  }
}