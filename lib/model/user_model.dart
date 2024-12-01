import 'package:booking_place/model/booking_model.dart';
import 'package:booking_place/model/contact_model.dart';
import 'package:booking_place/model/conversation_model.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/model/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_constants.dart';

class UserModel extends ContactModel {
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  bool? isHost;
  bool? isCurrentlyHosting;
  DocumentSnapshot? snapshot;
  String? linkImageUser;

  List<BookingModel>? bookings;
  List<ReviewModel>? reviews;

  List<PostingModel>? savedPostings;
  List<PostingModel>? myPostings;

  UserModel({
    String id = "",
    String firstName = "",
    String lastName = "",
    // MemoryImage? displayImage,
    this.linkImageUser = "",
    this.email = "",
    this.bio = "",
    this.city = "",
    this.country = "",
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          // displayImage: displayImage
          //
        ) {
    isHost = false;
    isCurrentlyHosting = false;
    bookings = [];
    reviews = [];
    savedPostings = [];
    myPostings = [];
  }

// Lấy thông tin người dùng từ Firestore
  Future<void> getUserInfoFromFirestore() async {
    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection("users").doc(id).get();

      // Kiểm tra nếu người dùng tồn tại trong Firestore
      if (userSnapshot.exists) {
        // Cập nhật các thông tin cơ bản của người dùng
        email = userSnapshot["email"];
        bio = userSnapshot["bio"];
        city = userSnapshot["city"];
        country = userSnapshot["country"];
        linkImageUser = userSnapshot["linkImageUser"];

        // Lấy URL ảnh từ Firestore và tải ảnh
        /* String? profileImageUrl = userSnapshot["profileImageUrl"];
        if (profileImageUrl != null) {
          // Tải ảnh từ URL Firebase Storage và chuyển thành MemoryImage
          final imageBytes =
              await NetworkAssetBundle(Uri.parse(profileImageUrl))
                  .load(profileImageUrl);
          displayImage = MemoryImage(imageBytes.buffer.asUint8List());
        }*/
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserToFirestore() async {
    Map<String, dynamic> dataMap = {
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "isHost": false,
      "myPostingIDs": [],
      "savePostingIDs": [],
      "earnings": 0
    };

    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }

  // Thêm bài đăng vào danh sách bài đăng của người dùng
  addPostingToMyPostings(PostingModel posting) async {
    myPostings!.add(posting);
    List<String> myPostingIDsList = [];
    myPostings!.forEach((element) {
      myPostingIDsList.add(element.id!);
    });
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'myPostingIDs': myPostingIDsList,
    });
  }

  // Phương thức này sẽ tải ảnh lên Firebase Storage và cập nhật thông tin người dùng trong Firestore
  // Phương thức tải ảnh mới lên Firebase Storage và cập nhật Firestore
  Future<void> updateProfileImage(MemoryImage newImage) async {
    try {
      // Tải ảnh lên Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/${id}.jpg');
      final uploadTask = storageRef.putData(newImage.bytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cập nhật URL của ảnh trong Firestore
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'profileImageUrl': downloadUrl,
      });

      // Cập nhật ảnh đại diện trong UserModel
      // displayImage = newImage;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  // Lấy tất cả bài đăng của người dùng từ Firestore
  getMyPostingsFromFirestore() async {
    List<String> myPostingIDs =
        List<String>.from(snapshot!["myPostingIDs"]) ?? [];

    for (String postingID in myPostingIDs) {
      PostingModel posting = PostingModel(id: postingID);
      await posting.getPostingInfoFromFirestore();
      await posting.getAllBookingsFromFirestore();
      //await posting.getAllImagesFromStorage();
      myPostings!.add(posting);
    }
  }

  // Thêm bài đăng vào danh sách yêu thích của người dùng
  addSavedPosting(PostingModel posting) async {
    for (var savedPosting in savedPostings!) {
      if (savedPosting.id == posting.id) {
        return;
      }
    }
    savedPostings!.add(posting);
    List<String> savePostingIDs = [];
    savedPostings!.forEach((savedPosting) {
      savePostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savePostingIDs': savePostingIDs,
    });
    Get.snackbar("Marked as Favourite", "Saved to your Favourite List");
  }

  // Xóa bài đăng khỏi danh sách yêu thích của người dùng
  removeSavedPostings(PostingModel posting) async {
    for (int i = 0; i < savedPostings!.length; i++) {
      if (savedPostings![i].id == posting.id) {
        savedPostings!.removeAt(i);
        break;
      }
    }

    List<String> savePostingIDs = [];
    savedPostings!.forEach((savedPosting) {
      savePostingIDs.add(savedPosting.id!);
    });

    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'savePostingIDs': savePostingIDs,
    });
    Get.snackbar(
        "Listings Removed", "Listings removed from your Favourite List");
  }

