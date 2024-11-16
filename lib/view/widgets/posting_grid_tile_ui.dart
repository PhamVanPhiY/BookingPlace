import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';

class PostingGridTileUi extends StatefulWidget {
  PostingModel? posting;

  PostingGridTileUi({super.key, this.posting});

  @override
  State<PostingGridTileUi> createState() => _PostingGridTileUiState();
}

class _PostingGridTileUiState extends State<PostingGridTileUi> {
  PostingModel? posting;

  updateUI() async {
    await posting!.getFirstImageFromStorage();
  }

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.all(8.0), // Đặt khoảng cách xung quanh mỗi bài đăng
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng
        borderRadius: BorderRadius.circular(12), // Bo góc cho phần tử
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Đổ bóng nhẹ
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // Đặt bóng hướng xuống dưới
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
                ? Container() // Nếu không có ảnh thì không hiển thị gì
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Bo góc ảnh
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: posting!.displayImage!.first,
                          fit: BoxFit.cover, // Phù hợp với không gian
                        ),
                      ),
                    ),
                  ),
          ),
          // Thông tin bài đăng
          Padding(
            padding: const EdgeInsets.all(8.0), // Khoảng cách cho các thông tin
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${posting!.type} - ${posting!.city}, ${posting!.country}",
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700], // Màu xám cho thông tin phụ
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
                    color: Colors.green[700], // Màu xanh cho giá tiền
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    RatingBar.readOnly(
                      size: 20.0,
                      maxRating: 5,
                      initialRating: posting!.getCurrentRating(),
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      filledColor: Colors.amber, // Màu vàng cho rating
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
