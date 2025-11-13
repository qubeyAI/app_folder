import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoneyHabitScreen extends StatefulWidget {
  final String userEmail;
  const MoneyHabitScreen({super.key, required this.userEmail});

  @override
  State<MoneyHabitScreen> createState() => _MoneyHabitScreenState();
}

class _MoneyHabitScreenState extends State<MoneyHabitScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _type = "Expense";

  final String sheetUrl = "https://script.google.com/macros/s/AKfycbwT-xppyljT34LlyddRVGlnSGZQHcVwkvczV9R1cQ1eOdtx31EOuWHQMsP3vyyKdf5g/exec"; // paste it here

  Future<void> addTransaction() async {
    final body = {
      "amount": _amountController.text,
      "category": _categoryController.text,
      "type": _type,
      "notes": _noteController.text,
      "user": widget.userEmail
    };

    final res = await http.post(
      Uri.parse(sheetUrl),
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved successfully ✅")),
      );
      _amountController.clear();
      _categoryController.clear();
      _noteController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💸 Money Habit Coach")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            DropdownButton<String>(
              value: _type,
              items: ["Expense", "Saving"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: addTransaction,
                child: const Text("Add Transaction"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
