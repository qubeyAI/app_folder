import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qubeyai/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 Added for user ID




class UserDataProvider with ChangeNotifier {

  final FirestoreService _firestoreService = FirestoreService();

  // 🔹 Local variables
  String _savingName = '';
  int _amount = 0;
  String _currency = 'USD';
  DateTime? _targetDate;
  String? _savingFrequency;

  int _levelsCount = 0;
  double _perLevelAmount = 0;

  int _streakDays = 0;
  DateTime? _lastOpenedDate;

  // 🔹 Firestore references 🟢 Added
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔹 Getters
  String get savingName => _savingName;
  int get amount => _amount;
  String get currency => _currency;
  DateTime? get targetDate => _targetDate;
  String? get savingFrequency => _savingFrequency;
  int get levelsCount => _levelsCount;
  double get perLevelAmount => _perLevelAmount;
  int get streakDays => _streakDays;

  UserDataProvider() {
    _loadUserData(); // local streaks
    _loadUserDataFromFirestore(); // 🟢 fetch from backend
  }

  // 🔹 Setting data
  void setSavingDetails({
    required String savingName,
    required int amount,
    required String currency,
    DateTime? targetDate,
    String? savingFrequency,
    required int streakDays,
  }) {
    _savingName = savingName;
    _amount = amount;
    _currency = currency;
    _targetDate = targetDate;
    _savingFrequency = savingFrequency ?? 'daily';
    _streakDays = streakDays;


    _generateLevels();

    _firestoreService.saveGoalName(savingName);

    notifyListeners();

    _saveUserDataToFirestore(); // 🟢 Save to backend
  }

  // 🔹 Auto-generate levels
  void _generateLevels() {
    if (_amount <= 0) {
      _levelsCount = 0;
      _perLevelAmount = 0;
      return;
    }

    switch (_savingFrequency?.toLowerCase()) {
      case 'daily':
        _levelsCount = 100;
        break;
      case 'weekly':
        _levelsCount = 52;
        break;
      case 'monthly':
        _levelsCount = 12;
        break;
      case 'quarterly':
        _levelsCount = 4;
        break;
      default:
        _levelsCount = 10;
    }

    _perLevelAmount = _levelsCount > 0 ? _amount / _levelsCount : 0.0;
  }

  // 🔹 Local streak logic
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _streakDays = prefs.getInt('streakDays') ?? 0;
    final lastOpenedString = prefs.getString('lastOpenedDate');
    if (lastOpenedString != null) {
      _lastOpenedDate = DateFormat('yyyy-MM-dd').parse(lastOpenedString);
    }
    _updateStreak();
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);

    if (_lastOpenedDate == null) {
      _streakDays = 1;
    } else {
      final lastOpenedString = DateFormat('yyyy-MM-dd').format(_lastOpenedDate!);
      if (lastOpenedString != todayString) {
        final diff = today.difference(_lastOpenedDate!).inDays;
        if (diff == 1) {
          _streakDays += 1;
        } else {
          _streakDays = 1;
        }
      }
    }

    await prefs.setInt('streakDays', _streakDays);
    await prefs.setString('lastOpenedDate', todayString);
    _lastOpenedDate = today;
    notifyListeners();
  }

  // 🟢 Firestore: Save user data
  Future<void> _saveUserDataToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'savingName': _savingName,
      'amount': _amount,
      'currency': _currency,
      'targetDate': _targetDate?.toIso8601String(),
      'savingFrequency': _savingFrequency,
      'levelsCount': _levelsCount,
      'perLevelAmount': _perLevelAmount,
      'streakDays': _streakDays,
    }, SetOptions(merge: true));
  }

  // 🟢 Firestore: Load user data
  Future<void> _loadUserDataFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _savingName = data['savingName'] ?? '';
      _amount = data['amount'] ?? 0;
      _currency = data['currency'] ?? 'USD';
      _targetDate = data['targetDate'] != null
          ? DateTime.parse(data['targetDate'])
          : null;
      _savingFrequency = data['savingFrequency'] ?? 'daily';
      _levelsCount = data['levelsCount'] ?? 0;
      _perLevelAmount = (data['perLevelAmount'] ?? 0).toDouble();
      _streakDays = data['streakDays'] ?? 0;

      notifyListeners();
    }
  }
}





