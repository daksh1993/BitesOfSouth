import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String title;
  final String price;
  final double makingPrice; // New field
  final String description;
  final String makingTime;
  final String category;
  final String rating;
  final String imageUrl;
  final bool availability;

  MenuItem({
    required this.title,
    required this.price,
    required this.makingPrice,
    required this.description,
    required this.makingTime,
    required this.category,
    required this.rating,
    required this.imageUrl,
    this.availability = true,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MenuItem(
      title: data['title'] ?? '',
      price: data['price'] ?? '',
      makingPrice: data['makingPrice'] ?? '', // Handle new field
      description: data['description'] ?? '',
      makingTime: data['makingTime'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['image'] ?? '',
      rating: data['rating'] ?? '',
      availability: data['availability'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'makingPrice': makingPrice, // Include in Firestore
      'description': description,
      'makingTime': makingTime,
      'category': category,
      'image': imageUrl,
      'rating': rating,
      'availability': availability,
    };
  }
}
