import 'package:booking_place/view/widgets/conversation_list_tile_ui.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure Firestore is imported
import '../../global.dart';
import '../../model/app_constants.dart';
import '../../model/conversation_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    print('Current user ID: ${AppConstants.currentUser.id}');
    return StreamBuilder<QuerySnapshot>(

      stream: inboxViewModel.getConversations(),

      builder: (context, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          print('${dataSnapshot.data?.docs.length}');
          return ListView.builder(
            itemCount: dataSnapshot.data?.docs.length,
            itemExtent: MediaQuery.of(context).size.height / 9,
            itemBuilder: (context, index) {
              DocumentSnapshot snapshot = dataSnapshot.data!.docs[index];
              print('snapshot ${snapshot}');
              ConversationModel currentConversation = ConversationModel();
              currentConversation.getConversationInfoFromFirestore(snapshot);

             return InkResponse(
               onTap: (){

               },
               child: ConversationListTileUI(
                 conversation: currentConversation,
               ),
             );
            },
          ); // ListView.builder
        }
      }, // <-- Closing brace for the builder function
    ); // StreamBuilder
  }
}
