import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Function to create the 'orders' collection with dummy data using auto-generated IDs
Future<void> createOrdersCollectionWithDummyData() async {
  final firestore = FirebaseFirestore.instance;
  final collectionRef = firestore.collection('orders');

  // Dummy data (2 orders) without pre-set userId
  List<OrdersModal> dummyOrders = [
    OrdersModal(
      id: null, // Will be set by Firestore
      items: [
        OrderItem(
          itemId: 'item_456',
          name: 'Paneer Butter Masala',
          quantity: 2,
          price: 250,
          makingTime: 15,
        ),
        OrderItem(
          itemId: 'item_789',
          name: 'Butter Naan',
          quantity: 3,
          price: 50,
          makingTime: 10,
        ),
      ],
      totalAmount: 650,
      orderStatus: 'Pending',
      pendingStatus: '0',
      paymentStatus: 'Paid',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      makingTime: 15,
      paymentDetails: PaymentDetails(
        razorpayPaymentId: 'pay_29QQoUBi66xm2f',
        razorpayOrderId: 'order_9A33XWu170gUtm',
        amount: 65000, // Amount in paise (650 INR)
        currency: 'INR',
        status: 'captured',
        amountRefunded: 0,
        refundStatus: null,
        captured: true,
        paymentTimestamp: DateTime.now().millisecondsSinceEpoch,
        testMode: true,
      ),
    ),
    OrdersModal(
      id: null, // Will be set by Firestore
      items: [
        OrderItem(
          itemId: 'item_101',
          name: 'Chicken Biryani',
          quantity: 1,
          price: 300,
          makingTime: 20,
        ),
      ],
      totalAmount: 300,
      orderStatus: 'Pending',
      pendingStatus: '0',
      paymentStatus: 'Paid',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      makingTime: 20,
      paymentDetails: PaymentDetails(
        razorpayPaymentId: 'pay_30RRpVBi77yn3g',
        razorpayOrderId: 'order_8B44YVu180hVun',
        amount: 30000, // Amount in paise (300 INR)
        currency: 'INR',
        status: 'captured',
        amountRefunded: 0,
        refundStatus: null,
        captured: true,
        paymentTimestamp: DateTime.now().millisecondsSinceEpoch,
        testMode: true,
      ),
    ),
  ];

  // Insert dummy data into Firestore with auto-generated IDs
  for (var order in dummyOrders) {
    DocumentReference docRef = await collectionRef.add(order.toMap());
    print('Order added with ID: ${docRef.id}');
  }
  print('Dummy orders added to Firestore');
}

class CookOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook Dashboard'),
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
                return OrderCard(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createOrdersCollectionWithDummyData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dummy orders added')),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final OrdersModal order;
  final double screenWidth;
  final double screenHeight;

  const OrderCard({
    required this.order,
    required this.screenWidth,
    required this.screenHeight,
    super.key, // Key is now required for uniqueness
  });

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String _pendingStatus;
  bool _is25Disabled = false;
  bool _is50Disabled = false;
  bool _is100Disabled = false;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    _pendingStatus = widget.order.pendingStatus ?? '0';
    _updateButtonStates();
  }

  void _updateButtonStates() {
    if (_pendingStatus == '25') {
      _is25Disabled = true;
    } else if (_pendingStatus == '50') {
      _is25Disabled = true;
      _is50Disabled = true;
    } else if (_pendingStatus == '100') {
      _is25Disabled = true;
      _is50Disabled = true;
      _is100Disabled = true;
    }
  }

  Future<void> _updatePendingStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id)
        .update({'pendingStatus': status});

    if (status == '100') {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'orderStatus': 'Completed'});
      isCompleted = true;
    }

    setState(() {
      _pendingStatus = status;
      _updateButtonStates();
    });
  }

  Future<void> _undoPendingStatus() async {
    String previousStatus = '0';
    if (_pendingStatus == '100') {
      previousStatus = '50';
    } else if (_pendingStatus == '50') {
      previousStatus = '25';
    } else if (_pendingStatus == '25') {
      previousStatus = '0';
    }

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id)
        .update({'pendingStatus': previousStatus});
    if (previousStatus == '0') {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'orderStatus': 'Pending'});
    } else if (previousStatus == '25' || previousStatus == '50') {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({'orderStatus': 'In Progress'});
    }

    setState(() {
      _pendingStatus = previousStatus;
      _is25Disabled = false;
      _is50Disabled = false;
      _is100Disabled = false;
      _updateButtonStates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: _pendingStatus == '0'
          ? Colors.white
          : _pendingStatus == '25'
              ? Colors.red.shade100
              : _pendingStatus == '50'
                  ? Colors.orange.shade100
                  : _pendingStatus == '100'
                      ? Colors.green.shade100
                      : Colors.white,
      margin: EdgeInsets.symmetric(vertical: widget.screenHeight * 0.01),
      child: Padding(
        padding: EdgeInsets.all(widget.screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.order.id ?? 'Unknown ID'}',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            ...widget.order.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.screenHeight * 0.005),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.name ?? 'Unknown Item'} x${item.quantity}',
                        style: TextStyle(fontSize: widget.screenWidth * 0.025),
                      ),
                      Text(
                        '₹${item.price * item.quantity}',
                        style: TextStyle(fontSize: widget.screenWidth * 0.025),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: widget.screenHeight * 0.01),
            Text(
              'Total: ₹${widget.order.totalAmount}',
              style: TextStyle(
                fontSize: widget.screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            Text(
              'Status: ${widget.order.orderStatus ?? 'Unknown'}',
              style: TextStyle(fontSize: widget.screenWidth * 0.025),
            ),
            SizedBox(height: widget.screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _is25Disabled ? null : () => _updatePendingStatus('25'),
                  child: const Text('25% Done'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    minimumSize: Size(
                        widget.screenWidth * 0.2, widget.screenHeight * 0.06),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _is50Disabled ? null : () => _updatePendingStatus('50'),
                  child: const Text('50% Done'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    minimumSize: Size(
                        widget.screenWidth * 0.2, widget.screenHeight * 0.06),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _is100Disabled ? null : () => _updatePendingStatus('100'),
                  child: const Text('Order Completed'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    minimumSize: Size(
                        widget.screenWidth * 0.25, widget.screenHeight * 0.06),
                  ),
                ),
              ],
            ),
            if (_pendingStatus != '0' && _pendingStatus.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: widget.screenHeight * 0.01),
                child: TextButton(
                  onPressed: _undoPendingStatus,
                  child: Text(
                    'Undo',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: widget.screenWidth * 0.025,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
