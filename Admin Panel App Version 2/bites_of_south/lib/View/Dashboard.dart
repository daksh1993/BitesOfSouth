import 'package:bites_of_south/View/Menu/menu_management.dart';
import 'package:bites_of_south/View/Rewards/rewardspanel.dart';
import 'package:bites_of_south/View/UserProfile/profileScreen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<int, Widget> _screens = {
    1: const MenuManagementScreen(),
    2: Scaffold(), // Replace with actual Order Screen
    3: Scaffold(), // Replace with actual Analysis Screen
    4: const RewardsPanel(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              spacing: MediaQuery.sizeOf(context).width * 0.029,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customContainer("Menu", 1),
                customContainer("Order", 2),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              spacing: MediaQuery.sizeOf(context).width * 0.029,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customContainer("Analysis", 3),
                customContainer("Rewards", 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customContainer(String name, int index) {
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
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(index),
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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
