import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CouponsTab extends StatelessWidget {
  const CouponsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.05;
    final double spacing = screenWidth * 0.03;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[50]!, Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/loadin.json',
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading coupons',
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
                      Icons.card_giftcard,
                      size: screenWidth * 0.15,
                      color: Colors.green[300],
                    ),
                    SizedBox(height: spacing),
                    Text(
                      'No coupons yet. Tap + to add one!',
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
            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (context, index) => SizedBox(height: spacing),
              itemBuilder: (context, index) {
                var coupon = snapshot.data!.docs[index];
                int totalUses = (coupon['usedBy'] as Map<dynamic, dynamic>)
                    .values
                    .fold(0, (sum, count) => sum + (count as int));
                return _buildCouponCard(
                  context,
                  coupon,
                  totalUses,
                  screenWidth,
                  spacing,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context,
    QueryDocumentSnapshot coupon,
    int totalUses,
    double screenWidth,
    double spacing,
  ) {
    final String code = coupon['code'] as String;
    final String discountType = coupon['discountType'] as String;
    final num value =
        coupon['value'] as num; // Handle as num to support double/int
    final int usesTillValid = coupon['usesTillValid'] as int;
    final DateTime expiryDate = coupon['expiryDate'].toDate();
    final String formattedExpiry = DateFormat.yMMMd().format(expiryDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(spacing * 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_offer,
              color: Colors.green[700],
              size: screenWidth * 0.08,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  discountType == 'percent'
                      ? '${value.toStringAsFixed(0)}% off'
                      : '₹${value.toStringAsFixed(0)} off',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: spacing * 0.3),
                Text(
                  'Expires: $formattedExpiry',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: spacing * 0.3),
                Text(
                  'Valid for $usesTillValid uses/user',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: spacing * 0.3),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red[400],
              size: screenWidth * 0.06,
            ),
            onPressed: () => _confirmDeleteCoupon(context, coupon.id, code),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCoupon(
      BuildContext context, String couponId, String code) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Coupon',
            style: TextStyle(color: Colors.green[800]),
          ),
          content: Text(
            'Are you sure you want to delete the coupon "$code"?',
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
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
                backgroundColor: Colors.red[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _deleteCoupon(couponId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Coupon "$code" deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCoupon(String couponId) {
    FirebaseFirestore.instance.collection('coupons').doc(couponId).delete();
  }
}
