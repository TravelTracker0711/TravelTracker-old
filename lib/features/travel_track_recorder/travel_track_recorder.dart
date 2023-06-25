import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/activate_travel_track_mananger.dart';
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_file_handler.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';
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

  Future<void> startRecordingAsync({
    bool forceNewTravelTrack = false,
    TravelConfig? newTravelTrackConfig,
  }) async {
    if (_isRecording) {
      return;
    }
    if (ActivateTravelTrackManager.I.isActivateTravelTrackExist ||
        forceNewTravelTrack) {
      await _addNewActiveTravelTrack(newTravelTrackConfig);
    }
    TravelTrack activeTravelTrack =
        ActivateTravelTrackManager.I.activeTravelTrack!;
    activeTravelTrack.addTrkseg();

    _gpsListener = _getGpsListener(activeTravelTrack);
    GpsProvider.I.addListener(_gpsListener!);
    GpsProvider.I.startRecordingAsync(
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
    if (!_isRecording) {
      return;
    }
    _removeGpsListener();
    GpsProvider.I.stopRecording();
    _writeActiveTravelTrack();
    _isRecording = false;
    notifyListeners();
  }

  void stopRecording() {
    if (!_isActivated) {
      return;
    }
    pauseRecording();
    ActivateTravelTrackManager.I.unsetActiveTravelTrack();
    _isActivated = false;
    notifyListeners();
  }

  Future<void> _addNewActiveTravelTrack(
    TravelConfig? newTravelTrackConfig,
  ) async {
    newTravelTrackConfig ??= TravelConfig(namePlaceholder: "New Travel Track");
    TravelTrack newTravelTrack = TravelTrack(
      config: newTravelTrackConfig,
    );
    await TravelTrackManager.I.addTravelTrackAsync(newTravelTrack);
    ActivateTravelTrackManager.I
        .setActiveTravelTrack(travelTrackId: newTravelTrack.id);
  }

  VoidCallback _getGpsListener(TravelTrack activeTravelTrack) {
    return () {
      if (!GpsProvider.I.isNewPoint) {
        return;
      }
      if (GpsProvider.I.wpt == null) {
        return;
      }
      activeTravelTrack.addTrkpt(
        trkpt: GpsProvider.I.wpt!,
      );
    };
  }

  void _removeGpsListener() {
    if (_gpsListener == null) {
      return;
    }
    GpsProvider.I.removeListener(_gpsListener!);
    _gpsListener = null;
  }

  void _writeActiveTravelTrack() {
    if (ActivateTravelTrackManager.I.activeTravelTrack != null) {
      TravelTrackFileHandler()
          .writeAsync(ActivateTravelTrackManager.I.activeTravelTrack!);
    }
  }
}
