import 'dart:math';

import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class ConversationModel {
  String? id;
  ContactModel? otherContact;
  List<MessageModel>? messages;
  MessageModel? lastMessage;

  ConversationModel() {
    messages = [];
  }

  addConversationToFirebase(ContactModel otherContact) async {
    List<String> userNames = [
      AppConstants.currentUser.getFullNameOfUser(),
      otherContact.getFullNameOfUser(),
    ];
    List<String> userIDs = [
      AppConstants.currentUser.id!,
      otherContact.id!,
    ];
    Map<String, dynamic> conversationDataMap = {
      'LastMessageDateTime': DateTime.now(),
      'LastMessageText': "",
      'userNames': userNames,
      'userIDs': userIDs,
    };
    DocumentReference reference = await FirebaseFirestore.instance
        .collection('conversations')
        .add(conversationDataMap);
    id = reference.id;
  }

  addMessageToFirestore(String messageText) async {
    Map<String, dynamic> messageData = {
      'dateTime': DateTime.now(),
      'senderID': AppConstants.currentUser!.id,
      'text': messageText
    };
    await FirebaseFirestore.instance
        .collection('conversations/${id}/messages')
        .add(messageData);
    Map<String, dynamic> conversationData = {
      'LastMessageDateTime': DateTime.now(),
      'LastMessageText': messageText
    };
    await FirebaseFirestore.instance
        .doc('conversations/${id}')
        .update(conversationData);
  }

  getConversationInfoFromFirestore(DocumentSnapshot snapshot) {
    id = snapshot.id;
    print("id ${id}");

    // Kiểm tra và lấy giá trị tin nhắn cuối cùng
    String lastMessageText = snapshot['LastMessageText'] ?? "";
    Timestamp lastMessageDateTimestamp = snapshot['LastMessageDateTime'] ?? Timestamp.now();
    DateTime lastMessageDateTime = lastMessageDateTimestamp.toDate();

    // Khởi tạo lastMessage nếu cần
    lastMessage = MessageModel();
    lastMessage!.dateTime = lastMessageDateTime;
    lastMessage!.text = lastMessageText;
    print(lastMessageText);
    // Kiểm tra và lấy danh sách userIDs và userNames
    List<String> userIDs = List<String>.from(snapshot['userIDs'] ?? []);
    List<String> userNames = List<String>.from(snapshot['userNames'] ?? []);

    otherContact = ContactModel();

    // Lấy ID của người dùng khác ngoài người hiện tại
    for (String userID in userIDs) {
      if (userID != AppConstants.currentUser.id) {
        otherContact!.id = userID;
        break;
      }
    }

    // Lấy tên người dùng khác ngoài người hiện tại
    for (String name in userNames) {
      if (name != AppConstants.currentUser.getFullNameOfUser()) {
        otherContact!.firstName = name.split(" ")[0] ?? "";
        otherContact!.lastName = name.split(" ")[1] ?? "";
        break;
      }
    }
  }

}
