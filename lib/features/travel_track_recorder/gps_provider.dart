// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

class GpsProvider with ChangeNotifier {
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isRecording = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  Wpt? _wpt;

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Wpt? get wpt => _wpt;

  static GpsProvider get I {
    GpsProvider instance = GetIt.I<GpsProvider>();
    if (!instance._isInitializing) {
      instance._isInitializing = true;
      instance._initAsync();
    }
    return instance;
  }

  Future<void> _initAsync() async {
    await PermissionManager.geolocatorRequestAsync();
    notifyListeners();
    _isInitialized = true;
  }

  Future<void> startRecordingAsync(LocationSettings? locationSettings) async {
    if (_isRecording) {
      return;
    }
    if (await PermissionManager.geolocatorRequestAsync() == false) {
      // TODO: handle permission not granted
      return;
    }
    debugPrint('GpsProvider.startRecording');
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_positionStreamListener);
    _isRecording = true;
  }

  void stopRecording() {
    if (!_isRecording) {
      return;
    }
    debugPrint("stopRecording");
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isRecording = false;
    notifyListeners();
  }

  void toggleRecording(LocationSettings? locationSettings) {
    if (_isRecording) {
      stopRecording();
    } else {
      startRecordingAsync(locationSettings);
    }
  }

  void _positionStreamListener(Position? pos) {
    if (pos == null) {
      return;
    }
    _wpt = WptFactory.fromPosition(position: pos);
    notifyListeners();
  }
}
