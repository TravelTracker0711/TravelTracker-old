import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/utils/datetime.dart';

class TravelTrack extends TravelData with ChangeNotifier {
  final List<WptExt> _wptExts = <WptExt>[];
  final List<TrksegExt> _trksegExts = <TrksegExt>[];
  final Map<String, AssetExt> _assetExtMap = <String, AssetExt>{};
  List<List<String>> _assetExtIdGroups = <List<String>>[];
  final List<String> _gpxFileFullPaths = <String>[];
  final DateTime _createDateTime;
  bool isSelected = false;
  bool isVisible = true;

  List<TrksegExt> get trksegExts => List<TrksegExt>.unmodifiable(_trksegExts);
  Map<String, AssetExt> get assetExtMap =>
      Map<String, AssetExt>.unmodifiable(_assetExtMap);
  List<AssetExt> get assetExts {
    List<AssetExt> assetExts = _assetExtMap.values.toList();
    assetExts.sort((a, b) => a.compareTo(b));
    return List<AssetExt>.unmodifiable(assetExts);
  }

  List<List<String>> get assetExtIdGroups =>
      List<List<String>>.unmodifiable(_assetExtIdGroups);
  DateTime get startTime =>
      getTrksegExtsStartTime(_trksegExts) ?? _createDateTime;
  DateTime get endTime => getTrksegExtsEndTime(_trksegExts) ?? _createDateTime;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'wptExts': _wptExts.map((e) => e.toJson()).toList(),
      'trksegExts': _trksegExts.map((e) => e.toJson()).toList(),
      'assetExts': assetExts.map((e) => e.toJson()).toList(),
      'gpxFileFullPaths': _gpxFileFullPaths,
      'createDateTime': _createDateTime.toIso8601String(),
    });
    return json;
  }

  Gpx toGpx() {
    // WptExt, TrksegExt
    Gpx gpx = Gpx();

    List<Wpt> wpts = [];
    for (WptExt ext in _wptExts) {
      Wpt wpt =
          Wpt(lat: ext.lat, lon: ext.lon, ele: ext.elevation, time: ext.time);
      wpts.add(wpt);
    }
    gpx.wpts = wpts;

    List<Trkseg> trksegs = [];
    for (TrksegExt trkext in _trksegExts) {
      List<Wpt> wpts = [];
      for (WptExt wptext in trkext.trkpts) {
        Wpt wpt = Wpt(
            lat: wptext.lat,
            lon: wptext.lon,
            ele: wptext.elevation,
            time: wptext.time);
        wpts.add(wpt);
      }
      Trkseg trkseg = Trkseg(trkpts: wpts);
      trksegs.add(trkseg);
    }
    Trk trk = Trk(trksegs: trksegs);
    List<Trk> trks = [trk];
    gpx.trks = trks;
    return gpx;
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

  TravelTrack({
    TravelConfig? config,
  }) : this._(
          config: config,
        );

  TravelTrack._({
    String? id,
    TravelConfig? config,
    List<WptExt>? wptExts,
    List<TrksegExt>? trksegExts,
    Map<String, AssetExt>? assetExts,
    List<String>? gpxFileFullPaths,
    DateTime? createDateTime,
  })  : _createDateTime = createDateTime ?? DateTime.now(),
        super(
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
      _assetExtMap.addAll(assetExts);
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
    Map<String, AssetExt> assetExtMap = <String, AssetExt>{};
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
          assetExtMap.addAll({
            for (AssetExt assetExt in await AssetExt.fromAssetEntitiesAsync(
              assets: assets.sublist(lastAssetEndIndex, assetStartIndex),
            ))
              assetExt.id: assetExt,
          });
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
          assetExtMap.addAll({
            for (AssetExt assetExt
                in await AssetExt.fromAssetEntitiesWithTrksegExtAsync(
              assets: assets.sublist(assetStartIndex, assetEndIndex),
              trksegExt: trksegExt,
            ))
              assetExt.id: assetExt,
          });
          assetStartIndex = assetEndIndex;
        }
        assetExtMap.addAll({
          for (AssetExt assetExt in await AssetExt.fromAssetEntitiesAsync(
            assets: assets.sublist(lastAssetEndIndex, assetCount),
          ))
            assetExt.id: assetExt,
        });
      }
    }
    return TravelTrack._(
      wptExts: wptExts,
      trksegExts: trksegExts,
      assetExts: assetExtMap,
      gpxFileFullPaths: gpxFileFullPaths,
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
    _trksegExts.add(
      TrksegExt(
        config: TravelConfig(
          namePlaceholder: "New Track Segment",
        ),
      ),
    );
    notifyListeners();
  }

  void addWptExt(WptExt wptExt) {
    _wptExts.add(wptExt);
    notifyListeners();
  }

  void addTrkpt(WptExt wptExt) {
    if (_trksegExts.isEmpty) {
      addTrkseg();
    }
    _trksegExts.last.addTrkpt(wptExt);
    debugPrint('addTrkpt: ${wptExt.time}');
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
