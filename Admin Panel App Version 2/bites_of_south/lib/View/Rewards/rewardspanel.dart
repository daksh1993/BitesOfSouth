import 'package:bites_of_south/View/Rewards/coupons.dart';
import 'package:bites_of_south/View/Rewards/offers.dart';
import 'package:bites_of_south/View/Rewards/rewardsTab.dart'; // Add this import
import 'package:bites_of_south/View/Rewards/rewardsAdd.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RewardScreen extends StatefulWidget {
  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  double? rupeesPerPoint;

  @override
  void initState() {
    super.initState();
    fetchRewardSettings();
  }

  // Fetch the previously saved value from Firestore
  Future<void> fetchRewardSettings() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('rewards')
        .get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        rupeesPerPoint =
            (doc.data() as Map<String, dynamic>)['rupeesPerPoint']?.toDouble();
      });
    }
  }

  // Update the Firestore value
  Future<void> updateRewardSettings(double value) async {
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('rewards')
        .set({'rupeesPerPoint': value});
    setState(() {
      rupeesPerPoint = value;
    });
  }

  // Show dialog with the previous value pre-filled
  void showSettingsDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: rupeesPerPoint != null ? rupeesPerPoint.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Rupees Per Point'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: 'Enter rupees per point'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? value = double.tryParse(controller.text);
                if (value != null) {
                  updateRewardSettings(value);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Changed from 2 to 3 tabs
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => showSettingsDialog(context),
                icon: Icon(Icons.settings))
          ],
          title: Text('Reward Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Offers'),
              Tab(text: 'Coupons'),
              Tab(text: 'Rewards'), // Added Rewards tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OffersTab(),
            CouponsTab(),
            RewardsTab(), // Added RewardsTab
          ],
        ),
        floatingActionButton: Builder(
          builder: (BuildContext fabContext) {
            return FloatingActionButton(
              onPressed: () => _showAddDialog(fabContext),
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final tabIndex = DefaultTabController.of(context)!.index;
    if (tabIndex == 0) {
      _showAddOfferDialog(context);
    } else if (tabIndex == 1) {
      _showAddCouponDialog(context);
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AddRewardScreen()));
    }
  }

  void _showAddOfferDialog(BuildContext context) {
    final nameController = TextEditingController();
    final multiplierController = TextEditingController();
    final minAmountController = TextEditingController();
    final usesTillValidController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Add New Offer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Offer Name'),
                ),
                TextField(
                  controller: multiplierController,
                  decoration: InputDecoration(
                      labelText: 'Points Multiplier (e.g., 2 for 2x)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minAmountController,
                  decoration:
                      InputDecoration(labelText: 'Min Order Amount (₹)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: usesTillValidController,
                  decoration:
                      InputDecoration(labelText: 'Uses Till Valid (per user)'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(startDate == null
                        ? 'Start Date: Not Set'
                        : 'Start: ${DateFormat.yMMMd().format(startDate!)}'),
                    TextButton(
                      onPressed: () async {
                        startDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        setDialogState(() {});
                      },
                      child: Text('Pick Start Date'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(endDate == null
                        ? 'End Date: Not Set'
                        : 'End: ${DateFormat.yMMMd().format(endDate!)}'),
                    TextButton(
                      onPressed: () async {
                        endDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        setDialogState(() {});
                      },
                      child: Text('Pick End Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    multiplierController.text.isEmpty ||
                    minAmountController.text.isEmpty ||
                    usesTillValidController.text.isEmpty ||
                    startDate == null ||
                    endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }
                FirebaseFirestore.instance.collection('offers').add({
                  'name': nameController.text,
                  'multiplier': double.parse(multiplierController.text),
                  'minAmount': double.parse(minAmountController.text),
                  'usesTillValid': int.parse(usesTillValidController.text),
                  'startDate': startDate,
                  'endDate': endDate,
                  'usedBy': {},
                });
                Navigator.pop(dialogContext);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCouponDialog(BuildContext context) {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final usesTillValidController = TextEditingController();
    String discountType = 'percent';
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Add New Coupon'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration:
                      InputDecoration(labelText: 'Coupon Code (e.g., DOSA20)'),
                ),
                DropdownButton<String>(
                  value: discountType,
                  items: [
                    DropdownMenuItem(
                        value: 'percent', child: Text('Percentage')),
                    DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => discountType = value!),
                ),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                      labelText: 'Discount Value (e.g., 20 for 20%)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: usesTillValidController,
                  decoration:
                      InputDecoration(labelText: 'Uses Till Valid (per user)'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(expiryDate == null
                        ? 'Expiry: Not Set'
                        : 'Expiry: ${DateFormat.yMMMd().format(expiryDate!)}'),
                    TextButton(
                      onPressed: () async {
                        expiryDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        setDialogState(() {});
                      },
                      child: Text('Pick Expiry Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (codeController.text.isEmpty ||
                    valueController.text.isEmpty ||
                    usesTillValidController.text.isEmpty ||
                    expiryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required')),
                  );
                  return;
                }
                FirebaseFirestore.instance.collection('coupons').add({
                  'code': codeController.text.toUpperCase(),
                  'discountType': discountType,
                  'value': double.parse(valueController.text),
                  'usesTillValid': int.parse(usesTillValidController.text),
                  'expiryDate': expiryDate,
                  'maxUses':
                      codeController.text.toUpperCase() == 'NEW99' ? null : 100,
                  'uses': 0,
                  'usedBy': {},
                });
                Navigator.pop(dialogContext);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
