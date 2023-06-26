import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

enum GpsAccuracy {
  powerSave,
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
  reduced;

  double get androidDistance {
    switch (this) {
      case GpsAccuracy.powerSave:
        return 500;
      case GpsAccuracy.lowest:
        return 500;
      case GpsAccuracy.low:
        return 500;
      case GpsAccuracy.medium:
        return 100;
      case GpsAccuracy.high:
        return 0;
      case GpsAccuracy.best:
        return 0;
      case GpsAccuracy.bestForNavigation:
        return 0;
      case GpsAccuracy.reduced:
        return 500;
    }
  }

  double get iosDistance {
    switch (this) {
      case GpsAccuracy.powerSave:
        return 3000;
      case GpsAccuracy.lowest:
        return 3000;
      case GpsAccuracy.low:
        return 1000;
      case GpsAccuracy.medium:
        return 100;
      case GpsAccuracy.high:
        return 10;
      case GpsAccuracy.best:
        return 0;
      case GpsAccuracy.bestForNavigation:
        return 0;
      case GpsAccuracy.reduced:
        return 3000;
    }
  }
}

abstract class GpsProvider with ChangeNotifier {
  bool _isInitializing = false;

  static GpsProvider get I {
    GpsProvider? instance;
    instance = GetIt.I<GpsProvider>();
    if (!instance._isInitializing) {
      instance._isInitializing = true;
      instance.initAsync();
    }
    return instance;
  }

  Future<void> initAsync();

  bool get isInitialized => throw UnimplementedError();
  bool get isRecording => throw UnimplementedError();
  bool get isNewPoint => throw UnimplementedError();
  Wpt? get wpt => throw UnimplementedError();

  Future<void> startRecordingAsync() async => throw UnimplementedError();
  void stopRecording() => throw UnimplementedError();
  void toggleRecording() => throw UnimplementedError();
  void setGpsSettings({
    GpsAccuracy? accuracy,
    double? distanceFilter,
    double? intervalMilli,
  }) =>
      throw UnimplementedError();
}
