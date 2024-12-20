import 'package:booking_place/view/guestSreens/account_screen.dart';
import 'package:booking_place/view/guestSreens/explore_screen.dart';
import 'package:booking_place/view/guestSreens/inbox_screen.dart';
import 'package:booking_place/view/guestSreens/saved_listing_screen.dart';
import 'package:booking_place/view/guestSreens/trips_screen.dart';
import 'package:booking_place/view/hostScreens/bookings_screen.dart';
import 'package:booking_place/view/hostScreens/my_postings_screen.dart';
import 'package:flutter/material.dart';

class HostHomeScreen extends StatefulWidget {
  int? index;
  HostHomeScreen({super.key, this.index});

  @override
  State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen> {
  int selectedIndex = 0;
  final List<String> screenTitles = [
    'Booking',
    'My Posting',
    'Inbox',
    'Profile',
  ];
  final List<Widget> screens = [
    BookingsScreen(),
    MyPostingsScreen(),
    InboxScreen(),
    AccountScreen(),
  ];
  BottomNavigationBarItem customNavigationBarItem(
      int index, IconData iconData, String title) {
    return BottomNavigationBarItem(
      icon: Icon(
        iconData,
        color: Colors.black,
      ),
      activeIcon: Icon(
        iconData,
        color: Colors.deepPurple,
      ),
      label: title,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.index ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(26, 220, 133, 133),
                    Color.fromARGB(255, 241, 100, 100)
                  ],
                  begin: FractionalOffset(0, 0),
                  end: FractionalOffset(1, 0),
                  stops: [0, 1],
                  tileMode: TileMode.clamp)),
        ),
        title: Text(
          screenTitles[selectedIndex],
          style: TextStyle(
              fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          customNavigationBarItem(0, Icons.calendar_today, screenTitles[0]),
          customNavigationBarItem(1, Icons.home, screenTitles[1]),
          customNavigationBarItem(2, Icons.message, screenTitles[2]),
          customNavigationBarItem(3, Icons.person_outline, screenTitles[3]),
        ],
      ),
    );
  }
}
