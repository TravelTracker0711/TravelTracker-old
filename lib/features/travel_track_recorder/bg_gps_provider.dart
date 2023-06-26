import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:travel_tracker/features/travel_track_recorder/gps_provider.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

extension BgGpsAccuracy on GpsAccuracy {
  int toBgAccuracy() {
    switch (this) {
      case GpsAccuracy.powerSave:
        return bg.Config.DESIRED_ACCURACY_LOWEST;
      case GpsAccuracy.lowest:
        return bg.Config.DESIRED_ACCURACY_LOWEST;
      case GpsAccuracy.low:
        return bg.Config.DESIRED_ACCURACY_LOW;
      case GpsAccuracy.medium:
        return bg.Config.DESIRED_ACCURACY_MEDIUM;
      case GpsAccuracy.high:
        return bg.Config.DESIRED_ACCURACY_HIGH;
      case GpsAccuracy.best:
        return bg.Config.DESIRED_ACCURACY_HIGH;
      case GpsAccuracy.bestForNavigation:
        return bg.Config.DESIRED_ACCURACY_NAVIGATION;
      case GpsAccuracy.reduced:
        return bg.Config.DESIRED_ACCURACY_LOWEST;
      default:
        throw Exception('Unknown GpsAccuracy: $this');
    }
  }
}

class BgGpsProvider extends GpsProvider {
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isNewPoint = false;
  Wpt? _wpt;

  int _bgAccuracy = bg.Config.DESIRED_ACCURACY_HIGH;
  int _fastestUpdateInterval = 1000;
  double _distanceFilter = 10;

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
    // TODO: make sure permission is ok
    await PermissionManager.geolocatorRequestAsync();
    bg.BackgroundGeolocation.onLocation(_onLocation);
    _isInitialized = true;
    notifyListeners();
  }

  @override
  Future<void> startRecordingAsync() async {
    if (_isRecording) {
      return;
    }
    if (await PermissionManager.geolocatorRequestAsync() == false) {
      // TODO: handle permission not granted
      return;
    }
    debugPrint('BgGpsProvider.startRecording');
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: _bgAccuracy,
      distanceFilter: _distanceFilter,
      fastestLocationUpdateInterval: _fastestUpdateInterval,
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
    _isRecording = true;
  }

  void _onLocation(bg.Location location) {
    debugPrint('BgGpsProvider: new location $location');
    Wpt newWpt = WptFactory.fromBgLocation(location: location);
    if (_wpt != null && _wpt!.latLng == newWpt.latLng) {
      debugPrint('BgGpsProvider: same wpt');
      return;
    }
    _wpt = newWpt;
    debugPrint('BgGpsProvider: new wpt $_wpt');
    notifyListeners(isNewPoint: true);
  }

  @override
  void stopRecording() {
    if (!_isRecording) {
      return;
    }
    debugPrint("stopRecording");
    bg.BackgroundGeolocation.stop();
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
    _bgAccuracy = accuracy?.toBgAccuracy() ?? _bgAccuracy;
    _fastestUpdateInterval = intervalMilli?.toInt() ?? _fastestUpdateInterval;
    _distanceFilter = distanceFilter ?? _distanceFilter;
  }

  @override
  void notifyListeners({
    bool isNewPoint = false,
  }) {
    _isNewPoint = isNewPoint;
    super.notifyListeners();
  }
}
