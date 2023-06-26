import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:travel_tracker/features/travel_track_recorder/gps_provider.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

extension LocationGpsAccuracy on GpsAccuracy {
  loc.LocationAccuracy toLocation() {
    switch (this) {
      case GpsAccuracy.powerSave:
        return loc.LocationAccuracy.powerSave;
      case GpsAccuracy.lowest:
        return loc.LocationAccuracy.low;
      case GpsAccuracy.low:
        return loc.LocationAccuracy.low;
      case GpsAccuracy.medium:
        return loc.LocationAccuracy.balanced;
      case GpsAccuracy.high:
        return loc.LocationAccuracy.high;
      case GpsAccuracy.best:
        return loc.LocationAccuracy.high;
      case GpsAccuracy.bestForNavigation:
        return loc.LocationAccuracy.navigation;
      case GpsAccuracy.reduced:
        return loc.LocationAccuracy.reduced;
      default:
        throw Exception('Unknown GpsAccuracy: $this');
    }
  }
}

class LocationGpsProvider extends GpsProvider {
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isNewPoint = false;
  StreamSubscription<loc.LocationData>? _locationDataSubscription;
  Wpt? _wpt;
  final loc.Location _location = loc.Location();

  @override
  bool get isInitialized => _isInitialized;
  @override
  bool get isRecording => _isRecording;
  @override
  bool get isNewPoint => _isNewPoint;

  @override
  Wpt? get wpt => _wpt;

  @override
  Future<void> initAsync() async {
    await PermissionManager.locationRequestAsync(_location);
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> startRecordingAsync() async {
    if (_isRecording) {
      return;
    }
    if (await PermissionManager.locationRequestAsync(_location) == false) {
      // TODO: handle permission not granted
      return;
    }
    debugPrint('LocationGpsProvider.startRecording');
    loc.LocationData data = await _location.getLocation();
    debugPrint('LocationGpsProvider: initial location data $data');
    _locationDataSubscription = _location.onLocationChanged.listen(
      (loc.LocationData data) {
        debugPrint('LocationGpsProvider: new location data $data');
      },
      // _locationDataStreamListener,
    );
    _isRecording = true;
  }

  void _locationDataStreamListener(loc.LocationData data) {
    debugPrint('LocationGpsProvider: new location data $data');
    Wpt newWpt = WptFactory.fromLocationData(locationData: data);
    if (_wpt != null && _wpt!.latLng == newWpt.latLng) {
      debugPrint('LocationGpsProvider: same wpt');
      return;
    }
    _wpt = newWpt;
    debugPrint('LocationGpsProvider: new wpt $_wpt');
    notifyListeners(isNewPoint: true);
  }

  @override
  void stopRecording() {
    if (!_isRecording) {
      return;
    }
    debugPrint("stopRecording");
    _locationDataSubscription?.cancel();
    _locationDataSubscription = null;
    _isRecording = false;
    notifyListeners();
  }

  @override
  void toggleRecording() {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecordingAsync();
    }
  }

  @override
  void setGpsSettings({
    GpsAccuracy? accuracy,
    double? intervalMilli,
    double? distanceFilter,
  }) {
    _location.changeSettings(
      accuracy: accuracy?.toLocation(),
      interval: intervalMilli?.toInt(),
      distanceFilter: distanceFilter,
    );
  }

  @override
  void notifyListeners({
    bool isNewPoint = false,
  }) {
    _isNewPoint = isNewPoint;
    super.notifyListeners();
  }
}
