import 'dart:async';
import 'package:booking_place/view/login_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
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
                colors: [Colors.white, Colors.white],
                begin: FractionalOffset(0, 0),
                end: FractionalOffset(1, 0),
                stops: [0, 1],
                tileMode: TileMode.clamp)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Đặt BoxFit.cover để ảnh chiếm toàn bộ màn hình
              Expanded(
                child: Image.asset(
                  "assets/images/logomain.png",
                  fit: BoxFit
                      .cover, // Đây là phần quan trọng để ảnh chiếm hết màn hình
                  width: double.infinity, // Đảm bảo ảnh chiếm hết chiều rộng
                  height: double.infinity, // Đảm bảo ảnh chiếm hết chiều cao
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
