import 'dart:io';

import 'package:booking_place/global.dart';
import 'package:booking_place/model/posting_model.dart';
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
                : Platform.isIOS
                    ? ApplePayButton()
                    : GooglePayButton()
          ],
        ),
      ),
    );
  }
}
