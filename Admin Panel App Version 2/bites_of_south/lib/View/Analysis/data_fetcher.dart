import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Fetches analysis data from Firestore based on date range
Future<Map<String, dynamic>> fetchAnalysisData(
    DateTime? startDate, DateTime? endDate) async {
  try {
    Query<Map<String, dynamic>> ordersQuery =
        FirebaseFirestore.instance.collection('orders'); // Query for orders collection

    // Apply start date filter if provided
    if (startDate != null) {
      final startMillis = startDate.millisecondsSinceEpoch;
      ordersQuery =
          ordersQuery.where('timestamp', isGreaterThanOrEqualTo: startMillis);
      print('DataFetcher: Applying start date filter - $startDate');
    }
    // Apply end date filter if provided
    if (endDate != null) {
      final endMillis =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
              .millisecondsSinceEpoch;
      ordersQuery = ordersQuery.where('timestamp', isLessThanOrEqualTo: endMillis);
      print('DataFetcher: Applying end date filter - $endDate');
    }

    // Fetch orders and menu data concurrently
    final ordersSnapshot = await ordersQuery.get();
    final menuSnapshot = await FirebaseFirestore.instance.collection('menu').get();
    print('DataFetcher: Fetched ${ordersSnapshot.docs.length} orders and ${menuSnapshot.docs.length} menu items');

    // Map menu items by ID
    Map<String, Map<String, dynamic>> menuItems = {
      for (var doc in menuSnapshot.docs) doc.id: doc.data()
    };

    // Initialize analysis metrics
    double netSales = 0.0;
    double netProfit = 0.0;
    Map<String, int> itemQuantities = {};
    Map<String, double> itemRevenues = {};
    Map<String, double> itemProfits = {};
    Map<String, int> trendingItems = {};
    Map<int, double> dailyRevenues = {};
    Map<int, double> dailyProfits = {};

    // Process each order
    for (var order in ordersSnapshot.docs) {
      final orderData = order.data();
      final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
      final totalAmount = (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final timestamp = (orderData['timestamp'] as num?)?.toInt() ?? 0;
      final orderDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final daysSinceEpoch = orderDate.difference(DateTime(1970, 1, 1)).inDays;

      netSales += totalAmount; // Aggregate total sales
      dailyRevenues[daysSinceEpoch] =
          (dailyRevenues[daysSinceEpoch] ?? 0) + totalAmount;

      // Process each item in the order
      for (var item in items) {
        if (item['isRedeemed'] == true) continue; // Skip redeemed items

        final itemId = item['itemId'] as String? ?? '';
        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final price = double.tryParse(item['price'] ?? '0') ?? 0.0;
        final menuItem = menuItems[itemId];
        final makingPrice = (menuItem?['makingPrice'] as num?)?.toDouble() ?? 0.0;

        // Update item metrics
        itemQuantities[itemId] = (itemQuantities[itemId] ?? 0) + quantity;
        itemRevenues[itemId] = (itemRevenues[itemId] ?? 0) + (price * quantity);
        itemProfits[itemId] =
            (itemProfits[itemId] ?? 0) + ((price - makingPrice) * quantity);
        netProfit += (price - makingPrice) * quantity;

        dailyProfits[daysSinceEpoch] = (dailyProfits[daysSinceEpoch] ?? 0) +
            ((price - makingPrice) * quantity);

        trendingItems[itemId] = (trendingItems[itemId] ?? 0) + quantity;
      }
    }

    final result = {
      'netSales': netSales,
      'netProfit': netProfit,
      'itemQuantities': itemQuantities,
      'itemRevenues': itemRevenues,
      'itemProfits': itemProfits,
      'trendingItems': trendingItems,
      'menuItems': menuItems,
      'dailyRevenues': dailyRevenues,
      'dailyProfits': dailyProfits,
    };
    print('DataFetcher: Analysis data prepared - Net Sales: $netSales, Net Profit: $netProfit');
    return result;
  } catch (e) {
    print('DataFetcher: Error fetching analysis data - $e');
    // Return empty data on error
    return {
      'netSales': 0.0,
      'netProfit': 0.0,
      'itemQuantities': <String, int>{},
      'itemRevenues': <String, double>{},
      'itemProfits': <String, double>{},
      'trendingItems': <String, int>{},
      'menuItems': <String, Map<String, dynamic>>{},
      'dailyRevenues': <int, double>{},
      'dailyProfits': <int, double>{},
    };
  }
}

// Fetches the logo from Firestore settings
Future<Uint8List> fetchLogo() async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('ZBr4W8fiLsfeX8kYo51v')
        .get();
    final logoUrl = doc.data()?['logo'] as String?;
    print('DataFetcher: Fetching logo from URL - $logoUrl');

    if (logoUrl != null) {
      final response = await http.get(Uri.parse(logoUrl));
      print('DataFetcher: Logo fetched, bytes length: ${response.bodyBytes.length}');
      return response.bodyBytes;
    }
    print('DataFetcher: No logo URL found');
    return Uint8List(0); // Return empty bytes if no logo
  } catch (e) {
    print('DataFetcher: Error fetching logo - $e');
    return Uint8List(0);
  }
}

// Fetches user data from SharedPreferences and Firestore
Future<Map<String, dynamic>> fetchUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final docId = prefs.getString('docId');
    print('DataFetcher: Fetching user data for docId - $docId');

    if (docId != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(docId).get();
      final result = {
        'name': userDoc.data()?['name'] ?? 'Unknown',
        'role': userDoc.data()?['role'] ?? 'Unknown',
      };
      print('DataFetcher: User data fetched - Name: ${result['name']}, Role: ${result['role']}');
      return result;
    }
    print('DataFetcher: No docId found in SharedPreferences');
    return {'name': 'Unknown', 'role': 'Unknown'};
  } catch (e) {
    print('DataFetcher: Error fetching user data - $e');
    return {'name': 'Unknown', 'role': 'Unknown'};
  }
}

// Explanation:
// This file encapsulates all data fetching logic for the analysis dashboard. `fetchAnalysisData` retrieves and processes order and menu data from Firestore, aggregating metrics like net sales, profit, and item-specific stats based on an optional date range. `fetchLogo` retrieves the logo image bytes from a URL stored in Firestore settings, and `fetchUserData` gets user details from SharedPreferences and Firestore. Debugging print statements help track the data retrieval process and identify issues.