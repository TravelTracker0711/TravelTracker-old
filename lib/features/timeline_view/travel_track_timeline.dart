import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:travel_tracker/features/asset/asset_ext_thumbnail_button.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_photo.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg.dart';

class TravelTrackTimeline extends StatefulWidget {
  TravelTrackTimeline({
    super.key,
    required this.scrollController,
    required this.maxHeight,
    required this.travelTrack,
  });

  final ScrollController scrollController;
  final double maxHeight;
  final TravelTrack travelTrack;

  @override
  State<TravelTrackTimeline> createState() => _TravelTrackTimelineState();
}

class _TravelTrackTimelineState extends State<TravelTrackTimeline> {
  late MapViewController mapViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mapViewController = context.watch<MapViewController>();
    debugPrint('isFollowingUser: ${mapViewController.isFollowingUser}');
    return SizedBox(
      width: 88,
      child: Stack(
        children: [
          ListView(
            controller: widget.scrollController,
            children: _buildTimelineTiles(
              widget.travelTrack,
              maxHeight: widget.maxHeight,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 26),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  mapViewController.followUser();
                },
                icon: mapViewController.isFollowingUser
                    ? const Icon(
                        Icons.gps_fixed,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.gps_not_fixed,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineTiles(
    TravelTrack travelTrack, {
    required double maxHeight,
  }) {
    List<Widget> timelineTiles = [];
    int trksegIndex = 0;
    String? lastTrksegId;
    List<AssetExt> assetExts = travelTrack.assetExts;
    List<Trkseg> trksegs = travelTrack.trksegs;
    for (int assetIndex = assetExts.length - 1; assetIndex >= 0; assetIndex--) {
      if (lastTrksegId == null) {
        timelineTiles.add(_buildTimelineHead());
      } else if (assetExts[assetIndex].attachedTrksegId != null &&
          assetExts[assetIndex].attachedTrksegId != lastTrksegId) {
        trksegIndex++;
        timelineTiles.add(_buildTrksegTimelineHead(trksegs[trksegIndex]));
      }
      lastTrksegId = assetExts[assetIndex].attachedTrksegId;

      timelineTiles.add(_buildAssetExtTimelineTile(
          assetExts[assetIndex], assetExts, assetIndex));
    }
    // for (List<String> assetExtIds in travelTrack.assetExtIdGroups) {
    //   List<AssetExt> assetExts = travelTrack.getAssetExtsByIds(assetExtIds);
    //   timelineTiles.add(_buildAssetExtsTimelineTile(assetExts));
    // }
    // 建立一個空白的container讓最底下的tile可以被滑到上面
    timelineTiles.add(
      Container(
        height: maxHeight - 50,
      ),
    );
    return timelineTiles;
  }

  Widget _buildTimelineHead() {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: LineStyle(color: Colors.blue),
      isFirst: true,
      indicatorStyle: IndicatorStyle(
        width: 56,
        height: 56,
        color: Colors.blue,
        indicator: Container(),
      ),
    );
  }

  Widget _buildTrksegTimelineHead(Trkseg trkseg) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      indicatorStyle: IndicatorStyle(
        width: 32,
        height: 32,
        color: Colors.blue,
        indicator: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pause,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetExtTimelineTile(
      AssetExt assetExt, List<AssetExt> assetExts, int index) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(
        color: Colors.blue,
      ),
      indicatorStyle: IndicatorStyle(
        width: 56,
        height: 56,
        color: Colors.blue,
        indicator: AssetExtThumbnailButton(
          displayedAssetExt: assetExt,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(),
                  body: GalleryViewPhoto(
                    assetExts: assetExts.reversed.toList(),
                    initialIndex: assetExts.length - 1 - index,
                    thumbnailHeight: 64.0,
                    thumbnailWidth: 48.0,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAssetExtsTimelineTile(List<AssetExt> assetExts) {
    debugPrint('assetExts.length: ${assetExts.length}');
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(
        color: Colors.blue,
      ),
      indicatorStyle: IndicatorStyle(
        width: 56,
        height: 56,
        color: Colors.blue,
        indicator: AssetExtThumbnailButton(
          displayedAssetExt: assetExts[0],
          assetCount: 1,
          onTap: () {},
        ),
      ),
    );
  }
}
