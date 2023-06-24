import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/utils/datetime.dart';

class TravelTrack extends TravelData with ChangeNotifier {
  final List<Wpt> _wpts = <Wpt>[];
  final List<Trkseg> _trksegs = <Trkseg>[];
  final Map<String, AssetExt> _assetExtMap = <String, AssetExt>{};
  List<List<String>> _assetExtIdGroups = <List<String>>[];
  final List<String> _gpxFileFullPaths = <String>[];
  final DateTime _createDateTime;
  bool isSelected = false;
  bool isVisible = true;

  List<Trkseg> get trksegs => List<Trkseg>.unmodifiable(_trksegs);
  Map<String, AssetExt> get assetExtMap =>
      Map<String, AssetExt>.unmodifiable(_assetExtMap);
  List<AssetExt> get assetExts {
    List<AssetExt> assetExts = _assetExtMap.values.toList();
    assetExts.sort((a, b) => a.compareTo(b));
    return List<AssetExt>.unmodifiable(assetExts);
  }

  List<List<String>> get assetExtIdGroups =>
      List<List<String>>.unmodifiable(_assetExtIdGroups);
  DateTime get startTime => getTrksegsStartTime(_trksegs) ?? _createDateTime;
  DateTime get endTime => getTrksegsEndTime(_trksegs) ?? _createDateTime;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'wpts': _wpts.map((e) => e.toJson()).toList(),
      'trksegs': _trksegs.map((e) => e.toJson()).toList(),
      'assetExtMap': _assetExtMap.map((key, value) => MapEntry(key, value)),
      'gpxFileFullPaths': _gpxFileFullPaths,
      'createDateTime': _createDateTime.toIso8601String(),
    });
    return json;
  }

  static Future<TravelTrack> fromJson(Map<String, dynamic> json) async {
    Map<String, AssetExt> assetExtMap = {
      for (String key in json['assetExtMap'].keys)
        key: await AssetExt.fromJson(json['assetExtMap'][key])
    };
    TravelTrack travelTrack = TravelTrack._(
      id: json['id'],
      config: TravelConfig.fromJson(json['config']),
      wpts: (json['wpts'] as List)
          .map((e) => Wpt.fromJson(e))
          .toList()
          .cast<Wpt>(),
      trksegs: (json['trksegs'] as List)
          .map((e) => Trkseg.fromJson(e))
          .toList()
          .cast<Trkseg>(),
      assetExtMap: assetExtMap,
      gpxFileFullPaths: (json['gpxFileFullPaths'] as List)
          .map((e) => e.toString())
          .toList()
          .cast<String>(),
      createDateTime: DateTime.parse(json['createDateTime']),
    );
    return travelTrack;
  }

  gpx_pkg.Gpx toGpx() {
    // Wpt, Trkseg
    gpx_pkg.Gpx gpx = gpx_pkg.Gpx();

    List<gpx_pkg.Wpt> wpts = [];
    for (Wpt ext in _wpts) {
      gpx_pkg.Wpt wpt = gpx_pkg.Wpt(
          lat: ext.lat, lon: ext.lon, ele: ext.elevation, time: ext.time);
      wpts.add(wpt);
    }
    gpx.wpts = wpts;

    List<gpx_pkg.Trkseg> trksegs = [];
    for (Trkseg trkext in _trksegs) {
      List<gpx_pkg.Wpt> wpts = [];
      for (Wpt wptext in trkext.trkpts) {
        gpx_pkg.Wpt wpt = gpx_pkg.Wpt(
            lat: wptext.lat,
            lon: wptext.lon,
            ele: wptext.elevation,
            time: wptext.time);
        wpts.add(wpt);
      }
      gpx_pkg.Trkseg trkseg = gpx_pkg.Trkseg(trkpts: wpts);
      trksegs.add(trkseg);
    }
    gpx_pkg.Trk trk = gpx_pkg.Trk(trksegs: trksegs);
    List<gpx_pkg.Trk> trks = [trk];
    gpx.trks = trks;
    return gpx;
  }

  TravelTrack({
    TravelConfig? config,
  }) : this._(
          config: config,
        );

  TravelTrack._({
    String? id,
    TravelConfig? config,
    List<Wpt>? wpts,
    List<Trkseg>? trksegs,
    Map<String, AssetExt>? assetExtMap,
    List<String>? gpxFileFullPaths,
    DateTime? createDateTime,
  })  : _createDateTime = createDateTime ?? DateTime.now(),
        super(
          id: id,
          config: config,
        ) {
    if (wpts != null) {
      _wpts.addAll(wpts);
      _wpts.sort((a, b) => a.compareTo(b));
    }
    if (trksegs != null) {
      _trksegs.addAll(trksegs);
      _trksegs.sort((a, b) => a.compareTo(b));
    }
    if (assetExtMap != null) {
      _assetExtMap.addAll(assetExtMap);
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
    Map<String, AssetExt> assetExtMap = <String, AssetExt>{};
    for (String gpxFilePath in gpxFileFullPaths) {
      File gpxFile = File(gpxFilePath);
      if (!await gpxFile.exists()) {
        continue;
      }
      String gpxString = await gpxFile.readAsString();
      gpx_pkg.Gpx gpx = gpx_pkg.GpxReader().fromString(gpxString);

      wpts.addAll(Wpt.fromGpx(
        gpx: gpx,
      ));
      trksegs.addAll(Trkseg.fromGpx(
        gpx: gpx,
      ));
    }
    wpts.sort((a, b) => a.compareTo(b));
    trksegs.sort((a, b) => a.compareTo(b));

    if (autoAttachAssets) {
      DateTime? startTime = getTrksegsStartTime(trksegs);
      DateTime? endTime = getTrksegsEndTime(trksegs);
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
          assetExtMap.addAll({
            for (AssetExt assetExt in await AssetExt.fromAssetEntitiesAsync(
              assetEntities:
                  assetEntities.sublist(lastAssetEndIndex, assetStartIndex),
            ))
              assetExt.id: assetExt,
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
          assetExtMap.addAll({
            for (AssetExt assetExt
                in await AssetExt.fromAssetEntitiesWithTrksegAsync(
              assetEntities:
                  assetEntities.sublist(assetStartIndex, assetEndIndex),
              trkseg: trkseg,
            ))
              assetExt.id: assetExt,
          });
          assetStartIndex = assetEndIndex;
        }
        assetExtMap.addAll({
          for (AssetExt assetExt in await AssetExt.fromAssetEntitiesAsync(
            assetEntities: assetEntities.sublist(lastAssetEndIndex, assetCount),
          ))
            assetExt.id: assetExt,
        });
      }
    }
    return TravelTrack._(
      wpts: wpts,
      trksegs: trksegs,
      assetExtMap: assetExtMap,
      gpxFileFullPaths: gpxFileFullPaths,
      config: config,
    );
  }

  // void clearAssetExtIdGroupsAsync() async {
  //   await Future.delayed(Duration.zero);
  //   _assetExtIdGroups.clear();
  //   notifyListeners();
  // }

  // void addAssetExtIdGroupAsync(List<String> assetExtIds) async {
  //   if (assetExtIds.isEmpty) {
  //     return;
  //   }
  //   await Future.delayed(Duration.zero);
  //   assetExtIds.sort((a, b) => a.compareTo(b));
  //   _assetExtIdGroups.add(assetExtIds);
  //   _assetExtIdGroups.sort((a, b) {
  //     assert(_assetExtMap[a.first] != null && _assetExtMap[b.first] != null,
  //         'assetExtMap must contain all assetExtIds');
  //     return _assetExtMap[a.first]!.compareTo(_assetExtMap[b.first]!);
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

  List<AssetExt> getAssetExtsByIds(List<String> assetExtIds) {
    List<AssetExt> assetExts = <AssetExt>[];
    for (String assetExtId in assetExtIds) {
      AssetExt? assetExt = _assetExtMap[assetExtId];
      if (assetExt != null) {
        assetExts.add(assetExt);
      }
    }
    return assetExts;
  }

  // TODO: addGpxFileFullPathsAsync
  Future<void> addGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
  }) async {
    throw UnimplementedError();
  }
}
