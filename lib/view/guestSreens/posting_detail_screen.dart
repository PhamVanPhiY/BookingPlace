import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostingDetailScreen extends StatefulWidget {
  final PostingModel posting;

  const PostingDetailScreen({super.key, required this.posting});

  @override
  _PostingDetailScreenState createState() => _PostingDetailScreenState();
}

class _PostingDetailScreenState extends State<PostingDetailScreen> {
  double rating = 3; // Khởi tạo giá trị rating mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(widget.posting.name ?? 'Unknown'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh
            // Hình ảnh
            FutureBuilder<dynamic>(
              future: widget.posting
                  .getFirstImageFromStorage(), // Hàm này vẫn giữ nguyên
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, size: 50);
                } else if (!snapshot.hasData) {
                  return Icon(Icons.image_not_supported, size: 50);
                } else {
                  // Kiểm tra và ép kiểu giá trị trả về
                  var image = snapshot.data;
                  if (image is MemoryImage) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                        ),
                      ),
                    );
                  } else {
                    // Xử lý khi dữ liệu không phải kiểu MemoryImage
                    return Icon(Icons.image_not_supported, size: 50);
                  }
                }
              },
            ),

            // Địa chỉ
            Text(
              widget.posting.getFullAddress(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 8),

            // Mô tả
            Text(
              'Description: ${widget.posting.description ?? 'No description available'}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 12),

            // Đánh giá
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 5),
                Text(
                  widget.posting.getCurrentRating().toStringAsFixed(1),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Ngày có sẵn
            Text(
              'Available Dates: ${widget.posting.getAllBookedDates().map((e) => e.toString().split(' ')[0]).join(', ')}',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),

            // Nút thêm bình luận
            ElevatedButton(
              onPressed: () {
                _showCommentDialog(context);
              },
              child: Text('Add a Comment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tính toán rating trung bình và cập nhật giá trị rating cho posting
  Future<void> _updateAverageRating() async {
    // Lấy tất cả reviews từ Firestore
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('postings')
        .doc(widget.posting.id)
        .collection('reviews')
        .get();

    // Tính tổng số sao và số lượng reviews
    double totalRating = 0;
    int reviewCount = reviewsSnapshot.docs.length;

    for (var doc in reviewsSnapshot.docs) {
      totalRating += doc['rating']; // Lấy rating từ từng review
    }

    // Tính trung bình
    double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0;

    // Làm tròn rating trung bình về số nguyên gần nhất
    int roundedRating = averageRating.round();

    // Cập nhật rating trung bình cho posting
    await FirebaseFirestore.instance
        .collection('postings')
        .doc(widget.posting.id)
        .update({
      'rating': roundedRating, // Cập nhật giá trị rating đã làm tròn
    });
  }

  // Hộp thoại thêm đánh giá
  void _showCommentDialog(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    double rating = 3; // Khởi tạo giá trị rating mặc định

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add a Comment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TextField để nhập bình luận
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Your Comment',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 15),

                  // Hiển thị các sao cho người dùng chọn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index +
                                1; // Cập nhật rating khi người dùng nhấn sao
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 15),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Lấy tên đầy đủ của người đánh giá bằng phương thức getFullNameOfUser
                    String reviewerName =
                        AppConstants.currentUser!.getFullNameOfUser();

                    // Tạo ReviewModel
                    ReviewModel review = ReviewModel(
                      contact: await AppConstants.currentUser!
                          .getContactInfoFromFirestore(),
                      text: commentController.text,
                      rating: rating,
                      dateTime: DateTime.now(),
                      reviewerName: reviewerName, // Lưu tên người đánh giá
                    );

                    // Lưu vào Firestore (reviews collection)
                    await FirebaseFirestore.instance
                        .collection('postings')
                        .doc(widget.posting.id)
                        .collection('reviews')
                        .add(review.toMap());

                    // Tính toán rating trung bình của posting
                    await _updateAverageRating();

                    // Đóng hộp thoại và hiển thị thông báo
                    Navigator.pop(context);
                    Get.snackbar("Review", "Your review has been submitted!");
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
