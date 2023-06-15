import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/asset_ext.dart';
import 'package:travel_tracker/utils/datetime.dart';

class TravelTrack extends TravelData {
  final List<WptExt> _wptExts = <WptExt>[];
  final List<TrksegExt> _trksegExts = <TrksegExt>[];
  final List<AssetExt> _assetExts = <AssetExt>[];
  final List<String> _gpxFileFullPaths = <String>[];
  bool isSelected = false;
  bool isVisible = true;

  List<TrksegExt> get trksegExts => List<TrksegExt>.unmodifiable(_trksegExts);
  List<AssetExt> get assetExts => List<AssetExt>.unmodifiable(_assetExts);
  DateTime? get startTime => getTrksegExtsStartTime(_trksegExts);
  DateTime? get endTime => getTrksegExtsEndTime(_trksegExts);

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
      _wptExts.sort((a, b) => a.compareTo(b));
    }
    if (trksegExts != null) {
      _trksegExts.addAll(trksegExts);
      _trksegExts.sort((a, b) => a.compareTo(b));
    }
    if (assetExts != null) {
      _assetExts.addAll(assetExts);
      _assetExts.sort((a, b) => a.compareTo(b));
    }
    if (gpxFileFullPaths != null) {
      _gpxFileFullPaths.addAll(gpxFileFullPaths);
    }
  }

  int compareTo(TravelTrack other) {
    return nullableDateTimeCompare(
      trksegExts.first.startTime,
      other.trksegExts.first.startTime,
    );
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
    wptExts.sort((a, b) => a.compareTo(b));
    trksegExts.sort((a, b) => a.compareTo(b));

    if (autoAttachAssets) {
      DateTime? startTime = getTrksegExtsStartTime(trksegExts);
      DateTime? endTime = getTrksegExtsEndTime(trksegExts);
      assert(startTime != null && endTime != null,
          'startTime and endTime must not be null');
      ExternalAssetManager externalAssetManager = await ExternalAssetManager.FI;
      List<AssetEntity>? assets =
          await externalAssetManager.getAssetsBetweenTimeAsync(
        minDate: startTime,
        maxDate: endTime,
      );
      if (assets != null) {
        int assetCount = assets.length;
        int assetStartIndex = 0;
        int assetEndIndex = 0;
        int lastAssetEndIndex = 0;
        for (TrksegExt trksegExt in trksegExts) {
          DateTime? trksegExtStartTime = trksegExt.startTime;
          DateTime? trksegExtEndTime = trksegExt.endTime;
          if (trksegExtStartTime == null || trksegExtEndTime == null) {
            continue;
          }
          while (assetStartIndex < assetCount) {
            AssetEntity asset = assets[assetStartIndex];
            DateTime assetDateTime = asset.createDateTime;
            if (assetDateTime.isBefore(trksegExtStartTime)) {
              assetStartIndex++;
              continue;
            }
            break;
          }
          assetExts.addAll(await AssetExt.fromAssetEntitysAsync(
            assets: assets.sublist(lastAssetEndIndex, assetStartIndex),
          ));
          assetEndIndex = assetStartIndex;
          while (assetEndIndex < assetCount) {
            AssetEntity asset = assets[assetEndIndex];
            DateTime assetDateTime = asset.createDateTime;
            if (assetDateTime.isBefore(trksegExtEndTime)) {
              assetEndIndex++;
              continue;
            }
            break;
          }
          lastAssetEndIndex = assetEndIndex;
          assetStartIndex = assetEndIndex;
          assetExts.addAll(await AssetExt.fromAssetEntitiesWithTrksegExtAsync(
            assets: assets.sublist(assetStartIndex, assetEndIndex),
            trksegExt: trksegExt,
          ));
        }
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
