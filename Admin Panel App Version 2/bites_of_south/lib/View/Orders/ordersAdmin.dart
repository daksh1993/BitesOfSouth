import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                  key: ValueKey(order.id),
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (order.orderStatus != 'Completed') {
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(order.id)
                          .update({'orderStatus': 'Completed'});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Order marked as completed')),
                      );
                    } else {
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
                    Navigator.of(context).pop();
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
            : Colors.green.shade100,
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
                          '₹${(item.getPriceAsDouble() * item.quantity).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: screenWidth * 0.025),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
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
                      : null,
                  child: Text(
                    order.paymentStatus == 'Pending'
                        ? 'Payment Pending'
                        : 'Amount Paid: ₹${order.totalAmount.toStringAsFixed(2)}',
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
