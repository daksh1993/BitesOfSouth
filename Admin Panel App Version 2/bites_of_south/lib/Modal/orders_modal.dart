import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModal {
  final String? id;
  final bool dineIn;
  final List<OrderItem> items;
  final double totalAmount;
  final String? orderStatus;
  final String? pendingStatus;
  final String? paymentStatus;
  final String? tableNo;
  final int timestamp;
  final PaymentDetails paymentDetails;
  final String? userId;

  OrdersModal({
    this.id,
    required this.dineIn,
    required this.items,
    required this.totalAmount,
    this.orderStatus,
    this.pendingStatus,
    this.paymentStatus,
    this.tableNo,
    required this.timestamp,
    required this.paymentDetails,
    this.userId,
  });

  factory OrdersModal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Firestore document data is null');
    }
    return OrdersModal(
      id: doc.id,
      dineIn: data['dineIn'] as bool? ?? false,
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] is num
          ? (data['totalAmount'] as num).toDouble()
          : data['totalAmount'] is String
              ? double.tryParse(data['totalAmount'] as String) ?? 0.0
              : 0.0),
      orderStatus: data['orderStatus'] as String? ?? 'Pending',
      pendingStatus: data['pendingStatus'] as String? ?? '0',
      paymentStatus: data['paymentStatus'] as String? ?? 'Unknown',
      tableNo: data['tableNo'] as String? ?? '',
      timestamp: (data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
              : data['timestamp'] is String
                  ? int.tryParse(data['timestamp'] as String) ?? 0
                  : data['timestamp'] as int?) ??
          0,
      paymentDetails: PaymentDetails.fromMap(
          data['paymentDetails'] as Map<String, dynamic>? ?? {}),
      userId: data['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dineIn': dineIn,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'pendingStatus': pendingStatus,
      'paymentStatus': paymentStatus,
      'tableNo': tableNo,
      'timestamp': timestamp,
      'paymentDetails': paymentDetails.toMap(),
      'userId': userId,
    };
  }
}

class OrderItem {
  final String itemId;
  final String? name;
  final int quantity;
  final String price; // Kept as String as per Firestore data
  final int makingTime;
  final String? orderStatus;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.makingTime,
    this.orderStatus,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown Item',
      quantity: (data['quantity'] is String
              ? int.tryParse(data['quantity'] as String) ?? 0
              : data['quantity'] as int?) ??
          0,
      price: data['price'] as String? ?? '0',
      makingTime: (data['makingTime'] is String
              ? int.tryParse(data['makingTime'] as String) ?? 0
              : data['makingTime'] as int?) ??
          0,
      orderStatus: data['orderStatus'] as String? ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'makingTime': makingTime,
      'orderStatus': orderStatus,
    };
  }

  // Helper method to get price as double for calculations
  double getPriceAsDouble() => double.tryParse(price) ?? 0.0;
}

class PaymentDetails {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final int amount;
  final String currency;
  final String status;
  final int amountRefunded;
  final String? refundStatus;
  final bool captured;
  final int paymentTimestamp;
  final bool testMode;

  PaymentDetails({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.amountRefunded,
    this.refundStatus,
    required this.captured,
    required this.paymentTimestamp,
    required this.testMode,
  });

  factory PaymentDetails.fromMap(Map<String, dynamic> data) {
    return PaymentDetails(
      razorpayPaymentId: data['razorpayPaymentId'] as String? ?? '',
      razorpayOrderId: data['razorpayOrderId'] as String? ?? '',
      amount: (data['amount'] is String
              ? int.tryParse(data['amount'] as String) ?? 0
              : data['amount'] as int?) ??
          0,
      currency: data['currency'] as String? ?? 'INR',
      status: data['status'] as String? ?? 'unknown',
      amountRefunded: (data['amountRefunded'] is String
              ? int.tryParse(data['amountRefunded'] as String) ?? 0
              : data['amountRefunded'] as int?) ??
          0,
      refundStatus: data['refundStatus'] as String?,
      captured: data['captured'] as bool? ?? false,
      paymentTimestamp: (data['paymentTimestamp'] is String
              ? int.tryParse(data['paymentTimestamp'] as String) ?? 0
              : data['paymentTimestamp'] as int?) ??
          0,
      testMode: data['testMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'amountRefunded': amountRefunded,
      'refundStatus': refundStatus,
      'captured': captured,
      'paymentTimestamp': paymentTimestamp,
      'testMode': testMode,
    };
  }
}
