import 'package:booking_place/global.dart';
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
                        if (_formKey.currentState!.validate()) {
                          await userViewModel.login(
                            _emailTextEditingController.text.trim(),
                            _passwordTextEditingController.text.trim(),
                          );
                        }
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
}
