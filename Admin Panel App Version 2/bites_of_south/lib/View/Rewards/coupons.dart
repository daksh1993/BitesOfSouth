

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('coupons').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No coupons yet. Tap + to add one!'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var coupon = snapshot.data!.docs[index];
            int totalUses = (coupon['usedBy'] as Map)
                .values
                .fold(0, (sum, count) => sum + count as int);
            return ListTile(
              title: Text(coupon['code']),
              subtitle: Text(
                '${coupon['discountType'] == 'percent' ? '${coupon['value']}%' : '₹${coupon['value']}'} off - Expires: ${DateFormat.yMMMd().format(coupon['expiryDate'].toDate())} (Valid for ${coupon['usesTillValid']} uses/user, Total uses: $totalUses)',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteCoupon(coupon.id),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCoupon(String couponId) {
    FirebaseFirestore.instance.collection('coupons').doc(couponId).delete();
  }
}
