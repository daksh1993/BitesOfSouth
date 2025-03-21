import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RewardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rewards yet. Tap + to add one!'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var reward = snapshot.data!.docs[index];
            return ListTile(
              title: Text(reward['name']),
              subtitle: Text(
                'Points: ${reward['requiredPoints']} - ${reward['discountType'] == 'free' ? 'Free Item' : '${reward['discountValue']}% Off'} ${reward['isCombo'] ? '(Combo)' : ''}',
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteReward(reward.id),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteReward(String rewardId) {
    FirebaseFirestore.instance.collection('rewards').doc(rewardId).delete();
  }
}
