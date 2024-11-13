import 'package:booking_place/model/booking_model.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserModel extends ContactModel {
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  bool? isHost;
  bool? isCurrentlyHosting;
  DocumentSnapshot? snapshot;

  List<BookingModel>? bookings;
  List<ReviewModel>? reviews;

  List<PostingModel>? savedPostings;
  List<PostingModel>? myPostings;

  UserModel({
    String id = "",
    String firstName = "",
    String lastName = "",
    MemoryImage? displayImage,
    this.email = "",
    this.bio = "",
    this.city = "",
    this.country = "",
  }) : super(
            id: id,
            firstName: firstName,
            lastName: lastName,
            displayImage: displayImage) {
    isHost = false;
    isCurrentlyHosting = false;
    bookings = [];
    reviews = [];
    savedPostings = [];
    myPostings = [];
  }

  Future<void> saveUserToFirestore() async {
    Map<String, dynamic> dataMap = {
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "isHost": false,
      "myPostingIDs": [],
      "savePostingIDs": [],
      "earnings": 0
    };

    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }

  addPostingToMyPostings(PostingModel posting) async {
    myPostings!.add(posting);
    List<String> myPostingIDsList = [];
    myPostings!.forEach((element) {
      myPostingIDsList.add(element.id!);
    });
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'myPostingIDs': myPostingIDsList,
    });
  }

  getMyPostingsFromFirestore() async {
    List<String> myPostingIDs =
        List<String>.from(snapshot!["myPostingIDs"]) ?? [];

    for (String postingID in myPostingIDs) {
      PostingModel posting = PostingModel(id: postingID);
      await posting.getPostingInfoFromFirestore();
      await posting.getAllImagesFromStorage();
      myPostings!.add(posting);
    }
  }

  addSavedPosting(PostingModel posting) async {
    for (var savedPosting in savedPostings!) {
      if (savedPosting.id == posting.id) {
        return;
      }
    }
    savedPostings!.add(posting);
    List<String> savePostingIDs = [];
    savedPostings!.forEach((savedPosting) {
      savePostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savePostingIDs': savePostingIDs,
    });
    Get.snackbar("Marked as Favourite", "Saved to your Favourite List");
  }

  removeSavedPostings(PostingModel posting) async {
    for(int i = 0;i < savedPostings!.length; i++){
      if(savedPostings![i].id == posting.id){
        savedPostings!.removeAt(i);
        break;
      }
    }

       List<String> savePostingIDs = [];
    savedPostings!.forEach((savedPosting) {
      savePostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savePostingIDs': savePostingIDs,
    });
    Get.snackbar("Listings Removed", "Listings removed from your Favourite List");
  
    
  }

  Future<void> addBookingToFirestore(BookingModel booking,double totalPriceForAllNigths,String hostID) async {
    String earningsOld = "";
    await FirebaseFirestore.instance.collection('users').doc(hostID).get().then((dataSnap){
      earningsOld = dataSnap["earnings"].toString();
   });

   Map<String, dynamic> data = {
    'dates' : booking.dates,
    'postingID' : booking.posting!.id!,
   };

   await FirebaseFirestore.instance.doc('users/${id}/bookings/${booking.id}').set(data);
   await FirebaseFirestore.instance.collection("users").doc(hostID).update(
    {"earnings" : totalPriceForAllNigths + int.parse(earningsOld),}
   );
   bookings!.add(booking);
  }
  List<DateTime> getAllBookedDates()
  {
    List<DateTime> allBookedDates = [];
    myPostings!.forEach((posting)
    {
      posting.bookings!.forEach((booking){
          allBookedDates.addAll(booking.dates!);
    });
  });
    return allBookedDates;
}
}
