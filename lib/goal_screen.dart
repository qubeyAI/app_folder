import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../level_model.dart';
import 'level_map_screen.dart';

class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _amountController = TextEditingController();
  int _durationDays = 100;
  String _frequency = 'daily';

  List<Level> generateLevels(int totalAmount, int totalDays, String frequency) {
    List<Level> levels = [];
    int n = frequency == 'daily'
        ? totalDays
        : frequency == 'weekly'
        ? (totalDays ~/ 7)
        : (totalDays ~/ 30);
    int baseAmount = totalAmount ~/ n;
    int remainder = totalAmount % n;

    for (int _i = 0; _i < n; _i++) {
      int amt = baseAmount + (remainder > 0 ? 1 : 0);
      if (remainder > 0) remainder--;
      levels.add(Level(idx: _i + 1, amount: amt));
    }
    return levels;
  }

  void _startJourney() async {
    int amount = int.tryParse(_amountController.text) ?? 0;
    List<Level> levels = generateLevels(amount, _durationDays, _frequency);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('levels', levelsToJson(levels) as String);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LevelMapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Your Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target Amount (₹)'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _frequency,
              items: ['daily', 'weekly', 'monthly']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _frequency = val!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startJourney,
              child: Text('Start Saving Journey'),
            ),
          ],
        ),
      ),
    );
  }
}
