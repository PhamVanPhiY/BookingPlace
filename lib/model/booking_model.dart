import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String id = "";
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;

  BookingModel();
  getBookingInfoFromFirestoreFromPosting(
      PostingModel posting, DocumentSnapshot snapshot) async {
    posting = posting;
    List<Timestamp> timestamps = List<Timestamp>.from(snapshot['dates']) ?? [];

    dates = [];
    timestamps.forEach((timestamps) {
      dates!.add((timestamps.toDate()));
    });
    String contactID = snapshot['userID'] ?? "";
    String fullName = snapshot['name'] ?? "";

    _loadContactInfo(id, fullName);

    contact = ContactModel(id: contactID);
  }

  _loadContactInfo(String id, String fullName) {
    String firstName = "";
    String lastName = "";

    var nameParts = fullName.split(" ");
    if (nameParts.length > 1) {
      firstName = nameParts[0];
      lastName = nameParts[1];
    } else {
      firstName = nameParts[0];
      lastName = ""; // Hoặc đặt giá trị mặc định khác nếu cần
    }

    contact = ContactModel(id: id, firstName: firstName, lastName: lastName);
  }

  createBooking(
      PostingModel postingM, ContactModel contactM, List<DateTime> datesM) {
    posting = postingM;
    contact = contactM;
    dates = datesM;
    datesM.sort();
  }
}
