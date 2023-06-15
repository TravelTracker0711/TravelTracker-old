import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:travel_tracker/features/asset/asset_ext_thumbnail_button.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';

class TravelTrackTimelineBuilder {
  final ScrollController scrollController;

  TravelTrackTimelineBuilder({
    required this.scrollController,
  });

  Widget build(TravelTrack travelTrack, {required double maxHeight}) {
    return SizedBox(
      width: 88,
      child: Stack(
        children: [
          ListView(
            controller: scrollController,
            children: _buildTimelineTiles(
              travelTrack,
              maxHeight: maxHeight,
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
                icon: const Icon(
                  Icons.gps_fixed,
                  color: Colors.white,
                ),
                onPressed: () {},
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
    List<TrksegExt> trksegExts = travelTrack.trksegExts;
    for (int assetIndex = assetExts.length - 1; assetIndex >= 0; assetIndex--) {
      if (lastTrksegId == null) {
        timelineTiles.add(_buildTimelineHead());
      } else if (assetExts[assetIndex].attachedTrksegExtId != null &&
          assetExts[assetIndex].attachedTrksegExtId != lastTrksegId) {
        trksegIndex++;
        timelineTiles.add(_buildTrksegExtTimelineHead(trksegExts[trksegIndex]));
      }
      lastTrksegId = assetExts[assetIndex].attachedTrksegExtId;

      timelineTiles.add(_buildAssetExtTimelineTile(assetExts[assetIndex]));
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

  Widget _buildTrksegExtTimelineHead(TrksegExt trksegExt) {
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

  Widget _buildAssetExtTimelineTile(AssetExt assetExt) {
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
          onTap: () {},
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
