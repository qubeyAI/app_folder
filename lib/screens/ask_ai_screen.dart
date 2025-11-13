import 'package:flutter/material.dart';

class AskAiScreen extends StatelessWidget {
  const AskAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ask AI")),
      body: const Center(
        child: Text("Chat with Qubey.AI Coming Soon",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}