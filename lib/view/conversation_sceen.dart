  import 'package:booking_place/global.dart';
  import 'package:booking_place/model/app_constants.dart';
  import 'package:booking_place/model/conversation_model.dart';
  import 'package:booking_place/model/message_model.dart';
  import 'package:booking_place/view/widgets/message_list_title_ui.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/material.dart';

  class ConversationSceen extends StatefulWidget {
    ConversationModel? conversation;

    ConversationSceen({
      super.key,
      this.conversation,
    });

    @override
    State<ConversationSceen> createState() => _ConversationSceenState();
  }

  class _ConversationSceenState extends State<ConversationSceen> {
    ConversationModel? conversation;
    TextEditingController controller = TextEditingController();
    void sendMessage() {
      String text=controller.text;
      if (text.isEmpty)
      {      return;
      }
      conversation!.addMessageToFirestore(text).whenComplete(()
      {
        setState((){
          controller.text = "";
        });
      });
    }
    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      conversation = widget.conversation;
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Colors.pinkAccent,
                Colors.amber,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            )),
          ),
          backgroundColor: Colors.black,
          title: Text(conversation!.otherContact!.getFullNameOfUser()),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: inboxViewModel.getMessages(widget.conversation),
                builder: (context, snapshots) {
                  if (snapshots.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                        itemCount: snapshots.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot snapshot = snapshots.data!.docs[index];
                          MessageModel currentMessage = MessageModel();
                          currentMessage.getMessageInfoFromFirestore(snapshot);
                          if (currentMessage.sender!.id ==
                              AppConstants.currentUser.id) {
                            currentMessage.sender =
                                AppConstants.currentUser.createContactFromUser();
                          } else {
                            currentMessage.sender =
                                widget.conversation!.otherContact;
                          }
                          return MessageListTitleUi(
                            message: currentMessage,
                          );
                        });
                  }
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.black,
              )),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 5 / 6,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'write message',
                        contentPadding: EdgeInsets.all(20.0),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 20.0),
                      controller: controller,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: const Icon(Icons.send)),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }


  }
