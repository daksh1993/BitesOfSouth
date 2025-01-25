import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Bites Of South',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: Image.asset(
          "assets/logo.png",
          fit: BoxFit.fill,
        ),
        backgroundColor: const Color.fromARGB(255, 72, 194, 109),
      ),
      body: const Center(
        child: Text(
          'Welcome to the homepage!',
        ),
      ),
    );
  }
}
