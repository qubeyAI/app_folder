import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_detail_screen.dart';
import '../level_model.dart';


class LevelMapScreen extends StatefulWidget {
  @override
  _LevelMapScreenState createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<Level> levels = [];



  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('levels');
    if (data != null) {
      setState(() {
        levels = levelsFromJson(data as List);
      });
    }
  }

  void _updateLevels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('levels', levelsToJson(levels) as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level Map')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            return GestureDetector(
              onTap: level.status == 'available'
                  ? () async {
                bool completed = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>
                      LevelDetailScreen(
                          level: level,
                      )),
                );
                if (completed == true) {
                  setState(() {
                    level.status = 'completed' as LevelStatus;
                    if (index + 1 < levels.length) {
                      levels[index + 1].status = 'available' as LevelStatus;
                    }
                  });
                  _updateLevels();
                }
              }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: level.status == 'completed'
                      ? Colors.green
                      : level.status == 'available'
                      ? Colors.yellow
                      : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
                child: Center(
                  child: Text(
                    "${level.idx}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: level.status == 'completed' ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
