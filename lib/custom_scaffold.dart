import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children:[
          Image.asset("assets/welcome screen/Untitled design.png",
            width: double.infinity,
            height: double.infinity,),
          SafeArea(
            child: child!,
          ),
        ],
      ),
    );
  }
}
