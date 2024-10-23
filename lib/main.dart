import 'package:booking_place/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart'; // Nhập tệp firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với các thông tin cấu hình từ firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Dùng cấu hình cho nền tảng hiện tại
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Booking Place',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Màn hình splash
    );
  }
}
