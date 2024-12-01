import 'package:flutter/material.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardGridUI extends StatefulWidget {
  PostingModel? posting;
  CardGridUI({super.key, this.posting});

  @override
  State<CardGridUI> createState() => _CardGridUIState();
}

class _CardGridUIState extends State<CardGridUI> {
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
    return Stack(
      children: [
        // Background Image
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(posting!.imageNames![0]),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1), // Màu tối ở trên
                  Colors.transparent, // Trong suốt ở giữa
                  Colors.black.withOpacity(0.3), // Màu tối ở dưới
                ],
                stops: [
                  0.0,
                  0.5,
                  1.0
                ], // Điều chỉnh độ mờ của các phần trên và dưới
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ), // Overlay with content
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        // Rating and Price at the top
        Positioned(
          top: 2,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    posting?.rating?.toStringAsFixed(1) ?? '0.0',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Text(
                '\$${posting!.price}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 2,
          left: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Name with ellipsis
              Text(
                posting!.name!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Text(
                posting!.address!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis, // Cắt ngắn nếu dài quá
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
