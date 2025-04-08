import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:flutter/material.dart';

class OrderGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // Complete list of menu item IDs from your menu collection
  final List<String> menuItemIds = [
    "0zk06Giny5OBel70dtA8",
    "1NI7z5pYfROUqwPdYTfb",
    "2t0C3B7UOU8p0qkVMJ3S",
    "3N7TkROTVTcruAUq5623",
    "3xa9jOv9bZNay21XhYMy",
    "6Bo4Tfy7jyJi6MSOgsqx",
    "9KMiyR0NmXmzIahrawyl",
    "BHGS1JpindF7QT0sbrlE",
    "FFr83AYg1KEc0WwFdHzF",
    "GxNQpRfLabGA1LOcmyfC",
    "LbzAhCMie58IgszOlwX9",
    "LnwGoTVnY1so21zxbl5s",
    "MdXHnpl6tbdCXbNu4xjk",
    "NHwJRjLaVnAWuQkAjuiX",
    "P9ZLeyXMh9I72RXtUt3G",
    "PEUBjU7LLgF8il0rGI3e",
    "Rdcgy7Ed43zA7t3hNPXs",
    "TFKu8eI69wGTqxl0mAHH",
    "Vucx3QmOs3JqGhBECraz",
    "ZZ5maop7LBQjKQd8Hwbf",
    "ZqAUwmYk0KodApoQcxid",
    "aAhZCtIvYAXbDsb2sWut",
    "fLXb33rDLFI3E1XGrIIY",
    "h5cuPaMFb2nKLn4zeq2G",
    "iBHtkYHlYFXdWNXgPzWS",
    "iZ9HNAVcQwGGxC1Sfk2L",
    "jqKqs2MrBGDn7CyVIfGS",
    "kIexMyU9I98zKTaVMz5w",
    "khX0XkaDuCdmMFU8bzcp",
    "lDPIZ29OIVWER6FQ9xPK",
    "lLQYtdv7cjzENuTy2lbZ",
    "lM6toBXwsfhfxxHfDsny",
    "lgeRysOCOBmdvllD6jrZ",
    "nd8MmlLXHcRHwIHvrkT1",
    "ngR3Bqfna9WLI8lWFVXJ",
    "pT0QBCuFtig4xO3jIBuC",
    "pTIQ9QCFyzeWYPM4vGKc",
    "prAvNK4DWEkxwjuKB5wC",
    "q3cDcbaF1xRIBmFgvrti",
    "qfw8sLtTwlNueKcj6lfp",
    "qpEGjAm4kZ7IGelB7tIx",
    "t7a5hNJj2ary1ofl2Hya",
    "wiax2KQVdKDgWoUr59Yw",
  ];

  // Updated list of user IDs including the new ones you provided
  final List<String> userIds = [
    "HRCALPvnTYNjX5zQ7BWfLebxRZ03",
    "CQIdIBhOhvQmqsC3uGNeo8zi67o2",
    "e6B9bMQbZ9Pr9ZbjF4xpWgkHRpB2",
    "mGdss1mIKnPWE9mDsh7rXyJbcxE3",
  ];

  Future<void> generateOrdersForLastYear() async {
    try {
      // Get timestamp for one year ago
      DateTime oneYearAgo = DateTime.now().subtract(Duration(days: 1));
      DateTime currentDate = oneYearAgo;

      // Generate orders for each month
      while (currentDate.isBefore(DateTime.now())) {
        // Generate random number of orders (1-5) per day
        int ordersPerDay = _random.nextInt(10) + 1;

        for (int i = 0; i < ordersPerDay; i++) {
          await _addRandomOrder(currentDate);
        }

        // Move to next day
        currentDate = currentDate.add(Duration(days: 1));
      }
      print("Orders generated successfully!");
    } catch (e) {
      print("Error generating orders: $e");
    }
  }

  Future<void> _addRandomOrder(DateTime date) async {
    // Generate random number of items (1-4) for the order
    int itemCount = _random.nextInt(4) + 1;
    List<Map<String, dynamic>> items = [];

    // Total amount calculation
    double totalAmount = 0;

    // Menu items with their prices for reference
    final Map<String, Map<String, dynamic>> menuReference = {
      "0zk06Giny5OBel70dtA8": {"name": "Sada Uttapam", "price": 45},
      "1NI7z5pYfROUqwPdYTfb": {"name": "Cheese Dosa", "price": 79},
      "2t0C3B7UOU8p0qkVMJ3S": {"name": "Schezwan Dosa", "price": 119},
      "3N7TkROTVTcruAUq5623": {"name": "Peri Peri Dosa", "price": 199},
      "3xa9jOv9bZNay21XhYMy": {"name": "Dilkhush Dosa", "price": 149},
      "6Bo4Tfy7jyJi6MSOgsqx": {"name": "Schezwan Cheese Uttapam", "price": 79},
      "9KMiyR0NmXmzIahrawyl": {"name": "Bangalore Thali", "price": 749},
      "BHGS1JpindF7QT0sbrlE": {"name": "Mysore Masala Dosa", "price": 129},
      "FFr83AYg1KEc0WwFdHzF": {"name": "Kerala Thali", "price": 699},
      "GxNQpRfLabGA1LOcmyfC": {"name": "Onion Uttapam", "price": 59},
      "LbzAhCMie58IgszOlwX9": {"name": "Chocolate Dosa", "price": 149},
      "LnwGoTVnY1so21zxbl5s": {"name": "Onion Tomato Uttapam", "price": 79},
      "MdXHnpl6tbdCXbNu4xjk": {"name": "Sada Dosa", "price": 69},
      "NHwJRjLaVnAWuQkAjuiX": {"name": "Powder Dosa", "price": 79},
      "P9ZLeyXMh9I72RXtUt3G": {"name": "Banglore Special Dosa", "price": 149},
      "PEUBjU7LLgF8il0rGI3e": {"name": "Cheese Onion Uttapam", "price": 69},
      "Rdcgy7Ed43zA7t3hNPXs": {"name": "BiteOfSouth Special", "price": 849},
      "TFKu8eI69wGTqxl0mAHH": {"name": "Ginni Dosa", "price": 159},
      "Vucx3QmOs3JqGhBECraz": {"name": "Onion Dosa", "price": 109},
      "ZZ5maop7LBQjKQd8Hwbf": {
        "name": "Cheese Mysore Masala Dosa",
        "price": 89
      },
      "ZqAUwmYk0KodApoQcxid": {"name": "Rava Dosa", "price": 59},
      "aAhZCtIvYAXbDsb2sWut": {"name": "Pav Bhaji Dosa", "price": 149},
      "fLXb33rDLFI3E1XGrIIY": {"name": "Rava Masala Dosa", "price": 69},
      "h5cuPaMFb2nKLn4zeq2G": {
        "name": "BitesOfSouth Special Dosa",
        "price": 199
      },
      "iBHtkYHlYFXdWNXgPzWS": {"name": "Cheese Thate Idli", "price": 59},
      "iZ9HNAVcQwGGxC1Sfk2L": {"name": "Panner Chilli Dosa", "price": 199},
      "jqKqs2MrBGDn7CyVIfGS": {"name": "Kerala Special Dosa", "price": 149},
      "kIexMyU9I98zKTaVMz5w": {"name": "Cheese Tomato Uttapam", "price": 69},
      "khX0XkaDuCdmMFU8bzcp": {"name": "Pizza Dosa", "price": 139},
      "lDPIZ29OIVWER6FQ9xPK": {"name": "Tandoori Dosa", "price": 149},
      "lLQYtdv7cjzENuTy2lbZ": {"name": "Masala Thatte Idli", "price": 69},
      "lM6toBXwsfhfxxHfDsny": {"name": "Masala Uttapam", "price": 79},
      "lgeRysOCOBmdvllD6jrZ": {"name": "Tomato Uttapam", "price": 59},
      "nd8MmlLXHcRHwIHvrkT1": {"name": "Idli Fry", "price": 79},
      "ngR3Bqfna9WLI8lWFVXJ": {"name": "Medu Vada", "price": 49},
      "pT0QBCuFtig4xO3jIBuC": {
        "name": "Cheese Paneer Schezwan Dosa",
        "price": 159
      },
      "pTIQ9QCFyzeWYPM4vGKc": {"name": "Schezwan Uttapam", "price": 69},
      "prAvNK4DWEkxwjuKB5wC": {"name": "Thate Idli", "price": 69},
      "q3cDcbaF1xRIBmFgvrti": {"name": "Chilli Idli", "price": 89},
      "qfw8sLtTwlNueKcj6lfp": {"name": "Idli", "price": 49},
      "qpEGjAm4kZ7IGelB7tIx": {"name": "Cheese Idli Fry", "price": 79},
      "t7a5hNJj2ary1ofl2Hya": {"name": "Pahadi Dosa", "price": 159},
      "wiax2KQVdKDgWoUr59Yw": {"name": "Masala Dosa", "price": 119},
    };

    // Generate items for the order
    for (int i = 0; i < itemCount; i++) {
      String itemId = menuItemIds[_random.nextInt(menuItemIds.length)];
      Map<String, dynamic>? menuItem = menuReference[itemId];

      if (menuItem != null) {
        int quantity = _random.nextInt(3) + 1;
        double price = menuItem["price"].toDouble();

        Map<String, dynamic> item = {
          "isRedeemed": false,
          "itemId": itemId,
          "makingTime": 3, // You could make this dynamic from menu data
          "name": menuItem["name"],
          "price": menuItem["price"].toString(),
          "quantity": quantity,
          "requiredPoints": 0,
        };

        totalAmount += price * quantity;
        items.add(item);
      }
    }

    // Generate order document
    Map<String, dynamic> order = {
      "couponCode": null,
      "dineIn": _random.nextBool(),
      "discount": 0,
      "instructions": "No instructions provided",
      "items": items,
      "makingTime": 3,
      "orderStatus": "Completed",
      "paymentDetails": {
        "amount": (totalAmount * 100).toInt(), // Convert to paise
        "amountRefunded": 0,
        "captured": true,
        "currency": "INR",
        "paymentTimestamp": Timestamp.fromDate(date).millisecondsSinceEpoch,
        "razorpayOrderId": "order_${_generateRandomId()}",
        "razorpayPaymentId": "pay_${_generateRandomId()}",
        "refundStatus": null,
        "status": "captured",
        "testMode": true,
      },
      "paymentStatus": "Paid",
      "pendingStatus": "100",
      "tableNo": null,
      "timestamp": Timestamp.fromDate(date).millisecondsSinceEpoch,
      "totalAmount": totalAmount,
      "userId": userIds[_random.nextInt(userIds.length)],
    };

    // Add to Firestore
    await _firestore.collection('orders').add(order);
  }

  String _generateRandomId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }
}

// Widget with button to trigger order generation
class OrderGeneratorButton extends StatelessWidget {
  final OrderGenerator generator = OrderGenerator();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await generator.generateOrdersForLastYear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orders generated successfully!')),
        );
      },
      child: Text('Generate Past Year Orders'),
    );
  }
}
