import 'package:booking_place/global.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/view/guest_home_screen.dart';
import 'package:booking_place/view/host_home_screen.dart';
import 'package:booking_place/view/widgets/edit_profile_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // User info section
              Center(
                child: Column(
                  children: [
                    MaterialButton(
                      onPressed: () {},
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 70,
                        child: CircleAvatar(
                          backgroundImage:
                              AppConstants.currentUser.displayImage,
                          radius: 68,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Name and email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.currentUser.getFullNameOfUser(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppConstants.currentUser.email.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Buttons List
              Column(
                children: [
                  _buildListTile(
                    title: "Personal Information",
                    icon: Icons.person_2,
                    onTap: () {
                      // Mở trang chỉnh sửa thông tin người dùng
                      Get.to(() =>
                          EditProfileScreen(user: AppConstants.currentUser));
                    },
                  ),
                  _buildListTile(
                    title: _hostingTitle,
                    icon: Icons.hotel_outlined,
                    onTap: () {
                      modifyHostingMode();
                      setState(() {});
                    },
                  ),
                  _buildListTile(
                    title: "Log Out",
                    icon: Icons.logout_outlined,
                    onTap: () {
                      userViewModel.logout();
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom widget for list tiles with better design
  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        color: Colors.white,
      ),
      child: MaterialButton(
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: ListTile(
          contentPadding: EdgeInsets.all(0.0),
          leading: Icon(
            icon,
            color: Colors.deepPurpleAccent,
            size: 30,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.deepPurpleAccent,
            size: 20,
          ),
        ),
      ),
    );
  }
}
