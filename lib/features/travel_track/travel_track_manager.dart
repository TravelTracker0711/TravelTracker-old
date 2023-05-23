import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/travel_track.dart';

class TravelTrackManager {
  Map<String, TravelTrack> _travelTracks = <String, TravelTrack>{};

  Map<String, TravelTrack> get travelTracks =>
      Map<String, TravelTrack>.unmodifiable(
        _travelTracks,
      );

  // ignore: non_constant_identifier_names
  static Future<TravelTrackManager> get FI async {
    return await GetIt.I
        .isReady<TravelTrackManager>()
        .then((_) => GetIt.I<TravelTrackManager>());
  }

  Future<void> init() async {
    debugPrint('TravelTrackManager init');
    // TODO: load _travelTracks from storage
  }

  Future<void> addTravelTrack(TravelTrack travelTrack) async {
    debugPrint('TravelTrackManager addTravelTrack');
    // TODO: save travelTrack to storage
    _travelTracks[travelTrack.id] = travelTrack;
  }

  Future<void> removeTravelTrack(String travelTrackId) async {
    debugPrint('TravelTrackManager removeTravelTrack');
    // TODO: delete travelTrack from storage
    _travelTracks.remove(travelTrackId);
  }
}
