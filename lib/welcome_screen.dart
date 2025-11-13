import 'package:qubeyai/custom_scaffold.dart';
import 'package:qubeyai/screens/signin_screen.dart';
import 'package:qubeyai/screens/signup_screen.dart';
import 'package:qubeyai/theme/theme.dart';
import 'package:qubeyai/welcome_button.dart';
import 'package:flutter/material.dart';

import 'theme/theme.dart';

class  WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
            child: Center(child: RichText(
          textAlign: TextAlign.center,
        text: const TextSpan(
          children:[
            TextSpan(
                text:
                "QubeyAI",
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.w900,
                )
            ),
                TextSpan(
                text:
                "\nSignup to take control of your goals!",
                style: TextStyle(
                  fontSize: 15.0,
                )
            ),
          ]
        )
      ),),
          ),),
       Flexible(
         flex: 1,
    child: Align(
      alignment: Alignment.bottomCenter,
    child: Column(
      children: [
     const Expanded(
         child: WelcomeButton(
           buttonText: "sign in",
           onTap: SignInScreen(),
           color: Colors.white,
           textColor: Colors.blue,
         ),
       ),
        Expanded(
          child: WelcomeButton(
            buttonText: "sign up",
            onTap: const SignUpScreen(),
            color: Colors.white,
            textColor: lightColorScheme.shadow,
          ),
        ),
      ],
    ),
          ),
       ),
        ],
      ),
    );
  }
}