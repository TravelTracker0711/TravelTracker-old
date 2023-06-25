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

  Map<String, TravelTrack> get travelTrackMap =>
      Map<String, TravelTrack>.unmodifiable(_travelTrackMap);
  List<TravelTrack> get travelTracks => _travelTrackMap.values.toList();

  String? get activeTravelTrackId => _activeTravelTrackId;
  TravelTrack? get activeTravelTrack => _travelTrackMap[_activeTravelTrackId];
  bool get isActivateTravelTrackExist => activeTravelTrack != null;

  bool get isInitialized => _isInitialized;
  bool get isAnyTravelTrackSelected => _travelTrackMap.values
      .any((travelTrack) => travelTrack.isSelected == true);
  bool get isAnyTravelTrackVisible => _travelTrackMap.values
      .any((travelTrack) => travelTrack.isVisible == true);

  List<TravelTrack> get selectedTravelTracks => travelTracks
      .where((travelTrack) => travelTrack.isSelected == true)
      .toList()
    ..sort((a, b) => a.compareTo(b));
  List<TravelTrack> get visibleTravelTracks => travelTracks
      .where((travelTrack) => travelTrack.isVisible == true)
      .toList()
    ..sort((a, b) => a.compareTo(b));

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
    // TODO: understand snackbar principle
    SchedulerBinding.instance.addPostFrameCallback((_) {
      snackbarKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("Loading your travel tracks from storage..."),
        ),
      );
    });

    TravelTrackFileHandler travelTrackFileHandler = TravelTrackFileHandler();
    _travelTrackMap.addAll(await travelTrackFileHandler.readAllAsync());
    _isInitialized = true;

    snackbarKey.currentState?.showSnackBar(
      const SnackBar(content: Text("Your travel tracks are loaded!")),
    );
    notifyListeners();
  }

  // TODO: move writeAsync to somewhere else
  Future<void> addTravelTrackAsync(TravelTrack travelTrack) async {
    TravelTrackFileHandler travelTrackFileHandler = TravelTrackFileHandler();
    await travelTrackFileHandler.writeAsync(travelTrack);
    _travelTrackMap[travelTrack.id] = travelTrack;
    notifyListeners();
  }

  // TODO: delete travelTrack from storage
  Future<void> removeTravelTrackAsync(String travelTrackId) async {
    _travelTrackMap.remove(travelTrackId);
    notifyListeners();
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

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
