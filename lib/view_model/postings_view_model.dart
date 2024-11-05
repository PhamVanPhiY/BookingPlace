import 'package:booking_place/global.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostingsViewModel {
  addListingInfoToFirestore() async {
    
    postingModel.setImageNames();
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
      "name": postingModel.name,
      "price": postingModel.price,
      "rating": postingModel.rating,
      "type": postingModel.type,
    };

    DocumentReference ref =
        await FirebaseFirestore.instance.collection("postings").add(dataMap);
    postingModel.id = ref.id;

    await AppConstants.currentUser.addPostingToMyPostings(postingModel);
  }

  addImageToFirebaseStorage() async {
 
    for (int i = 0; i < postingModel.displayImage!.length; i++) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("postingImages")
          .child(postingModel.id!)
          .child(postingModel.imageNames![i]);

      await ref.putData(postingModel.displayImage![i].bytes).whenComplete((){

      });
    }
  }
}
