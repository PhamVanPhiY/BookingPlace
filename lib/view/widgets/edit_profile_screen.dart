import 'dart:typed_data';
import 'package:booking_place/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  late MemoryImage _newProfileImage;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.user.firstName ?? '';
    lastNameController.text = widget.user.lastName ?? '';
    bioController.text = widget.user.bio ?? '';
    cityController.text = widget.user.city ?? '';
    countryController.text = widget.user.country ?? '';
    _newProfileImage = widget.user.displayImage ??
        MemoryImage(Uint8List(0)); // Khởi tạo với ảnh mặc định
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút sửa ảnh
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final imageBytes = await pickedFile.readAsBytes();
                      setState(() {
                        _newProfileImage = MemoryImage(imageBytes);
                      });
                    }
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: _newProfileImage.bytes.isNotEmpty
                            ? _newProfileImage
                            : MemoryImage(Uint8List(0)), // Ảnh mặc định
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30), // Giãn cách lớn hơn giữa các trường
              // Trường nhập First Name
              _buildTextField(
                controller: firstNameController,
                label: 'First Name',
                onChanged: (value) {
                  widget.user.firstName = value;
                },
              ),
              SizedBox(height: 20), // Giãn cách lớn hơn giữa các trường
              // Trường nhập Last Name
              _buildTextField(
                controller: lastNameController,
                label: 'Last Name',
                onChanged: (value) {
                  widget.user.lastName = value;
                },
              ),
              SizedBox(height: 20), // Giãn cách lớn hơn giữa các trường
              // Trường nhập Bio
              _buildTextField(
                controller: bioController,
                label: 'Bio',
                onChanged: (value) {
                  widget.user.bio = value;
                },
              ),
              SizedBox(height: 20), // Giãn cách lớn hơn giữa các trường
              // Trường nhập City
              _buildTextField(
                controller: cityController,
                label: 'City',
                onChanged: (value) {
                  widget.user.city = value;
                },
              ),
              SizedBox(height: 20), // Giãn cách lớn hơn giữa các trường
              // Trường nhập Country
              _buildTextField(
                controller: countryController,
                label: 'Country',
                onChanged: (value) {
                  widget.user.country = value;
                },
              ),
              SizedBox(height: 30),
              // Nút lưu thay đổi
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    // Lưu thông tin người dùng vào Firestore
                    await widget.user.saveUserToFirestore();

                    // Kiểm tra nếu ảnh đã thay đổi
                    if (_newProfileImage != widget.user.displayImage) {
                      // Cập nhật ảnh nếu có thay đổi
                      await widget.user.updateProfileImage(_newProfileImage);
                    }

                    // Thông báo cập nhật thành công
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profile updated successfully!')));
                    Navigator.pop(context); // Quay lại trang trước
                  },
                  child: Text('Save Changes', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field widget with styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurpleAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
