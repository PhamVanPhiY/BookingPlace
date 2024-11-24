import 'dart:convert'; // Để mã hóa Base64
import 'package:booking_place/global.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostingsViewModel {
  addListingInfoToFirestore() async {
    postingModel.setImageNames();

    // Chuyển đổi ảnh sang chuỗi Base64

    Map<String, dynamic> dataMap = {
      "address": postingModel.address,
      "amenities": postingModel.amenities,
      "bathrooms": postingModel.bathrooms,
      "description": postingModel.description,
      "beds": postingModel.beds,
      "city": postingModel.city,
      "country": postingModel.country,
      "hostID": AppConstants.currentUser.id,
      "imageNames": postingModel.imageNames,
      //  "images": imageBase64List, // Lưu danh sách ảnh dạng Base64
      "name": postingModel.name,
      "price": postingModel.price,
      "rating": 3.5,
      "type": postingModel.type,
    };

    DocumentReference ref =
        await FirebaseFirestore.instance.collection("postings").add(dataMap);
    postingModel.id = ref.id;

    await AppConstants.currentUser.addPostingToMyPostings(postingModel);
  }

  updateListingInfoToFirestore() async {
    postingModel.setImageNames();

    // Chuyển đổi ảnh sang chuỗi Base64

    Map<String, dynamic> dataMap = {
      "address": postingModel.address,
      "amenities": postingModel.amenities,
      "bathrooms": postingModel.bathrooms,
      "description": postingModel.description,
      "beds": postingModel.beds,
      "city": postingModel.city,
      "country": postingModel.country,
      "hostID": AppConstants.currentUser.id,
      //"imageNames": postingModel.imageNames,
      //"images": imageBase64List, // Lưu danh sách ảnh dạng Base64
      "name": postingModel.name,
      "price": postingModel.price,
      "rating": 3.5,
      "type": postingModel.type,
    };

    await FirebaseFirestore.instance
        .collection("postings")
        .doc(postingModel.id)
        .update(dataMap);
  }

  loadImagesFromFirestore(List<String> imageBase64List) {
    // Chuyển từ Base64 về MemoryImage để hiển thị trong giao diện
    postingModel.displayImage = imageBase64List
        .map((base64String) =>
            MemoryImage(base64Decode(base64String))) // Decode Base64
        .toList();
  }
}
