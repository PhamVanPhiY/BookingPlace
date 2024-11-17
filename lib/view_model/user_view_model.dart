import 'dart:async';
import 'dart:io';

import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/user_model.dart';
import 'package:booking_place/view/guestSreens/account_screen.dart';
import 'package:booking_place/view/guest_home_screen.dart';
import 'package:booking_place/view/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserViewModel {
  UserModel userModel = UserModel();

  // Phương thức đăng ký người dùng
  signUp(email, password, firstName, lastName, city, country, bio,
      imageFileOfUser) async {
    try {
      // Thực hiện đăng ký người dùng (tạo tài khoản)
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((result) async {
        String currentUserID = result.user!.uid;

        // Gửi liên kết xác thực đến email của người dùng
        await result.user!.sendEmailVerification();

        // Hiển thị thông báo gửi email xác nhận
        Get.snackbar(
          "Email Sent",
          "A verification link has been sent to your email. Please check your inbox.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(
              seconds: 5), // Tăng thời gian hiển thị snackbar lên 5 giây
          borderRadius: 8,
          margin: EdgeInsets.all(10),
          icon: Icon(Icons.mail, color: Colors.white),
        );

        // Kiểm tra trạng thái xác thực email định kỳ
        checkEmailVerificationPeriodically(currentUserID, email, firstName,
            lastName, city, country, bio, imageFileOfUser);
      });
    } catch (e) {
      // Kiểm tra lỗi "email already in use"
      if (e.toString().contains('email address is already in use')) {
        Get.snackbar(
          "Email already in use",
          "The email address you entered is already registered. Please use a different one.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          borderRadius: 8,
          margin: EdgeInsets.all(10),
          icon: Icon(Icons.error, color: Colors.white),
        );
      } else {
        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          borderRadius: 8,
          margin: EdgeInsets.all(10),
          icon: Icon(Icons.error, color: Colors.white),
        );
      }
    }
  }

