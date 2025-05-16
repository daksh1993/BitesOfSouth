import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsModal {
  final String id;
  String title;
  String price;
  String description;
  String makingTime;
  double makingPrice;
  String category;
  String rating;
  String imageUrl;
  bool isAvailable;

  ItemDetailsModal({
    this.id = '',
    required this.title,
    required this.price,
    required this.description,
    required this.makingTime,
    required this.makingPrice,
    required this.category,
    required this.rating,
    required this.imageUrl,
    this.isAvailable = true,
  });

  factory ItemDetailsModal.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>? ?? {};
    return ItemDetailsModal(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: data['price'] as String? ?? '0.0',
      description: data['description'] as String? ?? '',
      makingTime: data['makingTime'] as String? ?? '0',
      makingPrice: data['makingPrice'] as double? ?? 0.0,
      category: data['category'] as String? ?? 'Uncategorized',
      imageUrl: data['image'] as String? ?? '',
      rating: data['rating'] as String? ?? '0.0',
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'makingTime': makingTime,
      'makingPrice': makingPrice,
      'category': category,
      'image': imageUrl,
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }
}
