import 'package:gpx/gpx.dart';
import 'package:path/path.dart';
import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_tracker/features/travel_track/trk_asset.dart';

// TODO: find a way to store global list of travel tracks, and load them when app starts
// TODO: TravelTrackManager, TravelTrackRepository, TravelTrackService
// TODO: with ChangeNotifier
class TravelTrack {
  final String _id = const Uuid().v4();
  late String _name;
  String? _description = "";
  List<GpxExt> _gpxExts = <GpxExt>[];
  List<TrkAsset> _trkAssets = <TrkAsset>[];

  String get id => _id;
  String get name => _name;
  String? get description => _description;
  List<GpxExt> get gpxExts => List<GpxExt>.unmodifiable(_gpxExts);
  List<TrkAsset> get trkAssets => List<TrkAsset>.unmodifiable(_trkAssets);

  set name(String name) {
    _name = name;
  }

  set description(String? description) {
    _description = description;
  }

  void addGpxByFilePath(String gpxFilePath) async {
    _gpxExts.add(await GpxExt.fromFilePath(gpxFilePath));
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

  // TODO: TravelTrackService.createAutoAttachAssets
  // static Future<TravelTrack> createAutoAttachAssets({
  //   List<String>? gpxFilePaths,
  //   List<TrkAsset>? trkAssets,
  //   required String name,
  //   String? description,
  // }) async {
  //   TravelTrack travelTrack = TravelTrack(
  //     gpxFilePaths: gpxFilePaths,
  //     trkAssets: trkAssets,
  //     name: name,
  //     description: description,
  //   );
  //   return travelTrack;
  // }

  TravelTrack({
    String? name,
    String? description,
    List<GpxExt>? gpxExts,
    List<TrkAsset>? trkAssets,
  }) : _description = description {
    _name = name ?? 'Unnamed $_id';
    if (gpxExts != null) {
      _gpxExts = List<GpxExt>.from(gpxExts);
    }
    if (trkAssets != null) {
      _trkAssets = List<TrkAsset>.from(trkAssets);
    }
  }

  // TODO: auto attach assets
  static Future<TravelTrack> fromGpxFilePaths({
    String? name,
    String? description,
    required List<String> gpxFilePaths,
  }) async {
    if (name == null && gpxFilePaths.isNotEmpty) {
      name = basename(gpxFilePaths.first);
    }

    List<GpxExt> gpxExts = <GpxExt>[];
    for (String gpxFilePath in gpxFilePaths) {
      gpxExts.add(await GpxExt.fromFilePath(gpxFilePath));
    }

    List<TrkAsset> trkAssets = <TrkAsset>[];
    for (GpxExt gpxExt in gpxExts) {
      for (TrksegExt trksegExt in gpxExt.trksegExts) {
        trkAssets.addAll(await TrkAsset.fromTimeRange(
          startTime: trksegExt.trkseg.trkpts.first.time,
          endTime: trksegExt.trkseg.trkpts.last.time,
          attachedTrksegExt: trksegExt,
        ));
      }
    }
    return TravelTrack(
      name: name,
      description: description,
      gpxExts: gpxExts,
      trkAssets: trkAssets,
    );
  }
}