// Hàm kiểm tra trạng thái xác thực email
  // Hàm kiểm tra trạng thái xác thực email
  // Hàm kiểm tra trạng thái xác thực email
  checkEmailVerificationPeriodically(
      String currentUserID,
      String email,
      String firstName,
      String lastName,
      String city,
      String country,
      String bio,
      File imageFileOfUser) {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser!
            .reload(); // Reload lại thông tin người dùng
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          // Nếu email đã được xác thực, dừng kiểm tra
          timer.cancel();

          // Cập nhật thông tin người dùng vào AppConstants
          AppConstants.currentUser.id = currentUserID;
          AppConstants.currentUser.firstName = firstName;
          AppConstants.currentUser.lastName = lastName;
          AppConstants.currentUser.city = city;
          AppConstants.currentUser.country = country;
          AppConstants.currentUser.bio = bio;
          AppConstants.currentUser.email = email;

          // Lưu thông tin người dùng vào Firestore
          await saveUserToFirestore(
                  bio, city, country, email, firstName, lastName, currentUserID)
              .whenComplete(() async {
            // Thêm hình ảnh người dùng vào Firebase Storage
            await addImageToFirebaseStorage(imageFileOfUser, currentUserID);
          });

          // Thông báo tạo tài khoản thành công ngay sau khi xác thực email thành công
          Get.snackbar(
            "Congratulations",
            "Your account has been created successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
            borderRadius: 8,
            margin: EdgeInsets.all(10),
            icon: Icon(Icons.check_circle, color: Colors.white),
          );

          // Chuyển hướng đến trang chủ sau khi thông báo
          await Future.delayed(
              Duration(seconds: 3)); // Đảm bảo snackbar kịp hiển thị
          Get.to(GuestHomeScreen());
        } else {
          // Nếu email chưa được xác thực, yêu cầu người dùng kiểm tra email
          Get.snackbar(
            "Email Not Verified",
            "Please verify your email by clicking the link sent to your inbox.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 5),
            borderRadius: 8,
            margin: EdgeInsets.all(10),
            icon: Icon(Icons.error, color: Colors.white),
          );

          // Cung cấp tùy chọn gửi lại email xác thực
          Get.defaultDialog(
            title: "Resend Verification Email",
            middleText: "Would you like to resend the verification link?",
            onCancel: () {
              // Nếu không muốn gửi lại email xác thực
              timer.cancel();
            },
            onConfirm: () async {
              // Gửi lại liên kết xác thực
              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
              Get.snackbar(
                "Email Sent",
                "A new verification link has been sent to your email.",
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 3),
                borderRadius: 8,
                margin: EdgeInsets.all(10),
                icon: Icon(Icons.mail, color: Colors.white),
              );

              // Kiểm tra lại xác thực email sau khi gửi lại liên kết
              Timer(Duration(seconds: 60), () async {
                await FirebaseAuth.instance.currentUser!
                    .reload(); // Reload lại thông tin người dùng sau khi gửi lại email
                if (FirebaseAuth.instance.currentUser!.emailVerified) {
                  // Nếu email đã được xác thực, có thể cho phép tiếp tục
                  Get.snackbar(
                    "Email Verified",
                    "Your email has been verified. You can now proceed.",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                    borderRadius: 8,
                    margin: EdgeInsets.all(10),
                    icon: Icon(Icons.check_circle, color: Colors.white),
                  );
                  // Tiến hành chuyển hướng hoặc tiếp tục các thao tác
                } else {
                  Get.snackbar(
                    "Email Not Verified",
                    "The email is still not verified. Please check your inbox.",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                    borderRadius: 8,
                    margin: EdgeInsets.all(10),
                    icon: Icon(Icons.error, color: Colors.white),
                  );
                }
              });
            },
          );
        }
      }
    });
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserToFirestore(
      bio, city, country, email, firstName, lastName, id) async {
    Map<String, dynamic> dataMap = {
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "isHost": false,
      "myPostingIDs": [],
      "savePostingIDs": [],
      "earnings": 0
    };

    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }

  // Thêm hình ảnh của người dùng vào Firebase Storage
  addImageToFirebaseStorage(File imageFileOfUser, currentUserID) async {
    Reference referenceStorage = FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(currentUserID)
        .child(currentUserID + ".png");

    await referenceStorage.putFile(imageFileOfUser).whenComplete(() {
      AppConstants.currentUser.displayImage =
          MemoryImage(imageFileOfUser.readAsBytesSync());
    });
  }

  // Phương thức đăng nhập người dùng
  login(email, password) async {
    // Hiển thị snackbar đang kiểm tra thông tin đăng nhập
    Get.snackbar(
      "Please wait",
      "Checking your credentials...",
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      borderRadius: 8,
      margin: EdgeInsets.all(10),
      icon: Icon(Icons.lock, color: Colors.white),
    );

    try {
      // Đăng nhập trực tiếp với email và mật khẩu
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String currentUserID = result.user!.uid;
      AppConstants.currentUser.id = currentUserID;
      await getUserInfoFromFirestore(currentUserID);
      await getImageFromStorage(currentUserID);
      await AppConstants.currentUser.getMyPostingsFromFirestore();

      // Thông báo đăng nhập thành công
      Get.snackbar(
        "Logged-In",
        "You are logged-in successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      // Chuyển hướng đến trang chính
      Get.to(GuestHomeScreen());
    } catch (e) {
      // Xử lý lỗi FirebaseAuthException
      if (e is FirebaseAuthException) {
        print("Error code: ${e.code}"); // In ra mã lỗi để kiểm tra

        if (e.code == 'user-not-found') {
          // Nếu email không tồn tại trong Firebase
          Get.snackbar(
            "Email Not Found",
            "The email you entered is not registered. Please try again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            borderRadius: 8,
            margin: EdgeInsets.all(10),
            icon: Icon(Icons.error, color: Colors.white),
          );
        } else if (e.code == 'wrong-password') {
          // Nếu mật khẩu không đúng
          Get.snackbar(
            "Incorrect Password",
            "The password you entered is incorrect. Please try again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            borderRadius: 8,
            margin: EdgeInsets.all(10),
            icon: Icon(Icons.error, color: Colors.white),
          );
        } else {
          // Nếu có lỗi khác
          Get.snackbar(
            "Error",
            e.message ?? "An unknown error occurred. Please try again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 3),
            borderRadius: 8,
            margin: EdgeInsets.all(10),
            icon: Icon(Icons.error, color: Colors.white),
          );
        }
      }
    }
  }

  // Lấy thông tin người dùng từ Firestore
  getUserInfoFromFirestore(userID) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();

    AppConstants.currentUser.snapshot = snapshot;
    AppConstants.currentUser.firstName = snapshot["firstName"] ?? "";
    AppConstants.currentUser.lastName = snapshot["lastName"] ?? "";
    AppConstants.currentUser.email = snapshot["email"] ?? "";
    AppConstants.currentUser.bio = snapshot["bio"] ?? "";
    AppConstants.currentUser.city = snapshot["city"] ?? "";
    AppConstants.currentUser.city = snapshot["country"] ?? "";
    AppConstants.currentUser.isHost = snapshot["isHost"] as bool? ?? false;
  }

  // Lấy hình ảnh của người dùng từ Firebase Storage
  getImageFromStorage(userId) async {
    if (AppConstants.currentUser.displayImage != null) {
      return AppConstants.currentUser.displayImage;
    }

    final imageDataInBytes = await FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(userId)
        .child(userId + ".png")
        .getData(1024 * 1024);

    AppConstants.currentUser.displayImage = MemoryImage(imageDataInBytes!);
    return AppConstants.currentUser.displayImage;
  }

  // Trở thành Host
  becomeHost(String userID) async {
    userModel.isHost = true;
    Map<String, dynamic> dataMap = {
      "isHost": true,
    };
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .update(dataMap);
  }

  // Cập nhật trạng thái Hosting
  modifyCurrentlyHosting(bool isHosting) {
    userModel.isCurrentlyHosting = isHosting;
  }

  logout() async {
    try {
      // Thực hiện đăng xuất
      await FirebaseAuth.instance.signOut();

      // Hiển thị snackbar thông báo đã đăng xuất thành công
      Get.snackbar(
        "Logged Out",
        "You have successfully logged out.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.exit_to_app, color: Colors.white),
      );

      // Chuyển hướng đến màn hình đăng nhập
      Get.offAll(LoginScreen()); // hoặc trang đăng nhập của bạn
    } catch (e) {
      // Xử lý lỗi nếu có
      Get.snackbar(
        "Error",
        "An error occurred while logging out. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.error, color: Colors.white),
      );
      print("Logout error: $e"); // In ra lỗi nếu có
    }
  }
}
