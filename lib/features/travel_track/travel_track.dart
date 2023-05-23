import 'package:uuid/uuid.dart';
import 'package:travel_tracker/features/travel_track/trk_asset.dart';

// TODO: find a way to store global list of travel tracks, and load them when app starts
// TODO: TravelTrackManager, TravelTrackRepository, TravelTrackService
// TODO: with ChangeNotifier
class TravelTrack {
  String _id = const Uuid().v4();
  String _name;
  String? _description = "";
  List<String> _gpxFilePaths = <String>[];
  List<TrkAsset> _trackAssets = <TrkAsset>[];

  String get id => _id;
  String get name => _name;
  String? get description => _description;
  List<String> get gpxFilePaths => _gpxFilePaths;
  List<TrkAsset> get trackAssets => _trackAssets;

  set name(String name) {
    _name = name;
  }

  set description(String? description) {
    _description = description;
  }

  void addGpxFilePath(String gpxFilePath) {
    _gpxFilePaths.add(gpxFilePath);
  }

  // TODO: cal totalDistance
  double get totalDistance {
    return 0.0;
  }

  // TODO: cal totalDuration
  double get totalDuration {
    return 0.0;
  }

  // TODO: cal averageSpeed
  double get averageSpeed {
    return 0.0;
  }

  // TODO: get startTime
  DateTime get startTime {
    return DateTime.now();
  }

  // TODO: get endTime
  DateTime get endTime {
    return DateTime.now();
  }

  static Future<TravelTrack> createAutoAttachAssets({
    List<String>? gpxFilePaths,
    List<TrkAsset>? trackAssets,
    required String name,
    String? description,
  }) async {
    // TODO: auto attach assets
    TravelTrack travelTrack = TravelTrack(
      gpxFilePaths: gpxFilePaths,
      trackAssets: trackAssets,
      name: name,
      description: description,
    );
    return travelTrack;
  }

  TravelTrack({
    List<String>? gpxFilePaths,
    List<TrkAsset>? trackAssets,
    required String name,
    String? description,
  })  : _name = name,
        _description = description {
    if (gpxFilePaths != null) {
      _gpxFilePaths = gpxFilePaths;
    }
    if (trackAssets != null) {
      _trackAssets = trackAssets;
    }
  }
}
