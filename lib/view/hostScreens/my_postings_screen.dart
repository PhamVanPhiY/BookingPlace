import 'package:booking_place/view/hostScreens/create_posting_screen.dart';
import 'package:booking_place/view/widgets/posting_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPostingsScreen extends StatefulWidget {
  const MyPostingsScreen({super.key});

  @override
  State<MyPostingsScreen> createState() => _MyPostingsScreenState();
}

class _MyPostingsScreenState extends State<MyPostingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(29, 0, 26, 26),
        child: InkResponse(
          onTap: () {
            Get.to(CreatePostingScreen());
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: Colors.grey,
              width: 1.2,
            )),
            child: PostingListTile(),
          ),
        ),
      ),
    );
  }
}
