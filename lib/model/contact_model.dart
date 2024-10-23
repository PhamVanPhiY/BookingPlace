import 'package:booking_place/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContactModel {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  MemoryImage? displayImage;

  ContactModel({
    this.id = "",
    this.firstName = "",
    this.lastName = "",
    this.displayImage,
  });

  String getFullNameOfUser() {
    return fullName = firstName! + "" + lastName!;
  }

  UserModel createUserFromContact() {
    return UserModel(
      id: id!,
      firstName: firstName!,
      lastName: lastName!,
      displayImage: displayImage!,
    );
  }
}
