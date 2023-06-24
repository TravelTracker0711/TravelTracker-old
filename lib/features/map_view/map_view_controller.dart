import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/data_model/trkseg.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';

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

  void locateToTrkseg(Trkseg trkseg) {
    locateToWpts(trkseg.trkpts);
  }

  void locateToWpts(List<Wpt> wpts) {
    double minLat = wpts[0].lat;
    double maxLat = wpts[0].lat;
    double minLon = wpts[0].lon;
    double maxLon = wpts[0].lon;
    for (Wpt wpt in wpts) {
      if (wpt.lat < minLat) {
        minLat = wpt.lat;
      }
      if (wpt.lat > maxLat) {
        maxLat = wpt.lat;
      }
      if (wpt.lon < minLon) {
        minLon = wpt.lon;
      }
      if (wpt.lon > maxLon) {
        maxLon = wpt.lon;
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
      notifyListeners();
    }
  }

  void stopFollowingUser() {
    if (followOnLocationUpdateNotifier.value == FollowOnLocationUpdate.always) {
      followOnLocationUpdateNotifier.value = FollowOnLocationUpdate.never;
      notifyListeners();
      debugPrint('notify!');
    }
  }
}
