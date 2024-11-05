
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppConstants {
 static  UserModel currentUser =  UserModel();
  ContactModel createContactFromUserModel(){
    return ContactModel(
      id: currentUser.id,
      firstName: currentUser.firstName,
      lastName: currentUser.lastName,
      displayImage: currentUser.displayImage,  
      
    );
  }
}