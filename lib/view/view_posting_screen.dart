import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:booking_place/view/guestSreens/book_listing_screen.dart';
import 'package:booking_place/view/widgets/posting_info_tile_ui.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.amber],
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
                  MemoryImage currentImage = posting!.displayImage![index];
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
                          posting!.name!.toUpperCase(),
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
                            child: const Text('Book Now'),
                          ),
                          Text(
                            '\$${posting!.price} / night',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          posting!.description!,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: posting!.host!.displayImage,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            posting!.host!.getFullNameOfUser(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Text(
                    "Address: ${posting!.address ?? 'No address available'}",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Amenities Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, // Khoảng cách ngang giữa các item
                    runSpacing: 8, // Khoảng cách dọc giữa các dòng
                    children: List.generate(
                      posting!.amenities!.length,
                      (index) => Chip(
                        label: Text(
                          posting!.amenities![index],
                          style: const TextStyle(
                              fontSize: 14), // Kích thước chữ vừa phải
                        ),
                        backgroundColor: Colors.amber.shade50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6), // Padding trong mỗi chip
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Customer Reviews
            // Customer Reviews
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews
                              .length, // Lấy danh sách đánh giá từ Firestore
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
            )
          ],
        ),
      ),
    );
  }
}
