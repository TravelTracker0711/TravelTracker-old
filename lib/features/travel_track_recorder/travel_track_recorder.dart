import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';

class TravelTrackRecorder with ChangeNotifier {
  // ignore: non_constant_identifier_names
  static TravelTrackRecorder get I {
    TravelTrackRecorder instance = GetIt.I<TravelTrackRecorder>();
    return instance;
  }

  bool _isRecording = false;
  bool _isPaused = false;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;

  void startRecording() {
    TravelTrack? travelTrack = TravelTrackManager.I.activeTravelTrack;
    if (travelTrack == null) {
      travelTrack = TravelTrack(
        config: TravelConfig(namePlaceholder: "New Travel Track"),
      );
      TravelTrackManager.I.addTravelTrackAsync(travelTrack);
      TravelTrackManager.I.setActiveTravelTrackId(travelTrack.id);
    }
    _isPaused = false;
    _isRecording = true;
    notifyListeners();
  }

  void pauseRecording() {
    _isPaused = true;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    _isPaused = false;
    notifyListeners();
  }
}
