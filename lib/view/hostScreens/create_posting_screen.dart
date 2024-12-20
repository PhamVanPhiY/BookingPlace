import 'dart:io';

import 'package:booking_place/global.dart';
import 'package:booking_place/main.dart';
import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:booking_place/view/guest_home_screen.dart';
import 'package:booking_place/view/host_home_screen.dart';
import 'package:booking_place/view/widgets/amenities_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostingScreen extends StatefulWidget {
  PostingModel? posting;
  CreatePostingScreen({
    super.key,
    this.posting,
  });

  @override
  State<CreatePostingScreen> createState() => _CreatePostingScreenState();
}

class _CreatePostingScreenState extends State<CreatePostingScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _nameTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _descriptionTextEditingController =
      TextEditingController();
  TextEditingController _addressTextEditingController = TextEditingController();
  TextEditingController _cityTextEditingController = TextEditingController();
  TextEditingController _countryTextEditingController = TextEditingController();
  TextEditingController _amenitiesTextEditingController =
      TextEditingController();
  TextEditingController _imageUrlController =
      TextEditingController(); // Controller for image URL

  final List<String> residenceTypes = [
    'Detached House',
    'Villa',
    'Apartment',
    'Flat',
    'Townhouse',
    'Studio'
  ];
  String residenceTypeSelected = "";
  Map<String, int>? _beds;
  Map<String, int>? _bathrooms;
  List<String>? _imageUrls = []; // List to hold image URLs

  /* _selectImageFromGallery(int index) async {
    var imageFilePickedFromGallery =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFilePickedFromGallery != null) {
      MemoryImage imageFileInBytesForm = MemoryImage(
          (File(imageFilePickedFromGallery.path)).readAsBytesSync());

      if (index < 0) {
        _imageList!.add(imageFileInBytesForm);
      } else {
        _imageList![index] = imageFileInBytesForm;
      }
      setState(() {});
    }
  }*/

  void _addImageUrl() {
    String imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isNotEmpty) {
      setState(() {
        _imageUrls?.add(imageUrl); // Add URL to the list
        _imageUrlController.clear(); // Clear the input field after adding
      });
    }
  }

  initializeValues() {
    if (widget.posting == null) {
      _nameTextEditingController = TextEditingController(text: "");
      _priceTextEditingController = TextEditingController(text: "");
      _descriptionTextEditingController = TextEditingController(text: "");
      _addressTextEditingController = TextEditingController(text: "");
      _cityTextEditingController = TextEditingController(text: "");
      _countryTextEditingController = TextEditingController(text: "");
      residenceTypeSelected = residenceTypes.first;
      _beds = {'small': 0, 'medium': 0, 'large': 0};
      _bathrooms = {'full': 0, 'half': 0};
    } else {
      _nameTextEditingController =
          TextEditingController(text: widget.posting!.name);
      _priceTextEditingController =
          TextEditingController(text: widget.posting!.price.toString());
      _descriptionTextEditingController =
          TextEditingController(text: widget.posting!.description);
      _addressTextEditingController =
          TextEditingController(text: widget.posting!.address);
      _cityTextEditingController =
          TextEditingController(text: widget.posting!.city);
      _countryTextEditingController =
          TextEditingController(text: widget.posting!.country);
      _amenitiesTextEditingController =
          TextEditingController(text: widget.posting!.getAmenitiesString());
      _beds = widget.posting!.beds;
      _bathrooms = widget.posting!.bathrooms;
      _imageUrls = widget.posting!.displayImage;
      residenceTypeSelected = widget.posting!.type!;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValues();
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
            end: FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text(
          "Create / Update a Listing",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              if (residenceTypeSelected == "") {
                return;
              }
              if (_imageUrls!.isEmpty) {
                return;
              }

              postingModel.name = _nameTextEditingController.text;
              postingModel.price =
                  double.parse(_priceTextEditingController.text);
              postingModel.description = _descriptionTextEditingController.text;
              postingModel.address = _addressTextEditingController.text;
              postingModel.city = _cityTextEditingController.text;
              postingModel.country = _countryTextEditingController.text;
              postingModel.amenities =
                  _amenitiesTextEditingController.text.split(",");
              postingModel.type = residenceTypeSelected;
              postingModel.beds = _beds;
              postingModel.bathrooms = _bathrooms;
              postingModel.displayImage = _imageUrls;
              postingModel.imageNames = _imageUrls;
              postingModel.host =
                  AppConstants.currentUser.createUserFromContact();
              //postingModel.setImageNames();

              //if this is new a post or old post
              if (widget.posting == null) {
                postingModel.rating = 3.5;
                postingModel.bookings = [];
                postingModel.reviews = [];
                await postingsViewModel.addListingInfoToFirestore();
                //await postingsViewModel.addImageToFirebaseStorage();

                Get.snackbar("New listing",
                    "Your new listing is uploaded successfully.");
              } else {
                postingModel.rating = widget.posting!.rating;
                postingModel.bookings = widget.posting!.bookings;
                postingModel.reviews = widget.posting!.reviews;
                postingModel.id = widget.posting!.id;
                postingModel.imageNames = _imageUrls;

                for (int i = 0;
                    i < AppConstants.currentUser.myPostings!.length;
                    i++) {
                  if (AppConstants.currentUser.myPostings![i].id ==
                      postingModel.id) {
                    AppConstants.currentUser.myPostings![i] = postingModel;
                    break;
                  }
                }
                await postingsViewModel.updateListingInfoToFirestore();
                Get.snackbar("Update listing",
                    "Your new listing is updated successfully.");
              }

              PostingModel newPosting = PostingModel();

              //clear posting model

              postingModel = PostingModel();

              Get.to(HostHomeScreen());
            },
            icon: const Icon(Icons.upload),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Listing name
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Listing name"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _nameTextEditingController,
                          validator: (textInput) {
                            if (textInput!.isEmpty) {
                              return "Please entern a valid name";
                            }
                            return null;
                          },
                        ),
                      ),

                      // Select property type
                      Padding(
                        padding: const EdgeInsets.only(top: 28.0),
                        child: DropdownButton(
                          items: residenceTypes.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (valueItem) {
                            setState(() {
                              residenceTypeSelected = valueItem.toString();
                            });
                          },
                          isExpanded: true,
                          value: residenceTypeSelected,
                          hint: const Text(
                            "Select property type",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      // Price/night
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "Price"),
                              style: const TextStyle(
                                fontSize: 25.0,
                              ),
                              keyboardType: TextInputType.number,
                              controller: _priceTextEditingController,
                              validator: (text) {
                                if (text!.isEmpty) {
                                  return "Please enter a valid price";
                                }
                                return null;
                              },
                            )),
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 10.0, bottom: 10.0),
                              child: Text(
                                "\$ / night",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Description
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Description"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _descriptionTextEditingController,
                          maxLines: 3,
                          minLines: 1,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Please entern a valid description";
                            }
                            return null;
                          },
                        ),
                      ),
                      // Address
                      Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Address"),
                          maxLines: 3,
                          style: const TextStyle(fontSize: 25.0),
                          controller: _addressTextEditingController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "Please enter a valid address";
                            }
                            return null;
                          },
                        ),
                      ),
                      // Beds
                      const Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          "Beds",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 21.0, left: 15.0, right: 15.0),
                        child: Column(
                          children: [
                            // Twin /Single bed
                            AmenitiesUi(
                              type: 'Twin/Single',
                              startValue: _beds!['small']!,
                              decreaseValue: () {
                                _beds!['small'] = _beds!['small']! - 1;
                                if (_beds!['small']! < 0) {
                                  _beds!['small'] = 0;
                                }
                              },
                              increaseValue: () {
                                _beds!['small'] = _beds!['small']! + 1;
                              },
                            ),
                            // Double Bed
                            AmenitiesUi(
                                type: 'Double',
                                startValue: _beds!['medium']!,
                                decreaseValue: () {
                                  _beds!['medium'] = _beds!['medium']! - 1;
                                  if (_beds!['medium']! < 0) {
                                    _beds!['medium'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _beds!['medium'] = _beds!['medium']! + 1;
                                }),
                            // Queen /King bed
                            AmenitiesUi(
                                type: 'Queen/King',
                                startValue: _beds!['large']!,
                                decreaseValue: () {
                                  _beds!['large'] = _beds!['large']! - 1;
                                  if (_beds!['large']! < 0) {
                                    _beds!['large'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _beds!['large'] = _beds!['large']! + 1;
                                })
                          ],
                        ),
                      ),
                      // Bathrooms

                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "Bathrooms",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
                        child: Column(
                          children: [
                            // Full bathrooms
                            AmenitiesUi(
                                type: 'Full',
                                startValue: _bathrooms!['full']!,
                                decreaseValue: () {
                                  _bathrooms!['full'] =
                                      _bathrooms!['full']! - 1;

                                  if (_bathrooms!['full']! < 0) {
                                    _bathrooms!['full'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _bathrooms!['full'] =
                                      _bathrooms!['full']! + 1;
                                }),

                            //Half bathroom
                            AmenitiesUi(
                                type: 'Half',
                                startValue: _bathrooms!['half']!,
                                decreaseValue: () {
                                  _bathrooms!['half'] =
                                      _bathrooms!['half']! - 1;

                                  if (_bathrooms!['half']! < 0) {
                                    _bathrooms!['half'] = 0;
                                  }
                                },
                                increaseValue: () {
                                  _bathrooms!['half'] =
                                      _bathrooms!['half']! + 1;
                                }),
                          ],
                        ),
                      ),
                      // Extra amenities
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              labelText: "Amenities , (coma separated)"),
                          style: const TextStyle(
                            fontSize: 25.0,
                          ),
                          controller: _amenitiesTextEditingController,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return "please enter valid amenities (comaseparated)";
                            }
                            return null;
                          },
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      // Photos
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 21.0),
                        child: TextFormField(
                          controller: _imageUrlController,
                          decoration:
                              const InputDecoration(labelText: "Image URL"),
                          keyboardType: TextInputType.url,
                        ),
                      ),

                      // Button to add the URL to the list
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: ElevatedButton(
                          onPressed: _addImageUrl,
                          child: const Text("Add Image URL"),
                        ),
                      ),

                      // Display added image URLs as images
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _imageUrls!.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(url),
                                  Image.network(url), // Display image from URL
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 25.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: _imageList!.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 25,
                                  crossAxisSpacing: 25,
                                  childAspectRatio: 3 / 2),
                          itemBuilder: (context, index) {
                            if (index == _ima!.length) {
                              return IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _selectImageFromGallery(-1);
                                },
                              );
                            }
                            return MaterialButton(
                              onPressed: () {},
                              child: Image(
                                image: _imageList![index],
                                fit: BoxFit.fill,
                              ),
                            );
                          },
                        ),
                      )*/
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//18:57 