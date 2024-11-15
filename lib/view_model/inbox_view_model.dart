import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/app_constants.dart';

class InboxViewModel {
  getConversations() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('userIDs', arrayContains: AppConstants.currentUser.id)
        .snapshots();
  }
}
