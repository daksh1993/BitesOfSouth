import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String title;
  final String price;
  final String description;
  final String makingTime;
  final String category;
  final String rating;
  final String imageUrl;
  final bool availability; // New field

  MenuItem({
    required this.title,
    required this.price,
    required this.description,
    required this.makingTime,
    required this.category,
    required this.rating,
    required this.imageUrl,
     this.availability = true, // Default value
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MenuItem(
      title: data['title'],
      price: data['price'],
      description: data['description'],
      makingTime: data['makingTime'],
      category: data['category'],
      imageUrl: data['image'],
      rating: data['rating'],
      availability: data['availability'] ?? true, // Handle missing field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'makingTime': makingTime,
      'category': category,
      'image': imageUrl,
      'rating': rating,
      'availability': availability, // Include in Firestore
    };
  }
}