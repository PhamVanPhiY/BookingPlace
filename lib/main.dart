import 'package:booking_place/view/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart'; // Nhập tệp firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra xem Firebase đã được khởi tạo chưa
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Nếu đã khởi tạo, ta bỏ qua bước này
    print('Firebase has already been initialized: $e');
  }

  // Khởi tạo Firebase App Check (đảm bảo chỉ được gọi một lần)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Booking Place',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white), color: Colors.white),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Màn hình splash
    );
  }
}
