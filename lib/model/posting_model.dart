import 'package:booking_place/model/booking_model.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:flutter/material.dart';

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
  List<MemoryImage>? displayImage;
  List<String>? amenities;

  Map<String, int>? beds;
  Map<String, int>? bathroom;

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
    bathroom = {};
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
}
