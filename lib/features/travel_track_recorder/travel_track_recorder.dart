import 'package:flutter/material.dart';
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

  void startRecording() {
    TravelTrack? travelTrack = TravelTrackManager.I.activeTravelTrack;
    if (travelTrack == null) {
      travelTrack = TravelTrack(
        config: TravelConfig(namePlaceholder: "New Travel Track"),
      );
      TravelTrackManager.I.addTravelTrackAsync(travelTrack);
      TravelTrackManager.I.setActiveTravelTrackId(travelTrack.id);
    }
    travelTrack.addTrkseg();
    _gpsListener = () {
      if (GpsProvider.I.wptExt != null) {
        travelTrack?.addTrkpt(GpsProvider.I.wptExt!);
      }
    };
    GpsProvider.I.addListener(_gpsListener!);
    _isActivated = true;
    _isRecording = true;
    notifyListeners();
  }

  void pauseRecording() {
    if (_gpsListener != null) {
      GpsProvider.I.removeListener(_gpsListener!);
      _gpsListener = null;
    }
    _isRecording = false;
    notifyListeners();
  }

  void stopRecording() {
    if (_gpsListener != null) {
      GpsProvider.I.removeListener(_gpsListener!);
      _gpsListener = null;
    }
    _isActivated = false;
    _isRecording = false;
    TravelTrackManager.I.setActiveTravelTrackId(null);
    notifyListeners();
  }
}
