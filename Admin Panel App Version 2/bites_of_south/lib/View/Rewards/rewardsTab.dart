import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.05; // 5% of screen width
    final double spacing = screenWidth * 0.03; // 3% for spacing

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
          stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading rewards',
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
                      'No rewards yet. Tap + to add one!',
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
                var reward = snapshot.data!.docs[index];
                return _buildRewardCard(
                  context,
                  reward,
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

  Widget _buildRewardCard(
    BuildContext context,
    QueryDocumentSnapshot reward,
    double screenWidth,
    double spacing,
  ) {
    final String name = reward['name'] as String;
    final int requiredPoints = reward['requiredPoints'] as int;
    final String discountType = reward['discountType'] as String;
    final int? discountValue = reward['discountValue'] as int?;
    final bool isCombo = reward['isCombo'] as bool;

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
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          // Reward Icon
          Container(
            padding: EdgeInsets.all(spacing),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star,
              color: Colors.green[700],
              size: screenWidth * 0.08,
            ),
          ),
          SizedBox(width: spacing),
          // Reward Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  discountType == 'free' ? 'Free Item' : '$discountValue% Off',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: spacing * 0.3),
                Text(
                  'Points: $requiredPoints',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
                if (isCombo) ...[
                  SizedBox(height: spacing * 0.3),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 0.5,
                      vertical: spacing * 0.2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Combo',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Delete Button
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red[400],
              size: screenWidth * 0.06,
            ),
            onPressed: () => _confirmDeleteReward(context, reward.id, name),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReward(
      BuildContext context, String rewardId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Delete Reward',
            style: TextStyle(color: Colors.green[800]),
          ),
          content: Text(
            'Are you sure you want to delete the reward "$name"?',
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
                _deleteReward(rewardId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reward "$name" deleted'),
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

  void _deleteReward(String rewardId) {
    FirebaseFirestore.instance.collection('rewards').doc(rewardId).delete();
  }
}
