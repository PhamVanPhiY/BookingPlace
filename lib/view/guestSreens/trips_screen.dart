import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/view/guestSreens/posting_detail_screen.dart';
import 'package:flutter/material.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late Future<void> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = AppConstants.currentUser!.getAllBookingsFromUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<PostingModel> myPostings =
                AppConstants.currentUser!.myPostings ?? [];
            if (myPostings.isEmpty) {
              return Center(child: Text('No trips found.'));
            } else {
              return ListView.builder(
                itemCount: myPostings.length,
                itemBuilder: (context, index) {
                  PostingModel posting = myPostings[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: FutureBuilder<MemoryImage?>(
                        future: posting.getFirstImageFromStorage(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Icon(Icons.error);
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Icon(Icons
                                .image_not_supported); // Hiển thị khi không có dữ liệu
                          } else {
                            return CircleAvatar(
                              backgroundImage: snapshot.data!,
                            );
                          }
                        },
                      ),
                      title: Text(posting.name ?? 'Unknown'),
                      subtitle: Text(posting.getFullAddress()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostingDetailScreen(posting: posting),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
