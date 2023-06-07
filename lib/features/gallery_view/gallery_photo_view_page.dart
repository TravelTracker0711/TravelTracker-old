import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';

class GalleryPhotoViewPage extends StatefulWidget {
  const GalleryPhotoViewPage({super.key, required this.asset});

  final AssetEntity asset;

  @override
  State<GalleryPhotoViewPage> createState() => _GalleryPhotoViewPageState();
}

class _GalleryPhotoViewPageState extends State<GalleryPhotoViewPage> {
  @override
  Widget build(BuildContext context) {
    List<int> itemIds = List<int>.generate(100, (int index) => index + 1);
    return CarouselSlider(
      options: CarouselOptions(
        height: 30.0,
        aspectRatio: 1 / 1,
        viewportFraction: 0.1,
      ),
      items: itemIds.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(color: Colors.amber),
                child: Text(
                  '$i',
                  style: TextStyle(fontSize: 16.0),
                ));
          },
        );
      }).toList(),
    );
    // return PhotoView(
    //   imageProvider: AssetEntityImageProvider(widget.asset),
    // );
  }
}
