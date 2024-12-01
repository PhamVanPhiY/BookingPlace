import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/view/view_posting_screen.dart';
import 'package:booking_place/view/widgets/posting_grid_tile_ui.dart';
import 'package:booking_place/view/widgets/card_grid_UI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController controllerSearch = TextEditingController();
  Stream stream = FirebaseFirestore.instance.collection('postings').snapshots();
  String searchType = "";
  String? selectedType;
  String? selectedPriceRange;

  bool isNameButtonSelected = false;
  bool isTypeButtonSelected = false;
  bool isPriceButtonSelected = false;

  final List<String> types = [
    'Detached House',
    'Villa',
    'Apartment',
    'Flat',
    'Town house',
    'Studio'
  ];

  final List<String> priceRanges = [
    '50 - 100\$',
    '100 - 250\$',
    '250\$ and above'
  ];

  searchByField() {
    setState(() {
      stream = FirebaseFirestore.instance.collection('postings').snapshots();
    });
  }

  pressSearchByButton(String searchTypeStr, bool isNameButtonSelectedB,
      bool isTypeButtonSelectedB, bool isPriceButtonSelectedB) {
    setState(() {
      searchType = searchTypeStr;
      isNameButtonSelected = isNameButtonSelectedB;
      isTypeButtonSelected = isTypeButtonSelectedB;
      isPriceButtonSelected = isPriceButtonSelectedB;
    });
  }

  // Reset everything when Clear button is pressed
  clearSearch() {
    setState(() {
      controllerSearch.clear();
      selectedType = null;
      selectedPriceRange = null;
      stream = FirebaseFirestore.instance
          .collection('postings')
          .snapshots(); // Reset stream
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 15, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Tìm kiếm theo tên
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0),
              child: TextField(
                decoration: const InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(5.0)),
                style: const TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
                controller: controllerSearch,
                onChanged: (text) {
                  searchByField(); // Cập nhật khi thay đổi từ khóa tìm kiếm
                },
              ),
            ),
            // Các nút tìm kiếm theo thể loại và giá
            SizedBox(
              height: 48,
              width: MediaQuery.of(context).size.width / .5,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                children: [
                  MaterialButton(
                    onPressed: () async {
                      pressSearchByButton("type", false, true, false);
                      // Hiển thị một danh sách các thể loại
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Select Type"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: types
                                .map((type) => ListTile(
                                      title: Text(type),
                                      onTap: () {
                                        setState(() {
                                          selectedType = type;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color:
                        isTypeButtonSelected ? Colors.pinkAccent : Colors.white,
                    child: const Text("Type"),
                  ),
                  const SizedBox(width: 6),
                  MaterialButton(
                    onPressed: () async {
                      pressSearchByButton("price", false, false, true);
                      // Hiển thị một danh sách khoảng giá
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Select Price Range"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: priceRanges
                                .map((range) => ListTile(
                                      title: Text(range),
                                      onTap: () {
                                        setState(() {
                                          selectedPriceRange = range;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: isPriceButtonSelected
                        ? Colors.pinkAccent
                        : Colors.white,
                    child: const Text("Price"),
                  ),
                  const SizedBox(width: 6),
                  MaterialButton(
                    onPressed: () {
                      clearSearch(); // Reset everything
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: const Text("Clear"),
                  ),
                ],
              ),
            ),
            // Hiển thị danh sách tìm kiếm
            StreamBuilder(
              stream: stream,
              builder: (context, datasnapshots) {
                if (datasnapshots.hasData) {
                  var filteredPostings =
                      datasnapshots.data.docs.where((snapshot) {
                    // Tìm theo tên
                    if (controllerSearch.text.isNotEmpty &&
                        !snapshot['name']
                            .toLowerCase()
                            .contains(controllerSearch.text.toLowerCase())) {
                      return false;
                    }
                    // Tìm theo thể loại
                    if (selectedType != null &&
                        snapshot['type'] != selectedType) {
                      return false;
                    }
                    // Tìm theo khoảng giá
                    if (selectedPriceRange != null) {
                      double price = snapshot['price'];
                      if (selectedPriceRange == '50 - 100\$' &&
                          (price < 50 || price > 100)) {
                        return false;
                      } else if (selectedPriceRange == '100 - 250\$' &&
                          (price < 100 || price > 250)) {
                        return false;
                      } else if (selectedPriceRange == '250\$ and above' &&
                          price < 250) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  return GridView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredPostings.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 15,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot snapshot = filteredPostings[index];
                      PostingModel cPosting = PostingModel(id: snapshot.id);
                      cPosting.getPostingInfoFromSnapshot(snapshot);
                      return InkResponse(
                        onTap: () {
                          Get.to(ViewPostingScreen(
                            posting: cPosting,
                          ));
                        },
                        enableFeedback: true,
                        child: CardGridUI(posting: cPosting),
                        //     HotelCard(
                        //   imageUrl:
                        //       "https://path/to/your/image.png", // URL ảnh của khách sạn
                        //   hotelName: "Intercontinental Da Nang",
                        //   location: "Viet Nam",
                        //   rating: 5,
                        //   price: 450.0,
                        // ),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
