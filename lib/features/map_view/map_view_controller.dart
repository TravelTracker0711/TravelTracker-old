import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum MapViewMode {
  normal,
  partialTrack,
}

class MapViewController with ChangeNotifier {
  MapController? mapController;
  MapViewMode _mode = MapViewMode.partialTrack;
  double? _partialTrackMiddlePercentage;
  bool _isShowingAsset = false;

  MapViewMode get mode => _mode;
  double? get partialTrackMiddlePercentage => _partialTrackMiddlePercentage;
  bool get isShowingAsset => _isShowingAsset;

  set partialTrackMiddlePercentage(double? percentage) {
    _partialTrackMiddlePercentage = percentage;
    notifyListeners();
  }

  void setMode(MapViewMode mode) {
    _mode = mode;
  }
}
