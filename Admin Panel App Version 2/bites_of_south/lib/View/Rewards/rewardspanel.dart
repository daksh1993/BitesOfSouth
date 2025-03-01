import 'package:flutter/material.dart';

class RewardsPanel extends StatefulWidget {
  const RewardsPanel({super.key});

  @override
  State<RewardsPanel> createState() => _RewardsPanelState();
}

class _RewardsPanelState extends State<RewardsPanel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards"),
      ),
      body: const Center(
   
        child: Text("Rewards Panel"),
      ),
    );
  }
}
