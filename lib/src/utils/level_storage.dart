import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLevelCompleted(int levelIdx) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('level_completed_$levelIdx', true);
}

Future<bool> isLevelCompleted(int levelIdx) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('level_completed_$levelIdx') ?? false;
}

Future<void> saveLastUpi(String upi) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_upi', upi);
}

Future<String?> loadLastUpi() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_upi');
}