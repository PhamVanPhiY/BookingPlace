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
                  print(
                      'Building item at index: $index, posting: ${posting.name}');

                  return Dismissible(
                    key: Key(posting.id!), // Provide a default value when null

                    direction:
                        DismissDirection.endToStart, // Vuốt từ phải sang trái
                    onDismissed: (direction) {
                      // Log khi vuốt qua một mục
                      print('Item at index $index dismissed: ${posting.name}');

                      // Thực hiện xoá hoặc hành động khác
                      // Xử lý xoá item (hoặc cập nhật dữ liệu của bạn ở đây)
                      setState(() {
                        myPostings.removeAt(index);
                      });

                      // Hiển thị snack bar thông báo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Item ${posting.name} removed")),
                      );
                    },
                    background: Container(
                      color: Colors.red, // Màu nền khi vuốt
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: ListTile(
                        leading: FutureBuilder<dynamic>(
                          future: posting.getFirstImageFromFirestore(),
                          builder: (context, snapshot) {
                            print(
                                'Snapshot for index $index: connectionState=${snapshot.connectionState}, hasError=${snapshot.hasError}, hasData=${snapshot.hasData}');

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              print('Image for index $index is loading...');
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              print(
                                  'Error loading image for index $index: ${snapshot.error}');
                              return Icon(Icons.error);
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              print('No image data for index $index');
                              return Icon(Icons.image_not_supported);
                            } else {
                              var image = snapshot.data;
                              print('Loaded image for index $index: $image');

                              return Container(
                                width: 100, // Chiều rộng của hình vuông
                                height: 100, // Chiều cao của hình vuông
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        image), // Dùng NetworkImage để tải hình ảnh từ URL
                                    fit: BoxFit
                                        .cover, // Điều chỉnh cách hình ảnh vừa với khung
                                  ),
                                  borderRadius: BorderRadius
                                      .zero, // Không bo góc (hình vuông)
                                ),
                              );
                            }
                          },
                        ),
                        title: Text(posting.name ?? 'Unknown'),
                        subtitle: Text(posting.getFullAddress()),
                        onTap: () {
                          print(
                              'Tapped on posting at index $index: ${posting.name}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostingDetailScreen(posting: posting),
                            ),
                          );
                        },
                      ),
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
