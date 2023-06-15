import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:travel_tracker/features/asset/asset_ext_thumbnail_button.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';

class TravelTrackTimelineBuilder {
  Widget build(TravelTrack travelTrack) {
    return SizedBox(
      width: 88,
      child: ListView(
        children: _buildTimelineTiles(travelTrack),
      ),
    );
  }

  List<Widget> _buildTimelineTiles(TravelTrack travelTrack) {
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
        indicator: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
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
