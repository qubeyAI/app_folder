import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../user_data_provider.dart';




Future<int> updateStreak() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastSaved = prefs.getString('lastSavedDate');
  int currentStreak = prefs.getInt('streakDays') ?? 0;

  DateTime today = DateTime.now();
  DateTime todayDate = DateTime(today.year, today.month, today.day);

  if (lastSaved != null && lastSaved.isNotEmpty) {
    DateTime lastDate = DateTime.parse(lastSaved);
    if (todayDate.difference(lastDate).inDays == 1) {
      currentStreak++;
    } else if (todayDate.difference(lastDate).inDays > 1) {
      currentStreak = 1; // streak broken
    }
  } else {
    currentStreak = 1; // first save
  }

  await prefs.setInt('streakDays', currentStreak);
  await prefs.setString('lastSavedDate', todayDate.toIso8601String());

  return currentStreak;
}


