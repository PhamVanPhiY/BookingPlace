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
                      leading: FutureBuilder<dynamic>(
                        future: posting
                            .getFirstImageFromStorage(), // Hàm này vẫn giữ nguyên
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
                            // Kiểm tra và ép kiểu giá trị trả về
                            var image = snapshot.data;
                            if (image is MemoryImage) {
                              return CircleAvatar(
                                backgroundImage: image,
                              );
                            } else {
                              // Xử lý khi dữ liệu không phải kiểu MemoryImage
                              return Icon(Icons.image_not_supported);
                            }
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
