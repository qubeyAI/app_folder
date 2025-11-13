import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pronounController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _nameController.text = prefs.getString('name') ?? '';
      _pronounController.text = prefs.getString('pronoun') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
    });
  }

  Future<void> _saveData() async {
    final username = _usernameController.text.trim();

    // ✅ Username validation (must include at least one number)
    final hasNumber = RegExp(r'[0-9]').hasMatch(username);
    if (!hasNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Username must include at least single number'),
          backgroundColor: Colors.grey[900],
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('pronoun', _pronounController.text.trim());
    await prefs.setString('bio', _bioController.text.trim());

    Navigator.pop(context, true); // ✅ Return true to refresh profile screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField('Username', _usernameController,
                'Enter your username (must include numbers)'),
            _buildTextField('Name', _nameController, 'Enter your full name'),
            _buildTextField('Pronoun', _pronounController, 'e.g., He/Him, She/Her, They/Them'),

            // 👇 Slightly reduced gap between Pronoun and Bio
            const SizedBox(height: 8),

            _buildTextField(
              'Bio',
              _bioController,
              'Tell something about yourself',
              maxLines: 3,
            ),

            const SizedBox(height: 25),

            // ✅ Blue or green "Save Changes" button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // change to Colors.greenAccent if you want
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saveData,
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        keyboardType:
        label == 'Username' ? TextInputType.text : TextInputType.name,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}