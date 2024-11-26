import 'dart:io';

import 'package:booking_place/global.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/payment-gateway/payment_config.dart';
import 'package:booking_place/view/guest_home_screen.dart';
import 'package:booking_place/view/widgets/calender_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pay/pay.dart';

class BookListingScreen extends StatefulWidget {
  PostingModel? posting;
  String? hostID;
  BookListingScreen({super.key, this.posting, this.hostID});

  @override
  State<BookListingScreen> createState() => _BookListingScreenState();
}

class _BookListingScreenState extends State<BookListingScreen> {
  PostingModel? posting;
  List<DateTime> bookedDates = [];
  List<DateTime> selectedDates = [];
  List<CalenderUi> calendarWidgets = [];

  _buildCalenderWidgets() {
    for (int i = 0; i < 12; i++) {
      calendarWidgets.add(CalenderUi(
        monthIndex: i,
        bookedDates: bookedDates,
        selectDate: _selectDate,
        getSelectedDates: _getSelectedDates,
      ));
      setState(() {});
    }
  }

  List<DateTime> _getSelectedDates() {
    return selectedDates;
  }

  _selectDate(DateTime date) {
    if (selectedDates.contains(date)) {
      selectedDates.remove(date);
    } else {
      selectedDates.add(date);
    }
    selectedDates.sort();
    calculateAmountForOverAllStay(); // Gọi để cập nhật tổng chi phí
    setState(() {});
  }

  _loadBookedDates() {
    posting!.getAllBookingsFromFirestore().whenComplete(() {
      bookedDates = posting!.getAllBookedDates();
      _buildCalenderWidgets();
    });
  }

  _makeBooking() {
    if (selectedDates.isEmpty) {
      return;
    }
    posting!
        .makeNewBooking(selectedDates, context, widget.hostID)
        .whenComplete(() {
      Get.back();
    });
  }

  calculateAmountForOverAllStay() {
    if (selectedDates.isEmpty) {
      return;
    }
    DateTime checkInDate = selectedDates.first;
    DateTime checkOutDate = selectedDates.last
        .add(Duration(days: 1)); // Thêm 1 ngày cho ngày check-out
    int numberOfNights = checkOutDate.difference(checkInDate).inDays;

    // Tính tổng chi phí
    double totalPriceForAllNights = numberOfNights * posting!.price!;
    bookingPrice = totalPriceForAllNights;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    posting = widget.posting;
    _loadBookedDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.pinkAccent,
              Colors.amber,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: Text(
          "Book ${posting!.name}",
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Sun'),
                  Text('Mon'),
                  Text('Tues'),
                  Text('Wed'),
                  Text('Thur'),
                  Text('Fri'),
                  Text('Sat'),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.25,
                child: (calendarWidgets.isEmpty)
                    ? Container()
                    : PageView.builder(
                        itemCount: calendarWidgets.length,
                        itemBuilder: (context, index) {
                          return calendarWidgets[index];
                        }),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phần Image và thông tin khác
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              posting!.displayImage![
                                  0], // Lấy URL từ Firebase hoặc danh sách dữ liệu
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return const Icon(Icons
                                    .error); // Hiển thị icon lỗi nếu không tải được ảnh
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  posting!.name!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  posting!.address!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '\$${posting!.price}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' USD /night',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Phần thông tin Check In, Check Out, Total Cost
                      SizedBox(
                          height:
                              12), // Khoảng cách giữa phần trên và phần dưới
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Căn giữa Row
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check In:',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold), // Tăng kích thước chữ
                              ),
                              Text(
                                'Check Out:',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold), // Tăng kích thước chữ
                              ),
                              Text(
                                'Total Cost:',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold), // Tăng kích thước chữ
                              ),
                            ],
                          ),
                          SizedBox(width: 50), // Khoảng cách giữa 2 Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${selectedDates.isNotEmpty ? selectedDates.first.toLocal().toString().split(' ')[0] : '2024/01/01'}',
                                style: TextStyle(
                                    fontSize: 16), // Tăng kích thước chữ
                              ),
                              Text(
                                '${selectedDates.isNotEmpty ? selectedDates.last.toLocal().toString().split(' ')[0] : '2024/01/01'}',
                                style: TextStyle(
                                    fontSize: 16), // Tăng kích thước chữ
                              ),
                              Text(
                                '\$${(bookingPrice ?? 0.0).toStringAsFixed(2)}', // Nếu bookingPrice là null, gán giá trị mặc định là 0.0
                                style: TextStyle(
                                    fontSize: 16), // Tăng kích thước chữ
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              paymentResulut == ""
                  ? ElevatedButton(
                      onPressed: () {
                        calculateAmountForOverAllStay(); // Tính toán số tiền
                        _makeBooking(); // Xử lý đặt phòng
                        Get.to(
                            GuestHomeScreen()); // Điều hướng tới màn hình chính của khách

                        setState(() {
                          paymentResulut = ""; // Đặt lại kết quả thanh toán
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Màu nền của nút
                        minimumSize: Size(
                            double.infinity,
                            MediaQuery.of(context).size.height /
                                14), // Kích thước của nút
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bo góc nút
                        ),
                      ),
                      child: const Text(
                        'Payment',
                        style: TextStyle(color: Colors.white), // Màu chữ trắng
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
// 7: 13