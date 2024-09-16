import 'package:booking_place/view/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(horizontal: 60)),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white),
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
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
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
}
