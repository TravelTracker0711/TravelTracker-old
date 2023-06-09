import 'package:travel_tracker/features/travel_track/gpx_ext.dart';
import 'package:travel_tracker/features/travel_track/trkseg_ext.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_tracker/features/travel_track/asset_ext.dart';

// TODO: find a way to store global list of travel tracks, and load them when app starts
// TODO: TravelTrackManager, TravelTrackRepository, TravelTrackService
// TODO: with ChangeNotifier
class TravelTrack {
  late final String id;
  late String name;
  late String description;
  List<GpxExt> _gpxExts = <GpxExt>[];
  List<AssetExt> _assetExts = <AssetExt>[];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gpxExts': _gpxExts.map((e) => e.toJson()).toList(),
      'assetExts': _assetExts.map((e) => e.toJson()).toList(),
    };
  }

  // TravelTrack.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   name = json['name'];
  //   description = json['description'];
  //   _gpxExts = (json['gpxExts'] as List)
  //       .map((e) => GpxExt.fromJson(e))
  //       .toList()
  //       .cast<GpxExt>();
  //   _assetExts = (json['assetExts'] as List)
  //       .map((e) => AssetExt.fromJson(e))
  //       .toList()
  //       .cast<AssetExt>();
  // }

  List<GpxExt> get gpxExts => List<GpxExt>.unmodifiable(_gpxExts);
  List<TrksegExt> get trksegExts => List<TrksegExt>.unmodifiable(
        _gpxExts.expand((gpxExt) => gpxExt.trksegExts).toList(),
      );
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
    id = const Uuid().v4();
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
