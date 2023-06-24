import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/utils/datetime.dart';

class TravelTrack with ChangeNotifier {
  final TravelConfig config;
  final List<Wpt> _wpts = <Wpt>[];
  final List<Trkseg> _trksegs = <Trkseg>[];
  final Map<String, Asset> _assetMap = <String, Asset>{};
  List<List<String>> _assetIdGroups = <List<String>>[];
  final List<String> _gpxFileFullPaths = <String>[];
  final DateTime _createDateTime;
  bool isSelected = false;
  bool isVisible = true;

  List<Trkseg> get trksegs => List<Trkseg>.unmodifiable(_trksegs);
  Map<String, Asset> get assetMap => Map<String, Asset>.unmodifiable(_assetMap);
  List<Asset> get assets {
    List<Asset> assets = _assetMap.values.toList();
    assets.sort((a, b) => a.compareTo(b));
    return List<Asset>.unmodifiable(assets);
  }

  List<List<String>> get assetIdGroups =>
      List<List<String>>.unmodifiable(_assetIdGroups);
  DateTime get startTime => _trksegs.startTime ?? _createDateTime;
  DateTime get endTime => _trksegs.endTime ?? _createDateTime;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'wpts': _wpts.map((e) => e.toJson()).toList(),
      'trksegs': _trksegs.map((e) => e.toJson()).toList(),
      'assetMap': _assetMap.map((key, value) => MapEntry(key, value)),
      'gpxFileFullPaths': _gpxFileFullPaths,
      'createDateTime': _createDateTime.toIso8601String(),
    };
    return json;
  }

  static Future<TravelTrack> fromJson(Map<String, dynamic> json) async {
    Map<String, Asset> assetMap = {
      for (String key in json['assetMap'].keys)
        key: await Asset.fromJson(json['assetMap'][key])
    };
    TravelTrack travelTrack = TravelTrack._(
      config: TravelConfigFactory.fromJson(json['config']),
      wpts: (json['wpts'] as List)
          .map((e) => WptFactory.fromJson(e))
          .toList()
          .cast<Wpt>(),
      trksegs: (json['trksegs'] as List)
          .map((e) => TrksegFactory.fromJson(e))
          .toList()
          .cast<Trkseg>(),
      assetMap: assetMap,
      gpxFileFullPaths: (json['gpxFileFullPaths'] as List)
          .map((e) => e.toString())
          .toList()
          .cast<String>(),
      createDateTime: DateTime.parse(json['createDateTime']),
    );
    return travelTrack;
  }

  gpx_pkg.Gpx toGpx() {
    gpx_pkg.Gpx gpx = gpx_pkg.Gpx();

    List<gpx_pkg.Wpt> gpxWpts = [];
    for (Wpt wpt in _wpts) {
      gpx_pkg.Wpt gpxWpt = gpx_pkg.Wpt(
        lat: wpt.lat,
        lon: wpt.lon,
        ele: wpt.elevation,
        time: wpt.time,
      );
      gpxWpts.add(gpxWpt);
    }
    gpx.wpts = gpxWpts;

    List<gpx_pkg.Trkseg> gpxTrksegs = [];
    for (Trkseg trkseg in _trksegs) {
      List<gpx_pkg.Wpt> gpxTrkpts = [];
      for (Wpt wpt in trkseg.trkpts) {
        gpx_pkg.Wpt gpxWpt = gpx_pkg.Wpt(
          lat: wpt.lat,
          lon: wpt.lon,
          ele: wpt.elevation,
          time: wpt.time,
        );
        gpxTrkpts.add(gpxWpt);
      }
      gpx_pkg.Trkseg gpxTrkseg = gpx_pkg.Trkseg(trkpts: gpxTrkpts);
      gpxTrksegs.add(gpxTrkseg);
    }
    gpx_pkg.Trk gpxTrk = gpx_pkg.Trk(trksegs: gpxTrksegs);
    gpx.trks = [gpxTrk];
    return gpx;
  }

  TravelTrack({
    TravelConfig? config,
  }) : this._(
          config: config,
        );

  TravelTrack._({
    TravelConfig? config,
    List<Wpt>? wpts,
    List<Trkseg>? trksegs,
    Map<String, Asset>? assetMap,
    List<String>? gpxFileFullPaths,
    DateTime? createDateTime,
  })  : config = config ?? TravelConfig(),
        _createDateTime = createDateTime ?? DateTime.now() {
    if (wpts != null) {
      _wpts.addAll(wpts);
      _wpts.sort((a, b) => a.compareTo(b));
    }
    if (trksegs != null) {
      _trksegs.addAll(trksegs);
      _trksegs.sort((a, b) => a.compareTo(b));
    }
    if (assetMap != null) {
      _assetMap.addAll(assetMap);
    }
    if (gpxFileFullPaths != null) {
      _gpxFileFullPaths.addAll(gpxFileFullPaths);
    }
  }

  int compareTo(TravelTrack other) {
    return nullableDateTimeCompare(
      trksegs.first.startTime,
      other.trksegs.first.startTime,
    );
  }

  static Future<TravelTrack> fromGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
    bool autoAttachAssets = false,
    TravelConfig? config,
  }) async {
    List<Wpt> wpts = <Wpt>[];
    List<Trkseg> trksegs = <Trkseg>[];
    Map<String, Asset> assetMap = <String, Asset>{};
    for (String gpxFilePath in gpxFileFullPaths) {
      File gpxFile = File(gpxFilePath);
      if (!await gpxFile.exists()) {
        continue;
      }
      String gpxString = await gpxFile.readAsString();
      gpx_pkg.Gpx gpx = gpx_pkg.GpxReader().fromString(gpxString);

      wpts.addAll(WptFactory.fromGpxWpts(
        gpxWpts: gpx.wpts,
      ));
      trksegs.addAll(TrksegFactory.fromGpx(
        gpx: gpx,
      ));
    }
    wpts.sort((a, b) => a.compareTo(b));
    trksegs.sort((a, b) => a.compareTo(b));

    if (autoAttachAssets) {
      DateTime? startTime = trksegs.startTime;
      DateTime? endTime = trksegs.endTime;
      assert(startTime != null && endTime != null,
          'startTime and endTime must not be null');
      ExternalAssetManager externalAssetManager = await ExternalAssetManager.FI;
      List<AssetEntity>? assetEntities =
          await externalAssetManager.getAssetEntitiesBetweenTimeAsync(
        minDate: startTime,
        maxDate: endTime,
      );
      if (assetEntities != null) {
        int assetCount = assetEntities.length;
        int assetStartIndex = 0;
        int assetEndIndex = 0;
        int lastAssetEndIndex = 0;
        for (Trkseg trkseg in trksegs) {
          DateTime? trksegStartTime = trkseg.startTime;
          DateTime? trksegEndTime = trkseg.endTime;
          if (trksegStartTime == null || trksegEndTime == null) {
            continue;
          }
          while (assetStartIndex < assetCount) {
            AssetEntity assetEntity = assetEntities[assetStartIndex];
            DateTime assetDateTime = assetEntity.createDateTime;
            if (assetDateTime.isBefore(trksegStartTime)) {
              assetStartIndex++;
              continue;
            }
            break;
          }
          assetMap.addAll({
            for (Asset asset in await Asset.fromAssetEntitiesAsync(
              assetEntities:
                  assetEntities.sublist(lastAssetEndIndex, assetStartIndex),
            ))
              asset.config.id: asset,
          });
          assetEndIndex = assetStartIndex;
          while (assetEndIndex < assetCount) {
            AssetEntity assetEntity = assetEntities[assetEndIndex];
            DateTime assetDateTime = assetEntity.createDateTime;
            if (assetDateTime.isBefore(trksegEndTime)) {
              assetEndIndex++;
              continue;
            }
            break;
          }
          lastAssetEndIndex = assetEndIndex;
          assetMap.addAll({
            for (Asset asset in await Asset.fromAssetEntitiesWithTrksegAsync(
              assetEntities:
                  assetEntities.sublist(assetStartIndex, assetEndIndex),
              trkseg: trkseg,
            ))
              asset.config.id: asset,
          });
          assetStartIndex = assetEndIndex;
        }
        assetMap.addAll({
          for (Asset asset in await Asset.fromAssetEntitiesAsync(
            assetEntities: assetEntities.sublist(lastAssetEndIndex, assetCount),
          ))
            asset.config.id: asset,
        });
      }
    }
    return TravelTrack._(
      wpts: wpts,
      trksegs: trksegs,
      assetMap: assetMap,
      gpxFileFullPaths: gpxFileFullPaths,
      config: config,
    );
  }

  // void clearAssetIdGroupsAsync() async {
  //   await Future.delayed(Duration.zero);
  //   _assetIdGroups.clear();
  //   notifyListeners();
  // }

  // void addAssetIdGroupAsync(List<String> assetIds) async {
  //   if (assetIds.isEmpty) {
  //     return;
  //   }
  //   await Future.delayed(Duration.zero);
  //   assetIds.sort((a, b) => a.compareTo(b));
  //   _assetIdGroups.add(assetIds);
  //   _assetIdGroups.sort((a, b) {
  //     assert(_assetMap[a.first] != null && _assetMap[b.first] != null,
  //         'assetMap must contain all assetIds');
  //     return _assetMap[a.first]!.compareTo(_assetMap[b.first]!);
  //   });
  //   notifyListeners();
  // }

  void addTrkseg() {
    _trksegs.add(
      Trkseg(
        config: TravelConfig(
          namePlaceholder: "New Track Segment",
        ),
      ),
    );
    notifyListeners();
  }

  void addWpt(Wpt wpt) {
    _wpts.add(wpt);
    notifyListeners();
  }

  void addTrkpt(Wpt wpt) {
    if (_trksegs.isEmpty) {
      addTrkseg();
    }
    _trksegs.last.addTrkpt(wpt);
    debugPrint('addTrkpt: ${wpt.time}');
    notifyListeners();
  }

  List<Asset> getAssetsByIds(List<String> assetIds) {
    List<Asset> assets = <Asset>[];
    for (String assetId in assetIds) {
      Asset? asset = _assetMap[assetId];
      if (asset != null) {
        assets.add(asset);
      }
    }
    return assets;
  }

  // TODO: addGpxFileFullPathsAsync
  Future<void> addGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
  }) async {
    throw UnimplementedError();
  }
}
