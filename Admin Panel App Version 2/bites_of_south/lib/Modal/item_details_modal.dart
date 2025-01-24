import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsModal {
  final String id;
  String title;
  String price;
  String description;
  String makingTime;
  String category;
  String rating;
  String imageUrl;

  ItemDetailsModal({
    this.id = '',
    required this.title,
    required this.price,
    required this.description,
    required this.makingTime,
    required this.category,
    required this.rating,
    required this.imageUrl,
  });

  // Convert Firestore data to MenuItem object
  factory ItemDetailsModal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ItemDetailsModal(
      id: doc.id,
      title: data['title'],
      price: data['price'],
      description: data['description'],
      makingTime: data['makingTime'],
      category: data['category'],
      imageUrl: data['image'],
      rating: data['rating'],
    );
  }

  // Convert MenuItem object to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'makingTime': makingTime,
      'category': category,
      'image': imageUrl,
      'rating': rating,
    };
  }
}
