import 'package:booking_place/global.dart';
import 'package:booking_place/view/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();

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
      child: ListView(
        children: [
          Image.asset("assets/images/logologin.jpeg"),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 26.0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Email"),
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                      controller: _emailTextEditingController,
                      validator: (valueEmail) {
                        if (!valueEmail!.contains("@")) {
                          return "Please write valid email";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 21.0),
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Password"),
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                      controller: _passwordTextEditingController,
                      obscureText: true,
                      validator: (valuePassword) {
                        if (valuePassword!.length < 5) {
                          return "Password must be atleast 6 or more characters. ";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding( 
                    padding: const EdgeInsets.only(top: 26.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // if (_formKey.currentState!.validate()) {
                        await userViewModel.login(
                            // _emailTextEditingController.text.trim(),
                            // _passwordTextEditingController.text.trim(),
                            "1",
                            "1");
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.deepPurpleAccent,
                        elevation: 8,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showForgotPasswordDialog(); // Hiển thị hộp thoại quên mật khẩu
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(SignupScreen());
                    },
                    child: const Text(
                      "Don't have an account? Create here",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  _showForgotPasswordDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: Colors.deepPurpleAccent),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.deepPurple, // Background color of the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isNotEmpty && email.contains("@")) {
                  await _resetPassword(email);
                  Navigator.of(context).pop();
                } else {
                  Get.snackbar(
                    "Error",
                    "Please enter a valid email.",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                    borderRadius: 8,
                    margin: EdgeInsets.all(10),
                    icon: Icon(Icons.error, color: Colors.white),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      Get.snackbar(
        "Password Reset",
        "A password reset link has been sent to your email.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        borderRadius: 8,
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.email, color: Colors.white),
      );
    } catch (e) {
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
