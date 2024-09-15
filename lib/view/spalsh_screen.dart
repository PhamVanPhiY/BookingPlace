import 'dart:async';
import 'package:booking_place/view/login_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Get.to(LoginScreen());
    });
  }

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/splash.png"),
              const Padding(
                padding: EdgeInsets.only(top: 18),
                child: Text(
                  "Welcome to Airbnb Clone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
