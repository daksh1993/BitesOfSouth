import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModal {
  final String? id; // Auto-generated ID from Firestore
  final List<OrderItem> items;
  final int totalAmount;
  final String? orderStatus;
  final String? pendingStatus;
  final String? paymentStatus;
  final int timestamp;
  final int makingTime;
  final PaymentDetails paymentDetails;

  OrdersModal({
    this.id, // Nullable, set by Firestore
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.pendingStatus,
    required this.paymentStatus,
    required this.timestamp,
    required this.makingTime,
    required this.paymentDetails,
  });

  factory OrdersModal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Firestore document data is null');
    }
    return OrdersModal(
      id: doc.id, // Use the auto-generated document ID
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: data['totalAmount'] as int? ?? 0,
      orderStatus: data['orderStatus'] as String? ?? 'Unknown',
      pendingStatus: data['pendingStatus'] as String? ?? '0',
      paymentStatus: data['paymentStatus'] as String? ?? 'Unknown',
      timestamp: data['timestamp'] as int? ?? 0,
      makingTime: data['makingTime'] as int? ?? 0,
      paymentDetails: PaymentDetails.fromMap(
          data['paymentDetails'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Do not include 'id' here; Firestore will generate it
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'pendingStatus': pendingStatus,
      'paymentStatus': paymentStatus,
      'timestamp': timestamp,
      'makingTime': makingTime,
      'paymentDetails': paymentDetails.toMap(),
    };
  }
}

class OrderItem {
  final String itemId;
  final String? name;
  final int quantity;
  final int price;
  final int makingTime;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.makingTime,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unknown Item',
      quantity: data['quantity'] as int? ?? 0,
      price: data['price'] as int? ?? 0,
      makingTime: data['makingTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'makingTime': makingTime,
    };
  }
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
      amount: data['amount'] as int? ?? 0,
      currency: data['currency'] as String? ?? 'INR',
      status: data['status'] as String? ?? 'unknown',
      amountRefunded: data['amountRefunded'] as int? ?? 0,
      refundStatus: data['refundStatus'] as String?,
      captured: data['captured'] as bool? ?? false,
      paymentTimestamp: data['paymentTimestamp'] as int? ?? 0,
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
