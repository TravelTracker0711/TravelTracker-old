import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';

class ActivateTravelTrackManager with ChangeNotifier {
  String? _activeTravelTrackId;

  Map<String, TravelTrack> get _travelTrackMap =>
      TravelTrackManager.I.travelTrackMap;
  String? get activeTravelTrackId => _activeTravelTrackId;
  TravelTrack? get activeTravelTrack => _travelTrackMap[_activeTravelTrackId];
  bool get isActivateTravelTrackExist => activeTravelTrack != null;

  static ActivateTravelTrackManager get I =>
      GetIt.I<ActivateTravelTrackManager>();

  void setActiveTravelTrack({
    required String travelTrackId,
  }) {
    if (isActivateTravelTrackExist) {
      activeTravelTrack?.removeListener(_activateTravelTrackListener);
    }
    if (_travelTrackMap.containsKey(travelTrackId)) {
      _travelTrackMap[travelTrackId]!.addListener(_activateTravelTrackListener);
      _activeTravelTrackId = travelTrackId;
      notifyListeners();
    }
  }

  void unsetActiveTravelTrack() {
    if (isActivateTravelTrackExist) {
      activeTravelTrack?.removeListener(_activateTravelTrackListener);
      _activeTravelTrackId = null;
      notifyListeners();
    }
  }

  void _activateTravelTrackListener() {
    notifyListeners();
  }
}
