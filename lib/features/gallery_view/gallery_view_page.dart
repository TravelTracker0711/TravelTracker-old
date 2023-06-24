import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_controller.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_grid.dart';
import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';

class GalleryViewPage extends StatefulWidget {
  const GalleryViewPage({super.key});

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  @override
  Widget build(BuildContext context) {
    List<TravelTrack> visibleTravelTracks =
        context.watch<TravelTrackManager>().visibleTravelTracks;
    List<Asset> assets = <Asset>[];
    for (TravelTrack travelTrack in visibleTravelTracks) {
      assets.addAll(travelTrack.assets);
    }
    return GalleryViewGrid(
      controller: GalleryViewController(),
      assets: assets,
    );
  }
}
