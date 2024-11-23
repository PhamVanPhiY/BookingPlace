import 'package:booking_place/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ContactModel {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  MemoryImage? displayImage;
  String? linkImageUser;

  ContactModel({
    this.id = "",
    this.firstName = "",
    this.lastName = "",
    this.displayImage,
    this.linkImageUser,
  });

  // Lấy họ và tên đầy đủ của người dùng
  String getFullNameOfUser() {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    } else {
      return "Unknown User";
    }
  }

  // Tạo UserModel từ ContactModel
  UserModel createUserFromContact() {
    return UserModel(
      id: id!,
      firstName: firstName!,
      lastName: lastName!,
      //displayImage: displayImage!,
      linkImageUser: linkImageUser!,
    );
  }

  // Lấy thông tin người dùng từ Firestore (Bất đồng bộ)
  Future<ContactModel> getContactInfoFromFirestore() async {
    try {
      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      // Kiểm tra xem người dùng có tồn tại trong Firestore không
      if (snapshot.exists) {
        firstName = snapshot['firstName'] ?? "";
        lastName = snapshot['lastName'] ?? "";
        fullName = getFullNameOfUser(); // Tạo tên đầy đủ
        linkImageUser = snapshot['linkImageUser'] ?? "";
      } else {
        throw Exception('User not found');
      }
      return this; // Trả về ContactModel sau khi lấy xong dữ liệu
    } catch (e) {
      print("Error getting contact info: $e");
      return this; // Nếu có lỗi, trả về đối tượng mặc định
    }
  }

  // Lấy ảnh người dùng từ Firebase Storage (Bất đồng bộ)
  Future<MemoryImage?> getImageFromStorage() async {
    if (displayImage != null) {
      return displayImage!;
    }

    try {
      // Lấy dữ liệu ảnh từ Firebase Storage
      final imageData = await FirebaseStorage.instance
          .ref()
          .child("userImages")
          .child(id!)
          .child("$id.png")
          .getData(1024 * 1024); // Lấy tối đa 1MB dữ liệu

      if (imageData != null) {
        displayImage = MemoryImage(imageData);
        return displayImage;
      } else {
        return null; // Trả về null nếu không có dữ liệu ảnh
      }
    } catch (e) {
      print("Error getting image from storage: $e");
      return null; // Trả về null nếu có lỗi khi lấy ảnh
    }
  }
}
