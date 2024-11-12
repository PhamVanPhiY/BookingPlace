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
  BookListingScreen({super.key, this.posting});

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
    posting!.makeNewBooking(selectedDates, context).whenComplete(() {
      Get.back();
    });
  }

  calculateAmountForOverAllStay() {
    if (selectedDates.isEmpty) {
      return;
    }
    double totalPriceForAllNigths = selectedDates.length * posting!.price!;
    bookingPrice = totalPriceForAllNigths;
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
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
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
              height: MediaQuery.of(context).size.height / 2,
              child: (calendarWidgets.isEmpty)
                  ? Container()
                  : PageView.builder(
                      itemCount: calendarWidgets.length,
                      itemBuilder: (context, index) {
                        return calendarWidgets[index];
                      }),
            ),
            bookingPrice == 0.0
                ? MaterialButton(
                    onPressed: () {
                      calculateAmountForOverAllStay();
                    },
                    minWidth: double.infinity,
                    height: MediaQuery.of(context).size.height / 14,
                    color: Colors.green,
                    child: const Text(
                      'Proceed',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Container(),
            paymentResulut != ""
                ? MaterialButton(
                    onPressed: () {
                      Get.to(GuestHomeScreen());

                      setState(() {
                        paymentResulut = "";
                      });
                    },
                    minWidth: double.infinity,
                    height: MediaQuery.of(context).size.height / 14,
                    color: Colors.green,
                    child: const Text(
                      'Amout Faid Successfull',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Container(),
            bookingPrice == 0.0
                ? Container()
                : Platform.isIOS
                    ? ApplePayButton(
                        paymentConfiguration:
                            PaymentConfiguration.fromJsonString(
                                defaultApplePay),
                        paymentItems: [
                          PaymentItem(
                              label: 'Booking Amount',
                              amount: bookingPrice.toString(),
                              status: PaymentItemStatus.final_price),
                        ],
                        style: ApplePayButtonStyle.black,
                        width: double.infinity,
                        height: 50,
                        type: ApplePayButtonType.buy,
                        margin: const EdgeInsets.only(top: 15.0),
                        onPaymentResult: (result) {
                          print("Payment result = $result");
                          setState(() {
                            paymentResulut = result.toString();
                          });
                        },
                        loadingIndicator: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : GooglePayButton(
                        paymentConfiguration:
                            PaymentConfiguration.fromJsonString(
                                defaultGooglePay),
                        paymentItems: [
                          PaymentItem(
                              label: 'Total Amount',
                              amount: bookingPrice.toString(),
                              status: PaymentItemStatus.final_price),
                        ],
                        type: GooglePayButtonType.pay,
                        margin: const EdgeInsets.only(top: 15.0),
                        onPaymentResult: (result) {
                          print("Payment result = $result");
                          setState(() {
                            paymentResulut = result.toString();
                          });
                          _makeBooking();
                        },
                        loadingIndicator: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
          ],
        ),
      ),
    );
  }
}
// 7: 13