import 'dart:convert';
import 'dart:typed_data';

import 'package:booking_place/global.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/booking_model.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostingModel {
  String? id;
  String? name;
  String? type;
  double? price;
  String? description;
  String? address;
  String? city;
  String? country;
  double? rating;

  ContactModel? host;
  List<String>? imageNames;
  List<ImageProvider> displayImage = [];

  List<String>? amenities;

  Map<String, int>? beds;
  Map<String, int>? bathrooms;

  List<BookingModel>? bookings;
  List<ReviewModel>? reviews;

  PostingModel(
      {this.id = "",
      this.name = "",
      this.type = "",
      this.price = 0,
      this.description = "",
      this.address = "",
      this.city = "",
      this.country = "",
      this.host}) {
    displayImage = [];
    amenities = [];
    beds = {};
    bathrooms = {};
    rating = 0;

    bookings = [];
    reviews = [];
  }
  setImageNames() {
    imageNames = [];
    for (int i = 0; i < displayImage!.length; i++) {
      imageNames!.add("image${i}.png");
    }
  }

  getPostingInfoFromFirestore() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('postings').doc(id).get();

    getPostingInfoFromSnapshot(snapshot);
  }

  getPostingInfoFromSnapshot(DocumentSnapshot snapshot) {
    address = snapshot['address'] ?? "";
    amenities = List<String>.from(snapshot['amenities']) ?? [];
    bathrooms = Map<String, int>.from(snapshot['bathrooms']) ?? {};
    beds = Map<String, int>.from(snapshot['beds']) ?? {};
    city = snapshot['city'] ?? "";
    country = snapshot['country'] ?? "";
    description = snapshot['description'] ?? "";

    String hostID = snapshot['hostID'] ?? "";
    host = ContactModel(id: hostID);
    imageNames = List<String>.from(snapshot['images']) ?? [];
    name = snapshot['name'] ?? "";
    price = snapshot['price'].toDouble() ?? 0.0;
    rating = snapshot['rating'].toDouble() ?? 2.5;
    type = snapshot['type'] ?? "";
  }

  /*getAllImagesFromStorage() async {
    // Tạo một danh sách rỗng để lưu trữ các ảnh lấy được
    displayImage = [];

    // Duyệt qua danh sách tên các ảnh
    for (int i = 0; i < imageNames!.length; i++) {
      // Lấy dữ liệu ảnh từ Firebase Storage
      final imageData = await FirebaseStorage.instance
          .ref()
          .child("postingImages")
          .child(id!)
          .child(imageNames![i])
          .getData(1024 * 1024); // Lấy dữ liệu với kích thước tối đa 1MB

      // Thêm ảnh vào danh sách displayImages
      displayImage!.add(MemoryImage(imageData!));
    }
    

    // Trả về danh sách các ảnh đã lấy được
    return displayImage;
  }*/
  getAllImagesFromFirestore() async {
    displayImage = []; // Khởi tạo danh sách ảnh (hoặc danh sách lưu URL)

    // Lấy thông tin bài đăng từ Firestore
    DocumentSnapshot postingSnapshot = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id!) // ID của bài đăng
        .get();

    if (postingSnapshot.exists) {
      // Lấy danh sách ảnh từ trường "images" (dự đoán là List<String>)
      List<dynamic> images =
          postingSnapshot['images'] ?? []; // Lấy danh sách ảnh

      for (var image in images) {
        // Nếu ảnh là URL (chuỗi không rỗng), thêm trực tiếp vào danh sách
        if (image is String && image.isNotEmpty) {
          displayImage!.add(
              NetworkImage(image)); // Sử dụng NetworkImage để tải ảnh từ URL
        }
      }
    }

    return displayImage; // Trả về danh sách ảnh (hoặc URLs)
  }

