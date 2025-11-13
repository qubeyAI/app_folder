import 'package:qubeyai/custom_scaffold.dart';
import 'package:qubeyai/screens/privacy_policy_screen.dart';
import 'package:qubeyai/screens/terms_and_conditions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:qubeyai/screens/signin_screen.dart';
import 'package:qubeyai/theme/theme.dart';
import 'package:qubeyai/widgets/custom_scaffold.dart';
import '../services/firebase_auth_methods.dart';
import 'home_screen.dart';
import 'package:qubeyai/screens/home_screen.dart';
import 'package:qubeyai/screens/main_home_screen.dart';
import 'package:url_launcher/url_launcher.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;


  bool agreePersonalData = true;
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  bool isValidPassword(String password) {
    return password.length >= 6;
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started!!!',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w200,
                          color: lightColorScheme.shadow,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // full name
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // email
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        controller:
                        emailController,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // password
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        controller:
                        passwordController,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'the given data.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate() &&
                                agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Processing Data'),
                                ),
                              );
                            } else if (!agreePersonalData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please agree to the processing of the given data')),
                              );
                            }
                          },
                          child: InkWell(
                            onTap: () async {
                              if (!_formSignupKey.currentState!.validate()) return;// ✅ stop if validation fails


                              if (!isValidEmail(emailController.text.trim())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Please enter a valid email address")),
                                );
                                return;
                              }

                              if (!isValidPassword(passwordController.text.trim())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Password must be at least 6 characters")),
                                );
                                return;
                              }


                              try {
                                // Sign up user
                                UserCredential userCredential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text);

                                // Check if the user is new
                                bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

                                if (isNewUser) {
                                  // Show walkthrough
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => HomeScreen()),
                                  );
                                } else {
                                  // Go directly to home (rare for sign up)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => MainHomeScreen()),
                                  );
                                }
                              } catch (e) {}




                              try {
                                UserCredential userCredential = await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim()
                                );

                                // Send verification email
                                await userCredential.user!.sendEmailVerification();

                                // Show a message to the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Verification email sent. Check your inbox!")),
                                );
                              } on FirebaseAuthException catch (e) {
                                // Handle errors like email already in use
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? "Signup failed")),
                                );
                              }




                              try {
                                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Account created successfully")),
                                );

                                // Navigate to HomeScreen
                                Navigator.pushReplacementNamed(context, '/home');
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? "Signup failed")),
                                );
                              }


                              try {
                                await FirebaseAuthMethods().signUpWithEmail(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  context: context,
                                );

                                // ✅ Navigate only after Firebase sign-in succeeds
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainHomeScreen()),
                                );
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? "Error signing up")),
                                );
                              }
                            },
                            borderRadius:
                            BorderRadius.circular(10),
                            child: Container(
                              padding: const
                              EdgeInsets.symmetric(horizontal: 40,vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  "sign up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      // sign up divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  '''
your signup makes QubeyAI complete!
By signing up, you agree to our''',
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const TermsAndConditionsScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Terms,',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (e) => const PrivacyPolicyScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Privacy policy.',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),


                            ],
                          ),


                      Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                  ),



                      const SizedBox(
                        height: 20.0,
                      ),
                      // sign up social media logo


                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.shadow,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                  ],
                  ),
                ),
              ),
            ),
    ),
    ],
      ),
    );
  }
}