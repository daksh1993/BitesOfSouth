import 'package:bites_of_south/View/Analysis/analysisScreen.dart';
import 'package:bites_of_south/View/Menu/menu_management.dart';
import 'package:bites_of_south/View/Orders/ordersAdmin.dart';
import 'package:bites_of_south/View/Rewards/rewardspanel.dart';
import 'package:bites_of_south/View/UserProfile/profileScreen.dart';
import 'package:bites_of_south/View/addAdmin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<int, Widget> _screens = {
    1: const MenuManagementScreen(),
    2: OrderAdmin(),
    3: AnalysisScreen(),
    4: RewardScreen(),
  };
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? userRole;
  bool isLoadingUserData = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? docId = prefs.getString('docId');
      if (docId == null) {
        if (mounted) {
          setState(() {
            errorMessage = "User ID not found";
            isLoadingUserData = false;
          });
        }
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(docId).get();
      if (!userDoc.exists) {
        if (mounted) {
          setState(() {
            errorMessage = "User data not found";
            isLoadingUserData = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          userName = userDoc.get('name') as String? ?? 'Unknown';
          userRole = userDoc.get('role') as String? ?? 'Unknown';
          isLoadingUserData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading user data: $e";
          isLoadingUserData = false;
        });
      }
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // Responsive sizing using MediaQuery
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;
        final double minDimension =
            screenWidth < screenHeight ? screenWidth : screenHeight;
        final double padding =
            (minDimension * 0.04).clamp(8.0, 24.0); // 4% capped
        final double spacing =
            (minDimension * 0.03).clamp(6.0, 16.0); // 3% capped
        final bool isLargeScreen = screenWidth > 600;
        final bool isLandscape = orientation == Orientation.landscape;

        // Dynamic grid settings
        final int crossAxisCount =
            isLargeScreen ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2);
        final double childAspectRatio = isLandscape ? 1.2 : 1.0;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Admin Dashboard",
              style: TextStyle(
                fontSize: (minDimension * 0.06).clamp(18.0, 24.0),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green[700],
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: (minDimension * 0.07).clamp(24.0, 32.0),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                tooltip: 'Profile',
              ),
              IconButton(
                icon: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: (minDimension * 0.07).clamp(24.0, 32.0),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddAdminScreen()),
                  );
                },
                tooltip: 'Add New Admin',
              ),
            ],
          ),
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[50]!, Colors.white],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing),
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: (minDimension * 0.08).clamp(24.0, 32.0),
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: spacing * 0.5),
                    isLoadingUserData
                        ? CircularProgressIndicator(color: Colors.green)
                        : errorMessage != null
                            ? Text(
                                errorMessage!,
                                style: TextStyle(
                                  fontSize:
                                      (minDimension * 0.045).clamp(14.0, 18.0),
                                  color: Colors.red,
                                ),
                              )
                            : Row(
                                children: [
                                  Text(
                                    userName ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: (minDimension * 0.05)
                                          .clamp(16.0, 20.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  SizedBox(width: spacing * 0.5),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: spacing * 0.5,
                                      vertical: spacing * 0.2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      userRole ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: (minDimension * 0.04)
                                            .clamp(12.0, 16.0),
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    SizedBox(height: spacing * 0.5),
                    Text(
                      "Manage your restaurant with ease",
                      style: TextStyle(
                        fontSize: (minDimension * 0.045).clamp(14.0, 18.0),
                        color: Colors.green[600],
                      ),
                    ),
                    SizedBox(height: spacing * 2),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio,
                        children: [
                          customContainer("Menu", 1, minDimension, spacing),
                          customContainer("Orders", 2, minDimension, spacing),
                          customContainer("Analysis", 3, minDimension, spacing),
                          customContainer("Rewards", 4, minDimension, spacing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget customContainer(
      String name, int index, double minDimension, double spacing) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                _screens[index] ??
                const Scaffold(body: Center(child: Text("Page not found"))),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular((minDimension * 0.03).clamp(10.0, 15.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(index),
              size: (minDimension * 0.15).clamp(40.0, 60.0),
              color: Colors.green[700],
            ),
            SizedBox(height: spacing * 0.5),
            Text(
              name,
              style: TextStyle(
                fontSize: (minDimension * 0.09).clamp(16.0, 22.0),
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 1:
        return Icons.restaurant_menu;
      case 2:
        return Icons.shopping_cart;
      case 3:
        return Icons.analytics;
      case 4:
        return Icons.card_giftcard;
      default:
        return Icons.error;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
