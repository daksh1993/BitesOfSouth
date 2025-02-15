import 'package:bites_of_south/View/Menu/menu_management.dart';
import 'package:bites_of_south/View/Rewards/rewardspanel.dart';
import 'package:bites_of_south/View/UserProfile/profileScreen.dart';
import 'package:bites_of_south/main.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(), // Replace with your profile screen
                ),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customContainer(
                  "Menu",
                  1,
                  MenuManagementScreen(),
                ),
                customContainer("Order", 2, MyHomePage(title: "title")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customContainer(
                  "Analysis",
                  3,
                  MyHomePage(title: "title"),
                ),
                customContainer("Rewards", 4, RewardsPanel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customContainer(String name, int index, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      child: Container(
        color: Colors.amber,
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name),
            Text(index.toString()),
          ],
        ),
      ),
    );
  }
}
