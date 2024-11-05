import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/posting_model.dart';

class BookingModel {
  String id = "";
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;

  BookingModel();
}