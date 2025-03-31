import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Analysis"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          "Analysis Screen",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