/*
  getFirstImageFromStorage() async {
    if (displayImage!.isNotEmpty) {
      return displayImage!.first;
    }
    final imageData = await FirebaseStorage.instance
        .ref()
        .child("postingImages")
        .child(id!)
        .child(imageNames!.first)
        .getData(1024 * 1024);
    displayImage!.add(MemoryImage(imageData!));
    return displayImage!.first;
  }
*/
  getFirstImageFromFirestore() async {
    if (displayImage!.isNotEmpty) {
      return displayImage!.first; // Nếu đã có ảnh, trả về ảnh đầu tiên
    }

    // Lấy thông tin bài đăng từ Firestore
    DocumentSnapshot postingSnapshot = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id!) // ID của bài đăng
        .get();

    if (postingSnapshot.exists) {
      // Lấy danh sách ảnh từ trường "images"
      List<dynamic> images = postingSnapshot['images'] ?? [];

      if (images.isNotEmpty) {
        String firstImage = images[0]; // Lấy ảnh đầu tiên trong danh sách

        // Giải mã chuỗi Base64 của ảnh
        if (firstImage.isNotEmpty) {
          Uint8List bytes =
              base64Decode(firstImage); // Giải mã Base64 thành bytes
          displayImage!.add(MemoryImage(bytes)); // Thêm ảnh vào danh sách
          return displayImage!.first; // Trả về ảnh đầu tiên
        }
      }
    }

    return null; // Nếu không có ảnh, trả về null
  }

  getAmenitiesString() {
    if (amenities!.isEmpty) {
      return "";
    }

    String amenitiesString = amenities.toString();

    return amenitiesString.substring(1, amenitiesString.length - 1);
  }

  double getCurrentRating() {
    if (reviews!.length == 0) {
      return 4;
    }
    double rating = 0;

    reviews!.forEach((review) {
      rating = rating + review.rating!;
    });
    rating /= reviews!.length;
    return rating;
  }

  getHostFromFirestore() async {
    await host!.getContactInfoFromFirestore();
    await host!.getImageFromStorage();
  }

  int getGuestsNumber() {
    int? numGuests = 0;
    numGuests = numGuests + beds!['small']!;
    numGuests += numGuests + beds!['medium']! * 2;
    numGuests += numGuests + beds!['large']! * 2;
    return numGuests;
  }

  String getBedroomText() {
    String text = "";
    if (beds!['small'] != 0) {
      text = text + beds!["small"].toString() + " single/twin";
    }
    if (beds!["medium"] != 0) {
      text = text + beds!["medium"].toString() + " double";
    }
    if (beds!["large"] != 0) {
      text = text + beds!["large"].toString() + " queen/king";
    }
    return text;
  }

  String getBathroomText() {
    String text = "";
    if (beds!['full'] != 0) {
      text = text + bathrooms!["full"].toString() + " full";
    }
    if (beds!["half"] != 0) {
      text = text + bathrooms!["half"].toString() + " half";
    }
    return text;
  }

  String getFullAddress() {
    return address! + ", " + city! + ", " + country!;
  }

  getAllBookingsFromFirestore() async {
    bookings = [];
    QuerySnapshot snapshots = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .collection('bookings')
        .get();
    for (var snapshot in snapshots.docs) {
      BookingModel newBooking = BookingModel();
      await newBooking.getBookingInfoFromFirestoreFromPosting(this, snapshot);
      bookings!.add(newBooking);
    }
  }

  List<DateTime> getAllBookedDates() {
    List<DateTime> dates = [];
    bookings!.forEach((booking) {
      dates.addAll(booking.dates!);
    });
    return dates;
  }

  Future<void> makeNewBooking(List<DateTime> dates, context, hostID) async {
    Map<String, dynamic> bookingData = {
      'dates': dates,
      'name': AppConstants.currentUser.getFullNameOfUser(),
      'userID': AppConstants.currentUser.id,
      'payment': bookingPrice,
    };
    DocumentReference reference = await FirebaseFirestore.instance
        .collection('postings')
        .doc(id)
        .collection('bookings')
        .add(bookingData);
    BookingModel newBooking = BookingModel();

    newBooking.createBooking(
        this, AppConstants.currentUser.createUserFromContact(), dates);
    newBooking.id = reference.id;

    bookings!.add(newBooking);
    await AppConstants.currentUser
        .addBookingToFirestore(newBooking, bookingPrice!, hostID);
    Get.snackbar("Listing", "Booked successfully");
  }
}
