import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_file_handler.dart';
import 'package:travel_tracker/global.dart';

class TravelTrackManager with ChangeNotifier {
  final Map<String, TravelTrack> _travelTrackMap = <String, TravelTrack>{};
  String? _activeTravelTrackId;
  bool _isInitializing = false;
  bool _isInitialized = false;
  VoidCallback? _travelTrackListener;

  bool get isInitialized => _isInitialized;
  bool get isAnyTravelTrackSelected => _travelTrackMap.values
      .any((travelTrack) => travelTrack.isSelected == true);
  Map<String, TravelTrack> get travelTrackMap =>
      Map<String, TravelTrack>.unmodifiable(_travelTrackMap);
  TravelTrack? get activeTravelTrack => _travelTrackMap[_activeTravelTrackId];
  String? get activeTravelTrackId => _activeTravelTrackId;
  // TODO: get list of travel tracks, with setted sort and filter
  List<TravelTrack> get travelTracks => _travelTrackMap.values.toList();
  List<TravelTrack> get selectedTravelTracks => travelTracks
      .where((travelTrack) => travelTrack.isSelected == true)
      .toList();
  List<TravelTrack> get visibleTravelTracks => travelTracks
      .where((travelTrack) => travelTrack.isVisible == true)
      .toList();

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
    SnackBar snackBar =
        SnackBar(content: Text("Loading your travel tracks from storage..."));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      snackbarKey.currentState?.showSnackBar(snackBar);
    });

    TravelTrackFileHandler travelTrackFileHandler = TravelTrackFileHandler();
    _travelTrackMap.addAll(await travelTrackFileHandler.readAll());
    _isInitialized = true;
    snackBar = SnackBar(content: Text("Your travel tracks are loaded!"));
    snackbarKey.currentState?.showSnackBar(snackBar);
    notifyListeners();
  }

  Future<void> addTravelTrackAsync(TravelTrack travelTrack) async {
    TravelTrackFileHandler travelTrackFileHandler = TravelTrackFileHandler();
    await travelTrackFileHandler.write(travelTrack);
    _travelTrackMap[travelTrack.config.id] = travelTrack;
    notifyListeners();
  }

  Future<void> removeTravelTrackAsync(String travelTrackId) async {
    // TODO: delete travelTrack from storage
    _travelTrackMap.remove(travelTrackId);
    notifyListeners();
  }

  void setTravelTrackSelected({
    required String travelTrackId,
    required bool isSelected,
  }) {
    _travelTrackMap[travelTrackId]!.isSelected = isSelected;
    notifyListeners();
  }

  void setTravelTrackVisible({
    required String travelTrackId,
    required bool isVisible,
  }) {
    _travelTrackMap[travelTrackId]!.isVisible = isVisible;
    notifyListeners();
  }

  bool isTravelTrackSelected(String travelTrackId) {
    return _travelTrackMap[travelTrackId]!.isSelected;
  }

  bool isTravelTrackVisible(String travelTrackId) {
    return _travelTrackMap[travelTrackId]!.isVisible;
  }

  void setActiveTravelTrackId(String? travelTrackId) {
    if (_activeTravelTrackId != null) {
      if (_travelTrackListener != null) {
        _travelTrackMap[_activeTravelTrackId]
            ?.removeListener(_travelTrackListener!);
      }
    }
    if (travelTrackId != null && _travelTrackMap.containsKey(travelTrackId)) {
      _travelTrackListener = () {
        notifyListeners();
      };
      _travelTrackMap[travelTrackId]!.addListener(_travelTrackListener!);
    }
    _activeTravelTrackId = travelTrackId;
    notifyListeners();
  }
}
