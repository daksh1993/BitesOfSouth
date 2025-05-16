import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServicesMenu {
  final _firestore = FirebaseFirestore.instance;

  create(MenuItem item) async {
    try {
      print("In database Services");
      await _firestore.collection('menu').add(item.toMap());
      print("Item added successfully from database_services_menu.dart");
    } catch (e) {
      print(e);
    }
  }
}
