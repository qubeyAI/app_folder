import 'package:flutter/material.dart';

class UpiSavingsScreen extends StatelessWidget {
  const UpiSavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("UPI Savings")),
      body: const Center(
        child: Text("Redirecting to UPI savings soon...",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}




