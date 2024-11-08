import 'package:booking_place/model/app_constants.dart';
import 'package:booking_place/model/posting_model.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';

class PostingGridTileUi extends StatefulWidget {
  PostingModel? posting;

  PostingGridTileUi({super.key, this.posting});

  @override
  State<PostingGridTileUi> createState() => _PostingGridTileUiState();
}

class _PostingGridTileUiState extends State<PostingGridTileUi> {
  PostingModel? posting;

  updateUI() async {
    await posting!.getFirstImageFromStorage();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    posting = widget.posting;

    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: (posting!.displayImage!.isEmpty)
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: posting!.displayImage!.first,
                    fit: BoxFit.fill,
                  )),
                ),
        ),
        Text(
          "${posting!.type} - ${posting!.city}, ${posting!.country}",
          maxLines: 2,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          posting!.name!,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${posting!.price} / night',
          maxLines: 2,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            RatingBar.readOnly(
              size: 28.0,
              maxRating: 5,
              initialRating: posting!.getCurrentRating(),
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              filledColor: Colors.green,
            )
          ],
        )
      ],
    );
  }
}
