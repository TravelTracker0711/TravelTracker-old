// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';

class GpsProvider with ChangeNotifier {
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  StreamSubscription<Position>? _positionStream;

  Position? _position;
  WptExt? _wptExt;
  Position? get position => _position;
  WptExt? get wptExt {
    return _wptExt;
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
    debugPrint('startRecording');
    if (await checkPermission() && !_isRecording) {
      _positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? pos) {
        _position = pos;
        if (pos != null) {
          _wptExt = WptExt.fromPosition(position: pos);
        }
        debugPrint(pos.toString());
        notifyListeners();
      });
      _isRecording = true;
    } else {
      // TODO: do sth if the permission is fucking denied or deniedForever
      print("Permission denied");
    }
  }

  void stopRecording() {
    if (_isRecording) {
      _positionStream?.cancel();
      _positionStream = null;
      _isRecording = false;
      notifyListeners();
    }
  }

  // swap between stopRecording & startRecording
  void toggleRecording(LocationSettings locationSettings) {
    if (_isRecording) {
      debugPrint("stopRecording");
      stopRecording();
    } else {
      debugPrint("startRecording");
      startRecording(locationSettings);
    }
  }
}
