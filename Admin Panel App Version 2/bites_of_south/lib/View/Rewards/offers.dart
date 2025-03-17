
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OffersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('offers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No offers yet. Tap + to add one!'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var offer = snapshot.data!.docs[index];
            int totalUses = (offer['usedBy'] as Map)
                .values
                .fold(0, (sum, count) => sum + count as int);
            return ListTile(
              title: Text(offer['name']),
              subtitle: Text(
                '${offer['multiplier']}x points on orders above ₹${offer['minAmount']} - ${DateFormat.yMMMd().format(offer['startDate'].toDate())} to ${DateFormat.yMMMd().format(offer['endDate'].toDate())} (Valid for ${offer['usesTillValid']} uses/user, Total uses: $totalUses)',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteOffer(offer.id),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteOffer(String offerId) {
    FirebaseFirestore.instance.collection('offers').doc(offerId).delete();
  }
}