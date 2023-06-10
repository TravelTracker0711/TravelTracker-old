import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_file_handler.dart';

class TravelTrackManager with ChangeNotifier {
  final Map<String, TravelTrack> _travelTrackMap = <String, TravelTrack>{};
  bool _isInitializing = false;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Map<String, TravelTrack> get travelTrackMap =>
      Map<String, TravelTrack>.unmodifiable(_travelTrackMap);

  // ignore: non_constant_identifier_names
  static TravelTrackManager get I {
    TravelTrackManager instance = GetIt.I<TravelTrackManager>();
    if (!instance._isInitializing) {
      instance._isInitializing = true;
      instance._initAsync();
    }
    return instance;
  }

  Future<void> _initAsync() async {
    debugPrint('TravelTrackManager init');
    // TODO: load _travelTracks from storage
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addTravelTrackAsync(TravelTrack travelTrack) async {
    debugPrint('TravelTrackManager addTravelTrack');
    TravelTrackFileHandler travelTrackFileHandler = TravelTrackFileHandler();
    await travelTrackFileHandler.write(travelTrack);
    _travelTrackMap[travelTrack.id] = travelTrack;
    notifyListeners();
  }

  Future<void> removeTravelTrackAsync(String travelTrackId) async {
    debugPrint('TravelTrackManager removeTravelTrack');
    // TODO: delete travelTrack from storage
    _travelTrackMap.remove(travelTrackId);
    notifyListeners();
  }
}
