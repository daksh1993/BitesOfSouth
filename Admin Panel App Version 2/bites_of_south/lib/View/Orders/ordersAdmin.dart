import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderAdmin extends StatefulWidget {
  @override
  _OrderAdminState createState() => _OrderAdminState();
}

class _OrderAdminState extends State<OrderAdmin> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRange;

  void _updateDateRange(DateTime? start, DateTime? end, {String? range}) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedRange = range;
    });
  }

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
      body: Column(
        children: [
          DateRangeSection(
            screenWidth: screenWidth,
            onDateRangeChanged: _updateDateRange,
            selectedRange: _selectedRange,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildOrdersStream(),
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
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildOrdersStream() {
    Query query = FirebaseFirestore.instance.collection('orders');

    if (_startDate != null) {
      final startMillis = _startDate!.millisecondsSinceEpoch;
      query = query.where('timestamp', isGreaterThanOrEqualTo: startMillis);
    }

    if (_endDate != null) {
      final endMillis =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
              .millisecondsSinceEpoch;
      query = query.where('timestamp', isLessThanOrEqualTo: endMillis);
    }

    query = query.orderBy('timestamp', descending: true);
    return query.snapshots();
  }
}

class DateRangeSection extends StatefulWidget {
  final double screenWidth;
  final Function(DateTime?, DateTime?, {String? range}) onDateRangeChanged;
  final String? selectedRange;

  const DateRangeSection({
    required this.screenWidth,
    required this.onDateRangeChanged,
    this.selectedRange,
  });

  @override
  _DateRangeSectionState createState() => _DateRangeSectionState();
}

class _DateRangeSectionState extends State<DateRangeSection> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      widget.onDateRangeChanged(_startDate, _endDate);
    }
  }

  void _selectPredefinedRange(String range) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Past 2 Days':
        start = now.subtract(Duration(days: 2));
        break;
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
    widget.onDateRangeChanged(start, end, range: range);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenWidth * 0.03,
        horizontal: widget.screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: widget.screenWidth * 0.03),
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenWidth * 0.03),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRangeChip('Today'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('Past 2 Days'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Week'),
                SizedBox(width: widget.screenWidth * 0.02),
                _buildRangeChip('This Month'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.screenWidth * 0.03,
          horizontal: widget.screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: widget.screenWidth * 0.045, color: Colors.green),
            SizedBox(width: widget.screenWidth * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.035,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date == null
                        ? 'Select Date'
                        : '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeChip(String range) {
    final isSelected = widget.selectedRange == range;
    return GestureDetector(
      onTap: () => _selectPredefinedRange(range),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.04,
          vertical: widget.screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: widget.screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// AdminOrderCard remains unchanged
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
                          .update({
                        'orderStatus': 'Completed',
                        'pendingStatus': '100'
                      });
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
