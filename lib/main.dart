import 'package:qubeyai/firebase_options.dart';
import 'package:qubeyai/screens/signin_screen.dart';
import 'package:qubeyai/screens/signup_screen.dart';
import 'package:qubeyai/notification_service.dart';
import 'package:qubeyai/theme/theme.dart';
import 'package:qubeyai/user_data_provider.dart';
import 'package:qubeyai/subscription_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:qubeyai/screens/landing_wrapper.dart';
import 'package:qubeyai/screens/home_screen.dart';
import 'package:qubeyai/services/auth_service.dart';
import 'package:qubeyai/widgets/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:qubeyai/services/wallet_service.dart';
import '../widgets/balance_card.dart';
import 'services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qubeyai/screens/profile_settings_screen.dart';
import 'package:qubeyai/screens/main_home_screen.dart';
import 'goal_screen.dart';
import 'notification_service.dart';
import 'package:qubeyai/screens/alarm_screen.dart';
import 'package:qubeyai/screens/analysis_screen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:alarm/alarm.dart';





Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
      DefaultFirebaseOptions.currentPlatform,
  );


  await NotificationService.initialize();
  await NotificationService.checkAndScheduleIfInactive();
  await NotificationService.recordAppOpened();
  await Alarm.init();


  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool('seenWalkthrough') ?? false;
  bool subscribed = prefs.getBool('isSubscribed') ?? false; // 🔹 added

  Widget firstScreen;

  if (!seen) {
    prefs.setBool('seenWalkthrough', true);
    firstScreen = const WelcomeScreen(); // 🔹 show walkthrough first
  } else if (!subscribed) {
    firstScreen = const SubscriptionScreen(); // 🔹 show subscription after walkthrough/signup
  } else {
    firstScreen = const AuthWrapper(); // 🔹 if subscribed, normal flow
  }




  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => WalletService()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: const MyApp(),
    ),
  );





}
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthService>(context);
    final wallet =
        Provider.of<WalletService>(context);

    return MaterialApp(
      home: AuthWrapper(), // controls which screen shows
      title:"QubeyAI",
      theme: lightMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/signin': (c) => const SignInScreen(),
        '/signup': (c) => const SignUpScreen(),
        '/home': (c) => HomeScreen(),
        '/subscription': (c) => const SubscriptionScreen(),
        '/profile_settings' :  (c) => const ProfileSettingsScreen(),
        '/main_home': (c) => MainHomeScreen(),
     },
    );
  }
}