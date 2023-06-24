import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:travel_tracker/features/asset/asset_thumbnail_button.dart';
import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/features/gallery_view/gallery_view_photo.dart';
import 'package:travel_tracker/features/map_view/map_view_controller.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';

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
    List<Asset> assets = travelTrack.assets;
    List<Trkseg> trksegs = travelTrack.trksegs;
    for (int assetIndex = assets.length - 1; assetIndex >= 0; assetIndex--) {
      if (lastTrksegId == null) {
        timelineTiles.add(_buildTimelineHead());
      } else if (assets[assetIndex].attachedTrksegId != null &&
          assets[assetIndex].attachedTrksegId != lastTrksegId) {
        trksegIndex++;
        timelineTiles.add(_buildTrksegTimelineHead(trksegs[trksegIndex]));
      }
      lastTrksegId = assets[assetIndex].attachedTrksegId;

      timelineTiles
          .add(_buildAssetTimelineTile(assets[assetIndex], assets, assetIndex));
    }
    // for (List<String> assetIds in travelTrack.assetIdGroups) {
    //   List<Asset> assets = travelTrack.getAssetsByIds(assetIds);
    //   timelineTiles.add(_buildAssetsTimelineTile(assets));
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

  Widget _buildAssetTimelineTile(Asset asset, List<Asset> assets, int index) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(
        color: Colors.blue,
      ),
      indicatorStyle: IndicatorStyle(
        width: 56,
        height: 56,
        color: Colors.blue,
        indicator: AssetThumbnailButton(
          displayedAsset: asset,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(),
                  body: GalleryViewPhoto(
                    assets: assets.reversed.toList(),
                    initialIndex: assets.length - 1 - index,
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

  Widget _buildAssetsTimelineTile(List<Asset> assets) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      beforeLineStyle: const LineStyle(
        color: Colors.blue,
      ),
      indicatorStyle: IndicatorStyle(
        width: 56,
        height: 56,
        color: Colors.blue,
        indicator: AssetThumbnailButton(
          displayedAsset: assets[0],
          assetCount: 1,
          onTap: () {},
        ),
      ),
    );
  }
}
