// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

class GpsProvider with ChangeNotifier {
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  StreamSubscription<Position>? _positionStream;

  Position? _position;
  Wpt? _wpt;
  Position? get position => _position;
  Wpt? get wpt {
    return _wpt;
  }

  static GpsProvider get I {
    GpsProvider instance = GetIt.I<GpsProvider>();
    if (!instance._isInitializing) {
      instance._isInitializing = true;
      instance._initAsync();
    }
    return instance;
  }

  // init
  Future<void> _initAsync() async {
    // request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    notifyListeners();
    _isInitialized = true;
  }

  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // if permission is true, then start getting the position
  void startRecording(LocationSettings locationSettings) async {
    if (await checkPermission() && !_isRecording) {
      debugPrint('startRecording');
      _positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? pos) {
        _position = pos;
        if (pos != null) {
          _wpt = WptFactory.fromPosition(position: pos);
        }
        notifyListeners();
      });
      _isRecording = true;
    } else {
      // TODO: do sth if the permission is fucking denied or deniedForever
    }
  }

  void stopRecording() {
    if (_isRecording) {
      debugPrint("stopRecording");
      _positionStream?.cancel();
      _positionStream = null;
      _isRecording = false;
      notifyListeners();
    }
  }

  // swap between stopRecording & startRecording
  void toggleRecording(LocationSettings locationSettings) {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecording(locationSettings);
    }
  }
}
