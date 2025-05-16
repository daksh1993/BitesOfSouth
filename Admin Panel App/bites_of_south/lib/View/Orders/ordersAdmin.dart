import 'package:bites_of_south/Modal/orders_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class OrderAdmin extends StatefulWidget {
  const OrderAdmin({super.key});

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
    final spacing = screenWidth * 0.03;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Text(
          'Admin Order View',
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            DateRangeSection(
              screenWidth: screenWidth,
              onDateRangeChanged: _updateDateRange,
              selectedRange: _selectedRange,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _buildOrdersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Lottie.asset(
                          'assets/loadin.json',
                          width: screenWidth * 0.2,
                          height: screenHeight * 0.2,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading orders',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: screenWidth * 0.15,
                              color: Colors.green[300],
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.green[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final orders = snapshot.data!.docs
                        .map((doc) => OrdersModal.fromFirestore(doc))
                        .toList();

                    return ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: spacing),
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
    super.key,
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
    final spacing = widget.screenWidth * 0.03;
    return Container(
      padding: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Orders by Date',
            style: TextStyle(
              fontSize: widget.screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context: context,
                  label: 'From',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDateButton(
                  context: context,
                  label: 'To',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRangeChip('Today'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('Past 2 Days'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('This Week'),
                SizedBox(width: spacing * 0.5),
                _buildRangeChip('This Month'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.green[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(
          vertical: widget.screenWidth * 0.03,
          horizontal: widget.screenWidth * 0.03,
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: widget.screenWidth * 0.045,
            color: Colors.green[700],
          ),
          SizedBox(width: widget.screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.035,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  date == null
                      ? 'Select Date'
                      : DateFormat.yMMMd().format(date),
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
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
          vertical: widget.screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.green[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.green[200]!,
          ),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green[800],
            fontSize: widget.screenWidth * 0.035,
            fontWeight: FontWeight.w600,
          ),
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
    final spacing = screenWidth * 0.03;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: spacing * 0.5),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      color: Colors.green[700],
                      size: screenWidth * 0.06,
                    ),
                    SizedBox(width: spacing * 0.5),
                    Text(
                      'Order #${order.id?.substring(0, 8) ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing * 0.5,
                    vertical: spacing * 0.2,
                  ),
                  decoration: BoxDecoration(
                    color: order.orderStatus == 'Completed'
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.orderStatus ?? 'Unknown',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: order.orderStatus == 'Completed'
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            ...order.items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing * 0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.name ?? 'Unknown Item'} x${item.quantity}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Text(
                        '₹${(item.getPriceAsDouble() * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment: ${order.paymentStatus ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: order.paymentStatus == 'Pending'
                        ? Colors.red[600]
                        : Colors.green[600],
                  ),
                ),
                if (order.paymentStatus == 'Pending' &&
                    order.orderStatus == 'Completed')
                  ElevatedButton(
                    onPressed: () => _confirmPaymentStatus(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing,
                        vertical: spacing * 0.5,
                      ),
                    ),
                    child: Text(
                      'Mark as Paid',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: spacing),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showStatusDialog(context, order),
                child: Text(
                  order.orderStatus != 'Completed'
                      ? 'Mark as Completed'
                      : 'Revert to Pending',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPaymentStatus(BuildContext context, OrdersModal order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Update Payment Status',
            style: TextStyle(color: Colors.green[800]),
          ),
          content: Text(
            'Mark order #${order.id?.substring(0, 8) ?? 'Unknown'} as Paid?',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(order.id)
                    .update({'paymentStatus': 'Paid'});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment status updated to Paid'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, OrdersModal order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            order.orderStatus != 'Completed'
                ? 'Complete Order'
                : 'Revert Order',
            style: TextStyle(color: Colors.green[800]),
          ),
          content: Text(
            order.orderStatus != 'Completed'
                ? 'Mark order #${order.id?.substring(0, 8) ?? 'Unknown'} as Completed?'
                : 'Revert order #${order.id?.substring(0, 8) ?? 'Unknown'} to Pending?',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: order.orderStatus != 'Completed'
                    ? Colors.green
                    : Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (order.orderStatus != 'Completed') {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({
                    'orderStatus': 'Completed',
                    'pendingStatus': '100',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order marked as Completed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(order.id)
                      .update({
                    'orderStatus': 'Pending',
                    'pendingStatus': '0',
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order reverted to Pending'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(
                order.orderStatus != 'Completed' ? 'Complete' : 'Revert',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
