import 'package:bite_of_south/View/menu.dart';
import 'package:bite_of_south/main.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                customContainer(
                  "Analysis",
                  3,
                  MyHomePage(title: "title"),
                ),
                customContainer("Rewards", 4, MyHomePage(title: "title")),
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
        height: MediaQuery.sizeOf(context).height / 5,
        width: MediaQuery.sizeOf(context).height / 5,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(name),
          Text(index.toString()),
        ]),
      ),
    );
  }
}
