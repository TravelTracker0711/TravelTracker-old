import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';

// TODO: find a way to store global list of travel tracks, and load them when app starts
// TODO: TravelTrackManager, TravelTrackRepository, TravelTrackService
// TODO: with ChangeNotifier
class TravelTrack {
  final String id = const Uuid().v4();
  late String name;
  late String description;
  List<GpxExt> _gpxExts = <GpxExt>[];
  List<AssetExt> _assetExts = <AssetExt>[];

  List<GpxExt> get gpxExts => List<GpxExt>.unmodifiable(_gpxExts);
  List<AssetExt> get assetExts => List<AssetExt>.unmodifiable(_assetExts);

  // TODO: TravelTrackService.createAutoAttachAssets
  // static Future<TravelTrack> createAutoAttachAssetsAsync({
  //   List<String>? gpxFilePaths,
  //   List<AssetExt>? assetExts,
  //   required String name,
  //   String? description,
  // }) async {
  //   TravelTrack travelTrack = TravelTrack(
  //     gpxFilePaths: gpxFilePaths,
  //     assetExts: assetExts,
  //     name: name,
  //     description: description,
  //   );
  //   return travelTrack;
  // }

  TravelTrack._({
    String? name,
    String? description,
    List<GpxExt>? gpxExts,
    List<AssetExt>? assetExts,
  }) {
    this.name = name ?? _getFirstGpxExtName(gpxExts) ?? 'Unnamed $id';
    this.description = description ?? '';
    _gpxExts = List<GpxExt>.of(gpxExts ?? []);
    _assetExts = List<AssetExt>.of(assetExts ?? []);
  }

  static String? _getFirstGpxExtName(List<GpxExt>? gpxExts) {
    if (gpxExts == null || gpxExts.isEmpty) {
      return null;
    }
    return gpxExts.first.name;
  }

  static Future<TravelTrack> fromGpxFilePathsAsync({
    required List<String> gpxFilePaths,
    String? name,
    String? description,
  }) async {
    List<GpxExt> gpxExts = <GpxExt>[];
    for (String gpxFilePath in gpxFilePaths) {
      gpxExts.add(await GpxExt.fromFilePathAsync(
        filePath: gpxFilePath,
      ));
    }

    List<AssetExt> assetExts = <AssetExt>[];
    for (GpxExt gpxExt in gpxExts) {
      for (TrksegExt trksegExt in gpxExt.trksegExts) {
        assetExts.addAll(await AssetExt.fromTimeRangeAsync(
          startTime: trksegExt.trkseg.trkpts.first.time,
          endTime: trksegExt.trkseg.trkpts.last.time,
          attachedTrksegExt: trksegExt,
        ));
      }
    }
    return TravelTrack._(
      name: name,
      description: description,
      gpxExts: gpxExts,
      assetExts: assetExts,
    );
  }

  Future<void> addGpxByFilePathAsync(String gpxFilePath) async {
    _gpxExts.add(await GpxExt.fromFilePathAsync(
      filePath: gpxFilePath,
    ));
  }
}
