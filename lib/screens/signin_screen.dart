import 'package:qubeyai/custom_scaffold.dart';
import 'package:qubeyai/screens/signup_screen.dart';
import 'package:qubeyai/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_auth_methods.dart';
import 'home_screen.dart';
import 'package:qubeyai/screens/forgot_password_screen.dart';
import 'package:qubeyai/services/auth_service.dart';
import 'package:qubeyai/screens/home_screen.dart';
import 'package:qubeyai/screens/main_home_screen.dart';



import 'package:icons_plus/icons_plus.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberPassword = true;
  bool isLoading = false;

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
          flex: 5,
          child: Container(
            padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0)
              ),
            ),
            child: SingleChildScrollView(
              child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    Text(
                    "welcome back!!!",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w200,
                      color: lightColorScheme.shadow,
                    ),
                  ),
                  const SizedBox(
                      height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please enter Email";
                      }
                      return null;
                    },
                    controller:
                    emailController,
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 20),
                  TextFormField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "please enter Password";
                      }
                      return null;
                    },
                    controller:
                    passwordController,
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      hintText: "Enter Password",
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                  ),
                  const SizedBox(
                      height: 20),


                  Row(
                    children: [
                      Checkbox(
                        value: rememberPassword,
                        onChanged: (bool? value) {
                          setState(() {
                            rememberPassword = value!;
                          });
                        },
                        activeColor: lightColorScheme.shadow,
                      ),
                      const Text(
                        "Remember me",
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder:(context) => const ForgotPasswordScreen(),
                          ),
                      );
                    },
                    child: Text(
                      "  Forgot password?  ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lightColorScheme.shadow,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {

                          if (_formSignInKey.currentState!.validate() &&
                              rememberPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Processing Data'),
                              ),
                            );
                          } else if (!rememberPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "please agree to the processing of Personal Data"
                                    )
                                ));
                          }
                        },

                      child: InkWell(
                        onTap: () async {
                          if (!_formSignInKey.currentState!.validate()) return; // ✅ stop if validation fails


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
                            // Sign in user
                            UserCredential userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            User? user = FirebaseAuth.instance.currentUser;

                            // Check email verification
                            await user!.reload(); // Important: refresh user data
                            if (user.emailVerified) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please verify your email first!")),
                              );
                            }
                          } catch(e) {}



                          try {
                            UserCredential userCredential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim()
                            );

                            User? user = FirebaseAuth.instance.currentUser;

                            if (user != null && user.emailVerified) {
                              // Navigate to Home
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
                            } else {
                              // Show error and do NOT navigate
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please verify your email first!")),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message ?? "Sign in failed")),
                            );
                          }



                          try {
                            await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login successful")),
                            );
                            Navigator.pushReplacementNamed(context, '/home');
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message ?? "Login failed")),
                            );
                          }




                          try {
                            await FirebaseAuthMethods().signInWithEmail(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              context: context,
                            );

                            // ✅ Navigate only after Firebase sign-in succeeds
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainHomeScreen()),
                            );
                          }



                          on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message ?? "Error signing in")),
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
                            child: Center(
                              child: isLoading
                                  ? const
                              CircularProgressIndicator(color:
                              Colors.white, strokeWidth: 2,)
                                  : const Text(
                                  "sign in",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                                    ),
                                  ),
                                )
                            ]))

                  )
              ),
            ),
            const SizedBox(
              height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.7,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  child: Text("QubeyAI, missed your love & support!!!",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 0.7,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),


                ),
              ],
            ),
            const SizedBox(
              height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
            const SizedBox(
              height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don\'t have an account?  ",
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (e) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,),
        ],)
      );
  }
}

