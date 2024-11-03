import 'package:booking_place/global.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/view/guest_home_screen.dart';
import 'package:booking_place/view/host_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hostingTitle = 'Show my Host Dashboard';
  modifyHostingMode() async {
    if (AppConstants.currentUser.isHost!) {
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        AppConstants.currentUser.isCurrentlyHosting = false;
        Get.to(GuestHomeScreen());
      } else {
        AppConstants.currentUser.isCurrentlyHosting = true;
        Get.to(HostHomeScreen());
      }
    } else {
      await userViewModel.becomeHost(FirebaseAuth.instance.currentUser!.uid);
      AppConstants.currentUser.isCurrentlyHosting = true;
      Get.to(HostHomeScreen());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (AppConstants.currentUser.isHost!) {
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        _hostingTitle = 'Show my Guest Dashboard';
      } else {
        _hostingTitle = 'Show my Host Dashboard';
      }
    } else {
      _hostingTitle = 'Become a host';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 50, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //user info

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                child: Column(
                  children: [
                    MaterialButton(
                      onPressed: () {},
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: MediaQuery.of(context).size.width / 4.5,
                        child: CircleAvatar(
                          backgroundImage:
                              AppConstants.currentUser.displayImage,
                          radius: MediaQuery.of(context).size.width / 4.6,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // name and email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.currentUser.getFullNameOfUser(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          AppConstants.currentUser.email.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,

              //buttons
              children: [
                // Personal Information button
                Container(
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
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.0,
                    onPressed: () {},
                    child: const ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        size: 34,
                        Icons.person_2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                // Change hosting button
                Container(
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
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.0,
                    onPressed: () {
                      modifyHostingMode();
                      setState(() {
                        
                      });
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Text(
                        _hostingTitle,
                        style: const TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: const Icon(
                        size: 34,
                        Icons.hotel_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                // Logout button
                Container(
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
                  child: MaterialButton(
                    height: MediaQuery.of(context).size.height / 9.0,
                    onPressed: () {},
                    child: const ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      leading: Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        size: 34,
                        Icons.logout_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
