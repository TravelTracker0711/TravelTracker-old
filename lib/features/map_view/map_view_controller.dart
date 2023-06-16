import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';

enum MapViewMode {
  normal,
  partialTrack,
}

class MapViewController with ChangeNotifier {
  AnimatedMapController? animateMapController;
  final ValueNotifier<FollowOnLocationUpdate> followOnLocationUpdateNotifier =
      ValueNotifier<FollowOnLocationUpdate>(FollowOnLocationUpdate.always);
  MapViewMode _mode = MapViewMode.normal;
  double? _partialTrackMiddlePercentage;
  bool _isShowingAsset = true;

  MapViewMode get mode => _mode;
  double? get partialTrackMiddlePercentage => _partialTrackMiddlePercentage;
  bool get isShowingAsset => _isShowingAsset;
  bool get isFollowingUser =>
      followOnLocationUpdateNotifier.value == FollowOnLocationUpdate.always;

  set partialTrackMiddlePercentage(double? percentage) {
    _partialTrackMiddlePercentage = percentage;
    notifyListeners();
  }

  void setMode(MapViewMode mode) {
    _mode = mode;
  }

  void locateToTrksegExt(TrksegExt trksegExt) {
    locateToWptExts(trksegExt.trkpts);
  }

  void locateToWptExts(List<WptExt> wptExts) {
    double minLat = wptExts[0].lat;
    double maxLat = wptExts[0].lat;
    double minLon = wptExts[0].lon;
    double maxLon = wptExts[0].lon;
    for (WptExt wptExt in wptExts) {
      if (wptExt.lat < minLat) {
        minLat = wptExt.lat;
      }
      if (wptExt.lat > maxLat) {
        maxLat = wptExt.lat;
      }
      if (wptExt.lon < minLon) {
        minLon = wptExt.lon;
      }
      if (wptExt.lon > maxLon) {
        maxLon = wptExt.lon;
      }
    }
    LatLngBounds bounds = LatLngBounds(
      latlng.LatLng(minLat, minLon),
      latlng.LatLng(maxLat, maxLon),
    );
    animateMapController!.animatedFitBounds(
      bounds,
      options: const FitBoundsOptions(
        padding: EdgeInsets.all(20.0),
      ),
    );
  }

  void followUser() {
    if (followOnLocationUpdateNotifier.value == FollowOnLocationUpdate.never) {
      followOnLocationUpdateNotifier.value = FollowOnLocationUpdate.always;
    }
  }
}
