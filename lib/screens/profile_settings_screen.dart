import 'package:qubeyai/screens/account_ownership_and_control_screen.dart';
import 'package:qubeyai/screens/analysis_screen.dart';
import 'package:qubeyai/screens/privacy_policy_screen.dart';
import 'package:qubeyai/screens/terms_and_conditions_screen.dart';
import 'package:qubeyai/subscription_screen.dart';
import 'package:qubeyai/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For http.post
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'ai_chat_screen.dart';
import 'package:qubeyai/screens/analysis_screen.dart';
import 'package:qubeyai/screens/alarm_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qubeyai/screens/edit_profile_screen.dart';
import 'package:qubeyai/screens/privacy_policy_screen.dart';
import 'package:qubeyai/screens/terms_and_conditions_screen.dart';






class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});



  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {

  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Section ---
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }

                      final prefs = snapshot.data!;
                      final username = prefs.getString('username') ?? 'User Name';
                      final name = prefs.getString('name') ?? '';
                      final pronoun = prefs.getString('pronoun') ?? '';
                      final bio = prefs.getString('bio') ?? 'No bio added yet.';

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 👤 Username Text
                          Text(
                            '@$username',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          if (pronoun.isNotEmpty)
                            Text(
                              pronoun,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 12),
                          // 📝 Bio Section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              bio,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // 🔘 Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ✏️ Edit Profile
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditProfileScreen(),
                                      ),
                                    );
                                    if (result == true) setState(() {});
                                  },
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 📤 Share Profile
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    final profileText = '''
🌟 Check out my profile!
Username: @$username
Name: $name
Pronoun: $pronoun
Bio: $bio

Download the app 👇
Qubey.AI — This app helps me a lot!!!
''';
                                    Share.share(profileText, subject: 'My Profile');
                                  },
                                  child: const Text(
                                    'Share Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // --- Settings Section ---
            const SizedBox(height: 50),
            const Text(
              "Settings",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),



            _buildSettingTile(icon: Icons.lock, title: "Privacy Policy", onTap: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),); },),

            _buildSettingTile(icon: Icons.description, title: "Terms & Conditions", onTap: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),); },),

            _buildSettingTile(icon: Icons.bar_chart_sharp, title: "AI.Analysis", onTap: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalysisScreen()),); }),


            // --- AI Tile ---
            _buildSettingTile(
              icon: Icons.smart_toy,
              title: "AI Suggestions",
              onTap: () {
                // Open full AI chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChatScreen()),
                );
              },
              trailingWidget: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ),

                   // --- "New" indicator below the tile ---
                     Padding(
                       padding: const EdgeInsets.only(left: 51, top: 1), // align with tile icon
                      child: Row(
                            children: [
                         Container(
                                width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                             color: Colors.blue,
                         shape: BoxShape.circle,
                        ),
                       ),
                        const SizedBox(width: 6),
                            const Text(
                           "New",
                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),






            const SizedBox(height: 30),
            const Divider(color: Colors.white24, thickness: 0.5),

            // --- Account Section ---
            const SizedBox(height: 10),
            const Text(
              "Account",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(icon: Icons.perm_identity_sharp, title: "Account ownership & control", onTap: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountOwnershipAndControlScreen()),);}),
            _buildSettingTile(icon: Icons.logout, title: "Log Out", onTap: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),); },),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String subtitle = "",
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: const TextStyle(color: Colors.white54))
          : null,
      trailing: trailingWidget ?? const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }
}






