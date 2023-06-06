import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';

class TravelTrackManager with ChangeNotifier {
  final Map<String, TravelTrack> _travelTracks = <String, TravelTrack>{};
  bool _isInitializing = false;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Map<String, TravelTrack> get travelTracks =>
      Map<String, TravelTrack>.unmodifiable(
        _travelTracks,
      );

  // ignore: non_constant_identifier_names
  static TravelTrackManager get I {
    TravelTrackManager instance = GetIt.I<TravelTrackManager>();
    if (!instance._isInitializing) {
      instance._isInitializing = true;
      instance.initAsync();
    }
    return instance;
  }

  Future<void> initAsync() async {
    debugPrint('TravelTrackManager init');
    // TODO: load _travelTracks from storage
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addTravelTrackAsync(TravelTrack travelTrack) async {
    debugPrint('TravelTrackManager addTravelTrack');
    // TODO: save travelTrack to storage
    _travelTracks[travelTrack.id] = travelTrack;
    notifyListeners();
  }

  Future<void> removeTravelTrackAsync(String travelTrackId) async {
    debugPrint('TravelTrackManager removeTravelTrack');
    // TODO: delete travelTrack from storage
    _travelTracks.remove(travelTrackId);
    notifyListeners();
  }
}
