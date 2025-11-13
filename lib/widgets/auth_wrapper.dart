import 'package:qubeyai/screens/main_home_screen.dart';
import 'package:qubeyai/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:qubeyai/screens/home_screen.dart';
import 'package:qubeyai/screens/signin_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:qubeyai/screens/home_screen.dart';
import 'package:qubeyai/subscription_screen.dart';
import 'package:qubeyai/welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();

    bool isSubscribed = prefs.getBool('isSubscribed') ?? false;
    String? expiryString = prefs.getString('subscriptionExpiry');

    bool valid = false;
    if (isSubscribed && expiryString != null) {
      DateTime expiry = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiry)) {
        valid = true; // subscription still active
      } else {
        // expired
        prefs.setBool('isSubscribed', false);
      }
    }

    setState(() {
      _isSubscribed = valid;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 1️⃣ Not logged in yet
    if (!auth.isLoggedIn) {
      return const WelcomeScreen();
    }

    // 2️⃣ Logged in but no valid subscription
    if (!_isSubscribed) {
      return const SubscriptionScreen();
    }

    // 3️⃣ Logged in and subscription active
    return MainHomeScreen();
  }
}