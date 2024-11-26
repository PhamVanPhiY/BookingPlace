import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:booking_place/view/guestSreens/book_listing_screen.dart';
import 'package:booking_place/view/widgets/posting_info_tile_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPostingScreen extends StatefulWidget {
  final PostingModel? posting;

  ViewPostingScreen({super.key, this.posting});

  @override
  State<ViewPostingScreen> createState() => _ViewPostingScreenState();
}

class _ViewPostingScreenState extends State<ViewPostingScreen> {
  PostingModel? posting;
  List<ReviewModel> reviews = [];
  List<String> amenities = [
    "WiFi miễn phí",
    "Bể bơi",
    "Phòng gym",
    "Chỗ đỗ xe",
    "Điều hòa"
  ];
  getRequiredInfo() async {
    await posting!.getAllImagesFromFirestore();
    await posting!.getHostFromFirestore();
    await getReviews();
    setState(() {});
  }

  getReviews() async {
    final reviewCollection = FirebaseFirestore.instance
        .collection('postings')
        .doc(posting!.id)
        .collection('reviews');
    final reviewSnapshot = await reviewCollection.get();

    setState(() {
      reviews = reviewSnapshot.docs.map((doc) {
        return ReviewModel.fromFirestore(doc.data(), posting!.host!);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    getRequiredInfo();
  }

  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
            ),
          ),
        ),
        title: const Text(
          'Posting Information',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              AppConstants.currentUser.addSavedPosting(posting!);
            },
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Section
            AspectRatio(
              aspectRatio: 3 / 2,
              child: PageView.builder(
                itemCount: posting!.displayImage!.length,
                itemBuilder: (context, index) {
                  // Chuyển đổi mỗi String thành NetworkImage (hoặc FileImage nếu cần)
                  ImageProvider currentImage =
                      NetworkImage(posting!.displayImage![index]);
                  return Image(
                    image: currentImage,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),

            // Posting Details
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Book Now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          posting!.name!,
                          // 'Intercontienal DanNang',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.to(BookListingScreen(
                                posting: posting,
                                hostID: posting!.host!.id!,
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Book Noww'),
                          ),
                          Text(
                            '\$${posting!.price} / night',
                            // '\$4000 / night',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(thickness: 1, color: Colors.grey),

                  // Description & Host Info
                  // Description & Host Info
                  // Description & Host Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isDescriptionExpanded = !isDescriptionExpanded;
                          });
                        },
                        child: Text(
                          posting!.description!,
                          textAlign: TextAlign.justify,
                          maxLines: isDescriptionExpanded
                              ? null
                              : 5, // Giới hạn 5 dòng
                          overflow: isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow
                                  .ellipsis, // Hiển thị '...' nếu bị cắt
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (!isDescriptionExpanded)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDescriptionExpanded = true;
                            });
                          },
                          child: const Text(
                            '...Xem thêm',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isDescriptionExpanded)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDescriptionExpanded = false;
                            });
                          },
                          child: const Text(
                            'Ẩn bớt',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Căn trái cho các widget con
                    children: [
                      const Text(
                        'Amenities?', // Tiêu đề
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                          height: 10), // Khoảng cách giữa tiêu đề và Wrap
                      Wrap(
                        spacing: 8, // Khoảng cách ngang giữa các item
                        runSpacing: 8, // Khoảng cách dọc giữa các dòng
                        children: List.generate(
                          posting!
                              .amenities!.length, // Duyệt qua mảng amenities
                          (index) => Chip(
                            label: Text(
                              posting!.amenities![
                                  index], // Sử dụng phần tử của mảng amenities
                              style: const TextStyle(
                                fontSize: 14, // Kích thước chữ vừa phải
                              ),
                            ),
                            backgroundColor: Colors.amber.shade50,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6, // Padding trong mỗi chip
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Căn trái cho các widget con
                    children: [
                      const Text(
                        'What we offer?', // Tiêu đề
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                          height: 10), // Khoảng cách giữa tiêu đề và Wrap
                    ],
                  ),
                  const SizedBox(
                    height: 10, // Khoảng cách giữa avatar và tên
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // Căn đều khoảng cách giữa các phần tử
                    children: List.generate(2, (index) {
                      // Tùy chỉnh icon dựa trên index
                      IconData icon;
                      String textt = '';
                      switch (index) {
                        case 0:
                          icon = Icons.bed;
                          textt =
                              'Bed: ${posting!.getTotalBeds()}'; // Icon đầu tiên
                          break;
                        case 1:
                          icon = Icons.bathroom;
                          textt =
                              'Bathroom: ${posting!.getTotalBathrooms()}'; // Icon thứ hai
                          break;
                        // Có thể thêm các case khác nếu cần
                        default:
                          icon = Icons.star; // Mặc định là star
                          break;
                      }

                      return Column(
                        children: [
                          Icon(
                            icon, // Sử dụng icon đã xác định
                            size: 50, // Kích thước biểu tượng
                            color: Colors.blue, // Màu sắc biểu tượng
                          ),
                          SizedBox(
                            height: 8,
                          ), // Khoảng cách giữa ảnh và văn bản
                          Text(
                            textt,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(
                    height: 10, // Khoảng cách giữa avatar và tên
                  ),
                  Container(
                    color: Colors.blue.withOpacity(0.1), // Màu nền của Row
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 8), // Padding cho Row
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Căn đều hai đầu Row
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    posting!.host!.linkImageUser != null
                                        ? NetworkImage(
                                            posting!.host!.linkImageUser!)
                                        : null, // Hình ảnh mặc định nếu cần
                                backgroundColor: Colors
                                    .grey[300], // Màu nền khi không có ảnh
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Căn text sang trái
                              children: [
                                Text(
                                  posting!.host!
                                      .getFullNameOfUser(), // Tên host
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Màu chữ
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                    height: 4), // Khoảng cách giữa hai dòng
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star, // Biểu tượng ngôi sao
                                      color: Colors.yellow, // Màu ngôi sao
                                      size: 16, // Kích thước ngôi sao
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${posting!.rating} (1k reviews)", // Số sao và đánh giá
                                      style: const TextStyle(
                                        color: Colors.black87, // Màu chữ
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            // Xử lý khi nhấn vào icon
                            print("Message icon tapped!");
                          },
                          icon: Icon(
                            Icons.message, // Biểu tượng tin nhắn
                            color: Colors.blue, // Màu biểu tượng
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20, // Khoảng cách giữa avatar và tên
                  ),
                  Text(
                    "Address: ${posting!.address ?? 'No address available'}",
                    // "Address: Gia môn, Phong Bình, Gio Linh, Quảng Trị",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10, // Khoảng cách giữa avatar và tên
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Kiểm tra nếu danh sách đánh giá rỗng
                      reviews.isEmpty
                          ? const Text(
                              'No reviews',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews
                                  .length, // Lấy danh sách đánh giá từ Firestore
                              itemBuilder: (context, index) {
                                final review = reviews[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Thay đổi để lấy ảnh của người đánh giá
                                          FutureBuilder<MemoryImage?>(
                                            future: review
                                                .getReviewerImage(), // Lấy ảnh của người đánh giá
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors
                                                      .grey, // Màu nền khi đang tải ảnh
                                                );
                                              } else if (snapshot.hasError) {
                                                return const CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors
                                                      .grey, // Màu nền nếu có lỗi
                                                );
                                              } else if (snapshot.hasData) {
                                                return CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: snapshot
                                                      .data, // Hiển thị ảnh người đánh giá
                                                );
                                              } else {
                                                return const CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors
                                                      .grey, // Màu nền nếu không có ảnh
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Hiển thị tên người đánh giá
                                                Text(
                                                  review.reviewerName ??
                                                      'Anonymous',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                RatingBar.readOnly(
                                                  size: 20.0,
                                                  initialRating:
                                                      review.rating ?? 0.0,
                                                  maxRating: 5,
                                                  filledIcon: Icons.star,
                                                  emptyIcon: Icons.star_border,
                                                  filledColor: Colors.amber,
                                                ),
                                                const SizedBox(height: 5),
                                                // Hiển thị nội dung đánh giá
                                                Text(
                                                  review.text ?? 'No comments',
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),

            // Customer Reviews
            // Customer Reviews
          ],
        ),
      ),
    );
  }
}
