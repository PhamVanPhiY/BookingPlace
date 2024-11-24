import 'package:booking_place/model/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewModel {
  ContactModel? contact; // Đây là người đánh giá
  String? text;
  double? rating;
  DateTime? dateTime;
  String? reviewerName;

  ReviewModel(
      {this.contact, this.text, this.rating, this.dateTime, this.reviewerName});

  // Hàm khởi tạo thông qua dữ liệu Firestore
  ReviewModel.fromFirestore(Map<String, dynamic> data, ContactModel reviewer)
      : contact = reviewer,
        text = data['text'],
        rating = data['rating']?.toDouble() ?? 0.0,
        dateTime = (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        reviewerName = data['reviewerName'] ??
            reviewer.firstName ??
            'Anonymous'; // Kiểm tra lại nếu không có tên từ Firestore

  // Chuyển đổi ReviewModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'rating': rating,
      'dateTime': dateTime ?? DateTime.now(),
      'reviewerName': reviewerName,
    };
  }

  // Hàm lấy ảnh của người đánh giá từ Firebase Storage
  Future<MemoryImage?> getReviewerImage() async {
    if (contact != null) {
      // Đảm bảo lấy ảnh của người đánh giá
      //return await contact!.getImageFromStorage();
    }
    return null;
  }
}
