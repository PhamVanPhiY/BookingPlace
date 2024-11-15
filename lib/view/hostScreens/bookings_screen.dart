import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/view/widgets/calender_ui.dart';
import 'package:booking_place/view/widgets/posting_list_tile_ui.dart';
import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<DateTime> _bookedDated = [];
  List<DateTime> _allBookedDates = [];
  PostingModel? _selectedPosting;

  List<DateTime> _getSelectedDates() {
    return [];
  }

  _selectDate(DateTime date) {}

   selectAPosting(PostingModel posting) {
     _selectedPosting = posting;
    // posting.getAllBookingsFromFirestore().whenComplete((){
      _bookedDated=posting.getAllBookedDates();
    // });
    // _selectedPosting = posting;
    // _bookedDated = _selectedPosting!.getAllBookedDates();
    setState(() {});
  }

  _clearSelectedPosting() {
    _bookedDated = _allBookedDates;
    _selectedPosting = null;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bookedDated = AppConstants.currentUser!.getAllBookedDates();
    _allBookedDates = AppConstants.currentUser.getAllBookedDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Text('Sun'),
                  Text('Mon'),
                  Text('Tues'),
                  Text('Wed'),
                  Text('Thur'),
                  Text('Fri'),
                  Text('Sat'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 35),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: PageView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return CalenderUi(
                        monthIndex: index,
                        bookedDates: _bookedDated,
                        selectDate: _selectDate,
                        getSelectedDates: _getSelectedDates,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 0, 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter by Listing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MaterialButton(
                      onPressed: _clearSelectedPosting,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Display host listings
              AppConstants.currentUser.myPostings != null &&
                  AppConstants.currentUser.myPostings!.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: AppConstants.currentUser.myPostings!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 26.0),
                    child: InkResponse(
                      onTap: () {
                        selectAPosting(
                            AppConstants.currentUser.myPostings![index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedPosting ==
                                AppConstants.currentUser
                                    .myPostings![index]
                                ? Colors.blue
                                : Colors.grey,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: PostingListTileUi(
                          posting: AppConstants.currentUser
                              .myPostings![index],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text("No postings available"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
