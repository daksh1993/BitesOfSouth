import 'package:bites_of_south/View/Rewards/coupons.dart';
import 'package:bites_of_south/View/Rewards/offers.dart';
import 'package:bites_of_south/View/Rewards/rewardsTab.dart';
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

  Future<void> updateRewardSettings(double value) async {
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('rewards')
        .set({'rupeesPerPoint': value});
    setState(() {
      rupeesPerPoint = value;
    });
  }

  void showSettingsDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: rupeesPerPoint != null ? rupeesPerPoint.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set Rupees Per Point',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter rupees per point',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reward Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Coupons'),
              Tab(text: 'Rewards'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CouponsTab(),
            RewardsTab(),
          ],
        ),
        floatingActionButton: Builder(
          builder: (BuildContext fabContext) {
            return FloatingActionButton(
              onPressed: () => _showAddBottomSheet(fabContext),
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    final tabIndex = DefaultTabController.of(context)!.index;
    if (tabIndex == 0) {
      _showAddCouponBottomSheet(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddRewardScreen()),
      );
    }
  }

  // void _showAddOfferBottomSheet(BuildContext context) {
  //   final nameController = TextEditingController();
  //   final multiplierController = TextEditingController();
  //   final minAmountController = TextEditingController();
  //   final usesTillValidController = TextEditingController();
  //   DateTime? startDate;
  //   DateTime? endDate;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //           left: 16,
  //           right: 16,
  //           top: 16,
  //         ),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text('Add New Offer',
  //                   style: Theme.of(context).textTheme.titleLarge),
  //               SizedBox(height: 16),
  //               TextField(
  //                 controller: nameController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Offer Name',
  //                   border: OutlineInputBorder(),
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               TextField(
  //                 controller: multiplierController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Points Multiplier (e.g., 2 for 2x)',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 keyboardType: TextInputType.number,
  //               ),
  //               SizedBox(height: 8),
  //               TextField(
  //                 controller: minAmountController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Min Order Amount (₹)',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 keyboardType: TextInputType.number,
  //               ),
  //               SizedBox(height: 8),
  //               TextField(
  //                 controller: usesTillValidController,
  //                 decoration: InputDecoration(
  //                   labelText: 'Uses Till Valid (per user)',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 keyboardType: TextInputType.number,
  //               ),
  //               SizedBox(height: 8),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(startDate == null
  //                       ? 'Start Date: Not Set'
  //                       : 'Start: ${DateFormat.yMMMd().format(startDate!)}'),
  //                   TextButton(
  //                     onPressed: () async {
  //                       startDate = await showDatePicker(
  //                         context: context,
  //                         initialDate: DateTime.now(),
  //                         firstDate: DateTime.now(),
  //                         lastDate: DateTime(2026),
  //                       );
  //                       setState(() {});
  //                     },
  //                     child: Text('Pick Start Date'),
  //                   ),
  //                 ],
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(endDate == null
  //                       ? 'End Date: Not Set'
  //                       : 'End: ${DateFormat.yMMMd().format(endDate!)}'),
  //                   TextButton(
  //                     onPressed: () async {
  //                       endDate = await showDatePicker(
  //                         context: context,
  //                         initialDate: DateTime.now(),
  //                         firstDate: DateTime.now(),
  //                         lastDate: DateTime(2026),
  //                       );
  //                       setState(() {});
  //                     },
  //                     child: Text('Pick End Date'),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(height: 16),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     child: Text('Cancel'),
  //                   ),
  //                   SizedBox(width: 8),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       if (nameController.text.isEmpty ||
  //                           multiplierController.text.isEmpty ||
  //                           minAmountController.text.isEmpty ||
  //                           usesTillValidController.text.isEmpty ||
  //                           startDate == null ||
  //                           endDate == null) {
  //                         ScaffoldMessenger.of(context).showSnackBar(
  //                           SnackBar(content: Text('All fields are required')),
  //                         );
  //                         return;
  //                       }
  //                       FirebaseFirestore.instance.collection('offers').add({
  //                         'name': nameController.text,
  //                         'multiplier': double.parse(multiplierController.text),
  //                         'minAmount': double.parse(minAmountController.text),
  //                         'usesTillValid':
  //                             int.parse(usesTillValidController.text),
  //                         'startDate': startDate,
  //                         'endDate': endDate,
  //                         'usedBy': {},
  //                       });
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text('Save'),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showAddCouponBottomSheet(BuildContext context) {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final usesTillValidController = TextEditingController();
    String discountType = 'percent';
    DateTime? expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add New Coupon',
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Coupon Code (e.g., DOSA20)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: discountType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'percent', child: Text('Percentage')),
                    DropdownMenuItem(value: 'flat', child: Text('Flat Amount')),
                  ],
                  onChanged: (value) => setState(() => discountType = value!),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Discount Value (e.g., 20 for 20%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: usesTillValidController,
                  decoration: InputDecoration(
                    labelText: 'Uses Till Valid (per user)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(expiryDate == null
                        ? 'Expiry: Not Set'
                        : 'Expiry: ${DateFormat.yMMMd().format(expiryDate!)}'),
                    TextButton(
                      onPressed: () async {
                        expiryDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        setState(() {});
                      },
                      child: Text('Pick Expiry Date'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
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
                          'usesTillValid':
                              int.parse(usesTillValidController.text),
                          'expiryDate': expiryDate,
                          'maxUses':
                              codeController.text.toUpperCase() == 'NEW99'
                                  ? null
                                  : 100,
                          'uses': 0,
                          'usedBy': {},
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
