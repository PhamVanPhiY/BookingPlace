import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.amber],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp)),
      child: ListView(
        children: [
          Image.asset("assets/images/logo.png"),
          const Text(
            "Hi friend ,\n welcome back",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.pink,
                letterSpacing: 3.0),
          ),
        ],
      ),
    ));
  }
}
