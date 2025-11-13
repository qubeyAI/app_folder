import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountOwnershipAndControlScreen extends StatefulWidget {
  @override
  _AccountOwnershipAndControlScreenState createState() =>
      _AccountOwnershipAndControlScreenState();
}

class _AccountOwnershipAndControlScreenState
    extends State<AccountOwnershipAndControlScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently signed in.')));
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your email and password.')));
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      // Reauthenticate user with provided credentials
      final credential =
      EmailAuthProvider.credential(email: email, password: password);

      await user.reauthenticateWithCredential(credential);

      // Delete user from Firebase Auth (this also sign outs the user)
      await user.delete();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Your account has been deleted permanently.')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to delete account.';
      if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'requires-recent-login') {
        message =
        'Please sign in again before deleting your account for security reasons.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred.')));
    }

    setState(() {
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Account Ownership & Control'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
          'Delete Account',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Please read carefully before proceeding.',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey[300]),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 16, color: Colors.white, height: 1.4),
                  children: [
                  TextSpan(
                  text:
                  'Warning: Deleting your account is a permanent action and cannot be undone. '),
              TextSpan(
                  text:
                  'All data associated with this email account, including any stored information in our Firebase system,'
                      ' will be permanently removed!',
                  style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
              text:
              'Ensure that you have saved any important data before proceeding.'),
              TextSpan(
              text:
              'To confirm deletion, please provide your email and password below for authentication purposes.'),
          ],
        ),
      ),
    ),
    SizedBox(height: 32),
    TextField(
    controller: _emailController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(color: Colors.blueGrey[100]),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueGrey)),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent)),
    hintText: 'Enter your email used in this account',
    hintStyle: TextStyle(color: Colors.blueGrey[300]),
    fillColor: Colors.grey[900],
    filled: true,
    ),
    keyboardType: TextInputType.emailAddress,
    ),
    SizedBox(height: 20),
    TextField(
    controller: _passwordController,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(color: Colors.blueGrey[100]),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueGrey)),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent)),
    hintText: 'Enter your password',
    hintStyle: TextStyle(color: Colors.blueGrey[300]),
    fillColor: Colors.grey[900],
    filled: true,
    ),
    obscureText: true,
    ),
    SizedBox(height: 40),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: _isDeleting ? null : _deleteAccount,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent,
    padding: EdgeInsets.symmetric(vertical: 16),
    ),
    child: _isDeleting
    ? SizedBox(
    height: 24,
    width: 24,
    child: CircularProgressIndicator(
    valueColor:
    AlwaysStoppedAnimation<Color>(Colors.white)),
    )
        : Text(
    'Delete Account Permanently',
    style: TextStyle(fontSize: 18),
    ),
    ),
    ),
    SizedBox(height: 48),
    Divider(color: Colors.blueGrey[700]),
    SizedBox(height: 16),
    Text(
    'Additional Notices',
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.lightBlueAccent),
    ),
    SizedBox(height: 12),
    Text(
      '''
    • Account deletion is irreversible,

    • You will lose access to all services tied to this account,

    • Data removal may take a few moments to propagate through all services,

    • For assistance, contact support qubey.ai@gmail.com,
    
    ''',
    style: TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Colors.blueGrey[200]),
    ),
    SizedBox(height: 30),
    ],
    ),
    ),
    );
  }
}