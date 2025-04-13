import 'package:bites_of_south/View/Rewards/coupons.dart';
import 'package:bites_of_south/View/Rewards/rewardsTab.dart';
import 'package:bites_of_south/View/Rewards/rewardsAdd.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

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
      if (mounted) {
        setState(() {
          rupeesPerPoint =
              (doc.data() as Map<String, dynamic>)['rupeesPerPoint']
                  ?.toDouble();
        });
      }
    }
  }

  Future<void> updateRewardSettings(double value) async {
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('rewards')
        .set({'rupeesPerPoint': value});
    if (mounted) {
      setState(() {
        rupeesPerPoint = value;
      });
    }
  }

  void showSettingsDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth * 0.03;
    TextEditingController controller = TextEditingController(
      text: rupeesPerPoint != null ? rupeesPerPoint.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Rupees Per Point',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: spacing),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter rupees per point (e.g., 0.5)',
                filled: true,
                fillColor: Colors.green[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                prefixIcon: Icon(Icons.currency_rupee, color: Colors.green),
              ),
            ),
            SizedBox(height: spacing * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(width: spacing),
                ElevatedButton(
                  onPressed: () {
                    double? value = double.tryParse(controller.text);
                    if (value != null && value > 0) {
                      updateRewardSettings(value);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Rupees per point updated'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Enter a valid positive number'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green[700],
          elevation: 0,
          title: Text(
            'Reward Management',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.green[700],
              child: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.green[100],
                labelStyle: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'Coupons'),
                  Tab(text: 'Rewards'),
                ],
              ),
            ),
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
              backgroundColor: Colors.green,
              child: Icon(Icons.add, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    final tabIndex = DefaultTabController.of(context).index;
    if (tabIndex == 0) {
      _showAddCouponBottomSheet(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddRewardScreen()),
      );
    }
  }

  void _showAddCouponBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = screenWidth * 0.03;
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    final usesTillValidController = TextEditingController();
    String discountType = 'percent';
    DateTime? expiryDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Coupon',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Coupon Code (e.g., DOSA20)',
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: Icon(Icons.local_offer, color: Colors.green),
                  ),
                ),
                SizedBox(height: spacing),
                DropdownButtonFormField<String>(
                  value: discountType,
                  decoration: InputDecoration(
                    labelText: 'Discount Type',
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: Icon(Icons.discount, color: Colors.green),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'percent',
                      child: Text('Percentage'),
                    ),
                    DropdownMenuItem(
                      value: 'flat',
                      child: Text('Flat Amount'),
                    ),
                  ],
                  onChanged: (value) => setState(() => discountType = value!),
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: 'Discount Value (e.g., 20 for 20%)',
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: Icon(
                      discountType == 'percent'
                          ? Icons.percent
                          : Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: usesTillValidController,
                  decoration: InputDecoration(
                    labelText: 'Uses Till Valid (per user)',
                    filled: true,
                    fillColor: Colors.green[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    prefixIcon: Icon(Icons.repeat, color: Colors.green),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: spacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expiryDate == null
                          ? 'Expiry: Not Set'
                          : 'Expiry: ${DateFormat.yMMMd().format(expiryDate!)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.green[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        expiryDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                          builder: (context, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.green,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        setState(() {});
                      },
                      child: Text(
                        'Pick Expiry Date',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: spacing),
                    ElevatedButton(
                      onPressed: () {
                        if (codeController.text.isEmpty ||
                            valueController.text.isEmpty ||
                            usesTillValidController.text.isEmpty ||
                            expiryDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('All fields are required'),
                              backgroundColor: Colors.red[400],
                            ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Coupon added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Save'),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
