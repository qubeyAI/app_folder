import 'package:flutter/material.dart';

class WalletService extends ChangeNotifier {
  double _balance = 0.0;

  double get balance => _balance;

  void addMoney(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void spendMoney(double amount) {
    _balance -= amount;
    notifyListeners();
  }
}