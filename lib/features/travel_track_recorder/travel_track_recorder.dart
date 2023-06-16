import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'package:travel_tracker/features/travel_track_recorder/gps_provider.dart';

class TravelTrackRecorder with ChangeNotifier {
  // ignore: non_constant_identifier_names
  static TravelTrackRecorder get I {
    TravelTrackRecorder instance = GetIt.I<TravelTrackRecorder>();
    return instance;
  }

  bool _isActivated = false;
  bool _isRecording = false;
  VoidCallback? _gpsListener;

  bool get isActivated => _isActivated;
  bool get isRecording => _isRecording;

  Future<void> startRecordingAsync() async {
    TravelTrack? activeTravelTrack = TravelTrackManager.I.activeTravelTrack;
    if (activeTravelTrack == null) {
      activeTravelTrack = TravelTrack(
        config: TravelConfig(namePlaceholder: "New Travel Track"),
      );
      await TravelTrackManager.I.addTravelTrackAsync(activeTravelTrack);
      TravelTrackManager.I.setActiveTravelTrackId(activeTravelTrack.id);
    }
    activeTravelTrack.addTrkseg();
    _gpsListener = () {
      if (GpsProvider.I.wptExt != null) {
        activeTravelTrack?.addTrkpt(GpsProvider.I.wptExt!);
      }
    };
    GpsProvider.I.addListener(_gpsListener!);
    GpsProvider.I.startRecording(
      const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    _isActivated = true;
    _isRecording = true;
    notifyListeners();
  }

  void pauseRecording() {
    if (_gpsListener != null) {
      GpsProvider.I.removeListener(_gpsListener!);
      _gpsListener = null;
    }
    GpsProvider.I.stopRecording();
    _isRecording = false;
    notifyListeners();
  }

  void stopRecording() {
    pauseRecording();
    _isActivated = false;
    TravelTrackManager.I.setActiveTravelTrackId(null);
    notifyListeners();
  }
}
