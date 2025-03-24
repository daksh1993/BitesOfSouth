import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Function to create the 'orders' collection with dummy data using auto-generated IDs
// Future<void> createOrdersCollectionWithDummyData() async {
//   final firestore = FirebaseFirestore.instance;
//   final collectionRef = firestore.collection('orders');

//   // Dummy data (2 orders) without pre-set userId
//   List<OrdersModal> dummyOrders = [
//     OrdersModal(
//       id: null, // Will be set by Firestore
//       items: [
//         OrderItem(
//           itemId: 'item_456',
//           name: 'Paneer Butter Masala',
//           quantity: 2,
//           price: 250,
//           makingTime: 15,
//         ),
//         OrderItem(
//           itemId: 'item_789',
//           name: 'Butter Naan',
//           quantity: 3,
//           price: 50,
//           makingTime: 10,
//         ),
//       ],
//       totalAmount: 650,
//       orderStatus: 'Pending',
//       pendingStatus: '0',
//       paymentStatus: 'Paid',
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//       makingTime: 15,
//       paymentDetails: PaymentDetails(
//         razorpayPaymentId: 'pay_29QQoUBi66xm2f',
//         razorpayOrderId: 'order_9A33XWu170gUtm',
//         amount: 65000, // Amount in paise (650 INR)
//         currency: 'INR',
//         status: 'captured',
//         amountRefunded: 0,
//         refundStatus: null,
//         captured: true,
//         paymentTimestamp: DateTime.now().millisecondsSinceEpoch,
//         testMode: true,
//       ),
//     ),
//     OrdersModal(
//       id: null, // Will be set by Firestore
//       items: [
//         OrderItem(
//           itemId: 'item_101',
//           name: 'Chicken Biryani',
//           quantity: 1,
//           price: 300,
//           makingTime: 20,
//         ),
//       ],
//       totalAmount: 300,
//       orderStatus: 'Pending',
//       pendingStatus: '0',
//       paymentStatus: 'Paid',
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//       makingTime: 20,
//       paymentDetails: PaymentDetails(
//         razorpayPaymentId: 'pay_30RRpVBi77yn3g',
//         razorpayOrderId: 'order_8B44YVu180hVun',
//         amount: 30000, // Amount in paise (300 INR)
//         currency: 'INR',
//         status: 'captured',
//         amountRefunded: 0,
//         refundStatus: null,
//         captured: true,
//         paymentTimestamp: DateTime.now().millisecondsSinceEpoch,
//         testMode: true,
//       ),
//     ),
//   ];

//   // Insert dummy data into Firestore with auto-generated IDs
//   for (var order in dummyOrders) {
//     DocumentReference docRef = await collectionRef.add(order.toMap());
//     print('Order added with ID: ${docRef.id}');
//   }
//   print('Dummy orders added to Firestore');
// }

// // Cook Dashboard Screen (with update functionality)

// Admin Order View Screen (read-only with payment status button)
class OrderAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Admin Order View'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No orders found'));
            }

            final orders = snapshot.data!.docs
                .map((doc) => OrdersModal.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return AdminOrderCard(
                  key: ValueKey(order.id), // Unique key based on order ID
                  order: order,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// AdminOrderCard for Admin View (read-only with payment status button)
class AdminOrderCard extends StatelessWidget {
  final OrdersModal order;
  final double screenWidth;
  final double screenHeight;

  const AdminOrderCard({
    required this.order,
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(order.orderStatus != 'Completed'
                  ? 'Complete Order'
                  : 'Revert Payment'),
              content: Text(order.orderStatus != 'Completed'
                  ? 'Do you want to mark this order as completed?'
                  : 'Do you want to revert the payment status to Pending?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (order.orderStatus != 'Completed') {
                      // Mark order as completed
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({'orderStatus': 'Completed'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Order marked as completed')),
                      );
                    } else {
                      // Revert payment status to Pending
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({'paymentStatus': 'Pending'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Payment status reverted to Pending')),
                      );
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 5,
        color: order.paymentStatus == 'Pending'
            ? Colors.red.shade100
            : Colors.green.shade100, // Color based on payment status
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${order.id ?? 'Unknown ID'}',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              ...order.items.map((item) => Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.name ?? 'Unknown Item'} x${item.quantity}',
                          style: TextStyle(fontSize: screenWidth * 0.025),
                        ),
                        Text(
                          '₹${item.price * item.quantity}',
                          style: TextStyle(fontSize: screenWidth * 0.025),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Total: ₹${order.totalAmount}',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Order Status: ${order.orderStatus ?? 'Unknown'}',
                style: TextStyle(fontSize: screenWidth * 0.025),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: ElevatedButton(
                  onPressed: (order.paymentStatus == 'Pending' &&
                          order.orderStatus == 'Completed')
                      ? () async {
                          final newStatus = order.paymentStatus == 'Pending'
                              ? 'Paid'
                              : 'Pending';

                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(order.id)
                              .update({'paymentStatus': newStatus});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payment status updated to $newStatus',
                              ),
                            ),
                          );
                        }
                      : null, // Enable only if payment is pending and order is completed
                  child: Text(
                    order.paymentStatus == 'Pending'
                        ? 'Payment Pending'
                        : 'Amount Paid: ₹${order.totalAmount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.paymentStatus == 'Pending'
                        ? Colors.red
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
