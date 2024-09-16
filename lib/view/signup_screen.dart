import 'dart:io';

import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _passwordTextEditingController =
      TextEditingController();
  TextEditingController _firstNameTextEditingController =
      TextEditingController();
  TextEditingController _lastNameTextEditingController =
      TextEditingController();
  TextEditingController _cityTextEditingController = TextEditingController();
  TextEditingController _countryTextEditingController = TextEditingController();
  TextEditingController _bioTextEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? imageFileOfUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.amber],
                  begin: FractionalOffset(0, 0),
                  end: FractionalOffset(1, 0),
                  stops: [0, 1],
                  tileMode: TileMode.clamp)),
        ),
        title: const Text(
          'Create New Account',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
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
            Padding(
              padding:
                  const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
              child: Image.asset(
                "assets/images/signup.png",
                width: 240,
              ),
            ),
            const Text(
              "Tell us about you :",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "Email"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        controller: _emailTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please write valid email";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Password"),
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
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "First Name"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        controller: _firstNameTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please enter a first name ";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        controller: _lastNameTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please enter a last name ";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "City"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        controller: _cityTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please write your city name";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "Country"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        controller: _countryTextEditingController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "Please write your country name";
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: "Bio"),
                        style: const TextStyle(
                          fontSize: 25.0,
                        ),
                        maxLines: 4,
                        controller: _bioTextEditingController,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 38.0),
              child: MaterialButton(
                onPressed: () {},
                child: imageFileOfUser == null
                    ? const Icon(Icons.add_a_photo)
                    : CircleAvatar(
                        backgroundColor: Colors.pink,
                        radius: MediaQuery.of(context).size.width / 5.0,
                        child: CircleAvatar(
                          backgroundImage: FileImage(imageFileOfUser!),
                          radius: MediaQuery.of(context).size.width / 5.2,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 44.0, right: 60, left: 60),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
