import 'package:qubeyai/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../user_data_provider.dart';
import '../streak_manager.dart';
import '../level_model.dart';
import '../level_map_screen.dart';
import 'profile_settings_screen.dart';
import 'package:qubeyai/level_detail_screen.dart';
import 'package:qubeyai/src/utils/level_storage.dart';
import 'package:qubeyai/src/utils/glowing_path_animator.dart';
import 'analysis_screen.dart';



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import '../user_data_provider.dart';
import '../streak_manager.dart';
import '../level_model.dart';
import '../level_map_screen.dart';
import 'profile_settings_screen.dart';
import 'package:qubeyai/level_detail_screen.dart';
import 'package:qubeyai/src/utils/level_storage.dart';
import 'package:qubeyai/src/utils/glowing_path_animator.dart'; // ✨ Add this import

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {


  bool isPanelOpen = false;
  String goalName = "My Savings Goal";
  int streakDays = 0;
  late ConfettiController _confettiController;
  late AnimationController _pulseController;

  // ✨ Added variables for glowing path
  Offset? travelStart;
  Offset? travelEnd;
  bool showGlowAnimation = false;
  int? currentLevelIndex;

  @override
  void initState() {
    super.initState();
    NotificationService.cancelAllNotifications();
    _loadGoal();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    NotificationService.rescheduleAllNotifications();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      goalName = prefs.getString('goalName') ?? "My Savings Goal";
      streakDays = prefs.getInt('streakDays') ?? 0;
    });
  }

  Future<void> _editGoalName() async {
    final prefs = await SharedPreferences.getInstance();
    TextEditingController controller = TextEditingController(text: goalName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Set Your Goal",
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter your goal name",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await prefs.setString('goalName', controller.text.trim());
                setState(() => goalName = controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Save",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool> _isLevelUnlocked(int idx) async {
    if (idx == 0) return true; // Level 1 always unlocked
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('level_${idx + 1}_unlocked') ?? false;
  }

  Future<int> _getUserDaysFromWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('goal_days') ?? 30;
  }

  // ✨ New: Show dialog asking to continue to next level
  Future<void> _showNextLevelDialog(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Level Completed!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Do you want to travel to the next level?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Stay Here",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              Navigator.pop(context);
              _startTravelAnimation(index);
            },
            child: const Text("Next Level",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ✨ Start glowing travel animation manually
  void _startTravelAnimation(int index) {
    setState(() {
      final baseY = 200.0 + (index * 150);
      travelStart = Offset(MediaQuery.of(context).size.width / 2, baseY);
      travelEnd = Offset(MediaQuery.of(context).size.width / 2, baseY + 150);
      currentLevelIndex = index;
      showGlowAnimation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.of(context).size.width * 0.6;
    final userData = Provider.of<UserDataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => setState(() => isPanelOpen = true),
              ),
              const Text(
                "QubeyAI",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              Consumer<UserDataProvider>(
                builder: (context, userData, child) {
                  return ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(CurvedAnimation(
                        parent: _pulseController, curve: Curves.easeInOut)),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.orangeAccent, size: 28),
                          const SizedBox(width: 2),
                          Text(
                            userData.streakDays.toString(),
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(9),
            child: SizedBox(
                height: 2, width: double.infinity, child: ColoredBox(color: Colors.white12)),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: _editGoalName,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(goalName,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    const Icon(Icons.edit, color: Colors.white70, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Upcoming Levels",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 10),
              Container(height: 2, color: Colors.white54, width: double.infinity),
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<int>(
                    future: _getUserDaysFromWalkthrough(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final int userDays = snapshot.data!;
                      final int totalLevels = (userDays / 5).ceil();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        itemCount: totalLevels,
                        itemBuilder: (context, index) {
                          return FutureBuilder<bool>(
                            future: _isLevelUnlocked(index),
                            builder: (context, snap) {
                              final isUnlocked = snap.data ?? (index == 0);

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: isUnlocked
                                        ? () async {
                                      final level = Level(
                                        idx: index + 1,
                                        amount: (index + 1) * 10,
                                      );

                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              LevelDetailScreen(level: level),
                                        ),
                                      );

                                      // ✅ If level completed, ask if user wants next level
                                      if (result == true &&
                                          index < totalLevels - 1) {
                                        _showNextLevelDialog(index);
                                      } else {
                                        setState(() {});
                                      }
                                    }
                                        : null,
                                    child: AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 400),
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isUnlocked
                                            ? const LinearGradient(
                                          colors: [
                                            Colors.greenAccent,
                                            Colors.teal
                                          ],
                                          begin: Alignment.topLeft,
                                          end:
                                          Alignment.bottomRight,
                                        )
                                            : const LinearGradient(
                                          colors: [
                                            Colors.grey,
                                            Colors.black26
                                          ],
                                          begin: Alignment.topLeft,
                                          end:
                                          Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isUnlocked
                                                ? Colors.tealAccent
                                                : Colors.black26,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Level ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (index < totalLevels - 1)
                                    Container(
                                      width: 6,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isUnlocked
                                              ? [
                                            Colors.tealAccent,
                                            Colors.greenAccent
                                          ]
                                              : [
                                            Colors.grey.shade700,
                                            Colors.grey.shade500
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }),
              )
            ]),
          ),



          // ✨ Glowing travel animation overlay
          if (showGlowAnimation && travelStart != null && travelEnd != null)
            GlowingPathAnimator(
              start: travelStart!,
              end: travelEnd!,
              onFinish: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(
                    'level_${(currentLevelIndex ?? 0) + 2}_unlocked', true);

                setState(() {
                  showGlowAnimation = false;
                });
              },
            ),

          if (isPanelOpen)
            GestureDetector(
              onTap: () => setState(() => isPanelOpen = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isPanelOpen ? 0 : -panelWidth,
            child: SizedBox(
              width: panelWidth,
              child: const ProfileSettingsScreen(),
            ),
          ),
        ],
      ),
    );
  }
}






