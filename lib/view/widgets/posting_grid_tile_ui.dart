import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostingGridTileUi extends StatefulWidget {
  PostingModel? posting;

  PostingGridTileUi({super.key, this.posting});

  @override
  State<PostingGridTileUi> createState() => _PostingGridTileUiState();
}

class _PostingGridTileUiState extends State<PostingGridTileUi> {
  PostingModel? posting;

  updateUI() async {
    await posting!.getFirstImageFromFirestore();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    updateUI();
  }

  // Hàm lấy rating từ Firestore
  Future<double> _getRatingFromFirestore() async {
    if (posting != null) {
      try {
        // Lấy rating từ Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('postings')
            .doc(posting!.id)
            .get();

        if (snapshot.exists) {
          // Kiểm tra xem rating có tồn tại và lấy giá trị
          if (snapshot['rating'] != null) {
            double rating = snapshot['rating'].toDouble();
            return rating.roundToDouble(); // Làm tròn rating
          } else {
            return 0.0;
          }
        } else {
          return 0.0;
        }
      } catch (e) {
        print("Error getting rating: $e");
        return 0.0; // Trả về rating mặc định khi có lỗi
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _getRatingFromFirestore(), // Gọi phương thức lấy rating
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Hiển thị khi đang tải
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          double currentRating =
              snapshot.data!; // Cập nhật rating khi có dữ liệu

          // Số lượng ngôi sao cần hiển thị (làm tròn rating)
          int fullStars = currentRating.toInt();
          bool hasHalfStar = currentRating - fullStars >= 0.5;

          return Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh của bài đăng
                AspectRatio(
                  aspectRatio: 3 / 2,
                  child: (posting!.displayImage!.isEmpty)
                      ? Image.asset(
                          'assets/images/default_image.png') // Ảnh mặc định nếu không có ảnh
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: posting!.displayImage!.first,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                ),

                // Thông tin bài đăng
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${posting!.type} - ${posting!.city}, ${posting!.country}",
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        posting!.name!,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${posting!.price} / night',
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 6),
                      // Hiển thị rating dưới dạng ngôi sao
                      Row(
                        children: [
                          for (int i = 0; i < fullStars; i++)
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          if (hasHalfStar)
                            Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 20,
                            ),
                          for (int i = fullStars + (hasHalfStar ? 1 : 0);
                              i < 5;
                              i++)
                            Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('No rating data available'));
        }
      },
    );
  }
}
