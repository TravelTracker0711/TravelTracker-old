import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_controller.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_grid.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';

class GalleryViewPage extends StatefulWidget {
  const GalleryViewPage({super.key});

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  @override
  Widget build(BuildContext context) {
    Map<String, TravelTrack> travelTracks =
        context.watch<TravelTrackManager>().travelTracks;
    List<AssetExt> assetExts = <AssetExt>[];
    travelTracks.forEach((String travelTrackId, TravelTrack travelTrack) {
      for (AssetExt assetExt in travelTrack.assetExts) {
        assetExts.add(assetExt);
      }
    });
    return GalleryViewGrid(
      controller: GalleryViewController(),
      assetExts: assetExts,
    );
  }
}
