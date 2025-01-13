import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String title;
  final String price;
  final String description;
  final String makingTime;
  final String category;
  final String imageUrl;

  MenuItem({
    required this.title,
    required this.price,
    required this.description,
    required this.makingTime,
    required this.category,
    required this.imageUrl,
  });

  // Convert Firestore data to MenuItem object
  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MenuItem(
      title: data['title'],
      price: data['price'],
      description: data['description'],
      makingTime: data['making_time'],
      category: data['category'],
      imageUrl: data['image_url'],
    );
  }

  // Convert MenuItem object to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'making_time': makingTime,
      'category': category,
      'image_url': imageUrl,
    };
  }
}