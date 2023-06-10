import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/asset_ext.dart';

// TODO: find a way to store global list of travel tracks, and load them when app starts
// TODO: TravelTrackManager, TravelTrackRepository, TravelTrackService
// TODO: with ChangeNotifier
class TravelTrack extends TravelData {
  final List<WptExt> _wptExts = <WptExt>[];
  final List<TrksegExt> _trksegExts = <TrksegExt>[];
  final List<AssetExt> _assetExts = <AssetExt>[];
  final List<String> _gpxFileFullPaths = <String>[];
  bool isSelected = false;
  bool isVisible = true;

  List<TrksegExt> get trksegExts => List<TrksegExt>.unmodifiable(_trksegExts);
  List<AssetExt> get assetExts => List<AssetExt>.unmodifiable(_assetExts);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'wptExts': _wptExts.map((e) => e.toJson()).toList(),
      'trksegExts': _trksegExts.map((e) => e.toJson()).toList(),
      'assetExts': _assetExts.map((e) => e.toJson()).toList(),
      'gpxFileFullPaths': _gpxFileFullPaths,
    });
    return json;
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

  TravelTrack._({
    String? id,
    TravelConfig? config,
    List<WptExt>? wptExts,
    List<TrksegExt>? trksegExts,
    List<AssetExt>? assetExts,
    List<String>? gpxFileFullPaths,
  }) : super(
          id: id,
          config: config,
        ) {
    if (wptExts != null) {
      _wptExts.addAll(wptExts);
    }
    if (trksegExts != null) {
      _trksegExts.addAll(trksegExts);
    }
    if (assetExts != null) {
      _assetExts.addAll(assetExts);
    }
    if (gpxFileFullPaths != null) {
      _gpxFileFullPaths.addAll(gpxFileFullPaths);
    }
  }

  static Future<TravelTrack> fromGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
    bool autoAttachAssets = false,
  }) async {
    List<WptExt> wptExts = <WptExt>[];
    List<TrksegExt> trksegExts = <TrksegExt>[];
    List<AssetExt> assetExts = <AssetExt>[];
    for (String gpxFilePath in gpxFileFullPaths) {
      File gpxFile = File(gpxFilePath);
      if (!await gpxFile.exists()) {
        continue;
      }
      String gpxString = await gpxFile.readAsString();
      Gpx gpx = GpxReader().fromString(gpxString);

      wptExts.addAll(WptExt.fromGpx(
        gpx: gpx,
      ));
      trksegExts.addAll(TrksegExt.fromGpx(
        gpx: gpx,
      ));
    }

    if (autoAttachAssets) {
      for (TrksegExt trksegExt in trksegExts) {
        ExternalAssetManager externalAssetManager =
            await ExternalAssetManager.FI;
        DateTime? minDate, maxDate;
        for (WptExt wptExt in trksegExt.trkpts) {
          if (wptExt.time == null) {
            continue;
          }
          if (minDate == null || minDate.isAfter(wptExt.time!)) {
            minDate = wptExt.time;
          }
          if (maxDate == null || maxDate.isBefore(wptExt.time!)) {
            maxDate = wptExt.time;
          }
        }
        List<AssetEntity>? assets =
            await externalAssetManager.getAssetsBetweenTimeAsync(
          minDate: minDate,
          maxDate: maxDate,
        );
        if (assets == null) {
          continue;
        }
        assetExts.addAll(await AssetExt.fromAssetEntitiesWithTrksegExtAsync(
          assets: assets,
          trksegExt: trksegExt,
        ));
      }
    }
    return TravelTrack._(
      wptExts: wptExts,
      trksegExts: trksegExts,
      assetExts: assetExts,
      gpxFileFullPaths: gpxFileFullPaths,
    );
  }

  // TODO: addGpxFileFullPathsAsync
  Future<void> addGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
  }) async {
    throw UnimplementedError();
  }
}