  // Thêm cuộc hẹn vào Firestore
  Future<void> addBookingToFirestore(BookingModel booking,
      double totalPriceForAllNigths, String hostID) async {
    String earningsOld = "";

    print("Starting to fetch earnings for hostID: $hostID");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(hostID)
        .get()
        .then((dataSnap) {
      earningsOld = dataSnap["earnings"].toString();
      print("Fetched earningsOld: $earningsOld");
    }).catchError((error) {
      print("Error fetching earnings: $error");
    });

    Map<String, dynamic> data = {
      'dates': booking.dates,
      'postingID': booking.posting!.id!,
    };

    print("Data to be added to bookings: $data");

    try {
      String? id = AppConstants.currentUser.id; // Thay thế bằng logic lấy `id`
      print(
          "Adding booking to Firestore at path: users/$id/bookings/${booking.id}");
      await FirebaseFirestore.instance
          .doc('users/${id}/bookings/${booking.id}')
          .set(data);
      print("Booking added successfully.");
    } catch (error) {
      print("Error adding booking: $error");
    }

    try {
      print("Updating earnings for hostID: $hostID");
      await FirebaseFirestore.instance.collection("users").doc(hostID).update({
        "earnings": totalPriceForAllNigths + double.parse(earningsOld),
      });
      print("Earnings updated successfully.");
    } catch (error) {
      print("Error updating earnings: $error");
    }

    try {
      bookings!.add(booking);
      print("Booking added to local list.");
      await addBookingConversation(booking);
      print("Booking conversation added successfully.");
    } catch (error) {
      print("Error in addBookingConversation or local list: $error");
    }
  }

  // Lấy tất cả các ngày đã đặt trong các bài đăng của người dùng
  List<DateTime> getAllBookedDates() {
    List<DateTime> allBookedDates = [];
    myPostings!.forEach((posting) {
      posting.bookings!.forEach((booking) {
        allBookedDates.addAll(booking.dates!);
      });
    });
    return allBookedDates;
  }

  // Tạo cuộc trò chuyện khi đặt phòng
  addBookingConversation(BookingModel booking) async {
    ConversationModel conversation = ConversationModel();

    // Thêm log để kiểm tra quá trình thêm cuộc trò chuyện
    print("Đang thêm cuộc trò chuyện với host: ${booking.posting!.host!}");

    await conversation
        .addConversationToFirebase(booking.posting!.host!)
        .then((_) {
      print("Thêm cuộc trò chuyện thành công");
    }).catchError((error) {
      print("Lỗi khi thêm cuộc trò chuyện: $error");
    });

    String textMessage =
        "Hi my name is ${AppConstants.currentUser!.firstName} and I have "
        "just booked ${booking.posting!.name} from ${booking.dates!.first} to "
        "${booking.dates!.last} if you have any questions contact me. Enjoy your"
        "stay!";

    // Thêm log để kiểm tra quá trình thêm tin nhắn
    print("Đang thêm tin nhắn: $textMessage");

    await conversation.addMessageToFirestore(textMessage).then((_) {
      print("Thêm tin nhắn thành công");
    }).catchError((error) {
      print("Lỗi khi thêm tin nhắn: $error");
    });
  }

  // Tạo đối tượng ContactModel từ UserModel
  createContactFromUser() {
    return ContactModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      // displayImage: displayImage,
    );
  }

  // Lấy tất cả các booking của người dùng từ Firestore
  Future<void> getAllBookingsFromUser() async {
    // Tạo danh sách để lưu trữ các posting
    List<PostingModel> userPostings = [];

    // Truy vấn tất cả các booking của user từ Firestore
    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id) // ID người dùng
        .collection('bookings') // Thư mục chứa các booking
        .get();

    // Lặp qua tất cả các booking để lấy thông tin về posting
    for (var bookingDoc in bookingSnapshot.docs) {
      // Lấy thông tin booking
      BookingModel booking = BookingModel();
      booking.id = bookingDoc.id;
      booking.dates = List<DateTime>.from(
          bookingDoc['dates'].map((e) => (e as Timestamp).toDate()));
      String postingID = bookingDoc['postingID'];

      // Truy vấn posting từ ID của nó
      DocumentSnapshot postingSnapshot = await FirebaseFirestore.instance
          .collection(
              'postings') // Giả sử postings được lưu trong collection 'postings'
          .doc(postingID)
          .get();

      // Lấy thông tin PostingModel từ dữ liệu Firestore
      PostingModel posting = PostingModel(id: postingSnapshot.id);
      await posting
          .getPostingInfoFromFirestore(); // Giả sử bạn có phương thức này để lấy thông tin chi tiết về posting

      // Thêm posting vào danh sách
      userPostings.add(posting);
    }

    // Lưu tất cả các posting đã đặt vào biến myPostings của user
    myPostings = userPostings;

    // Bạn có thể làm gì đó với danh sách này, ví dụ hiển thị nó trên UI.
    print('All bookings for user ${id}:');
    for (var posting in userPostings) {
      print(posting.name); // In ra tên của từng posting
    }
  }
}
