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

part 'conversion.dart';
part 'factory.dart';

class TravelTrack with ChangeNotifier {
  final TravelConfig config;
  final List<Wpt> _wpts = <Wpt>[];
  final List<Trkseg> _trksegs = <Trkseg>[];
  final Map<String, Asset> _assetMap = <String, Asset>{};
  // TODO: group Asset Ids
  // List<List<String>> _assetIdGroups = <List<String>>[];
  final List<String> _gpxFileFullPaths = <String>[];
  final DateTime _createDateTime;
  bool isSelected = false;
  bool isVisible = true;

  /// Guarantee to be sorted by [Wpt.time] in ascending order.
  List<Wpt> get wpts => List<Wpt>.unmodifiable(_wpts);

  /// Guarantee to be sorted by [Trkseg.startTime] in ascending order.
  List<Trkseg> get trksegs => List<Trkseg>.unmodifiable(_trksegs);

  Map<String, Asset> get assetMap => Map<String, Asset>.unmodifiable(_assetMap);

  /// Guarantee to be sorted by [Asset.createdDateTime] in ascending order.
  List<Asset> get assets {
    List<Asset> assets = _assetMap.values.toList();
    assets.sort((a, b) => a.compareTo(b));
    return List<Asset>.unmodifiable(assets);
  }

  // List<List<String>> get assetIdGroups => List<List<String>>.unmodifiable(
  //     _assetIdGroups.map((e) => List<String>.unmodifiable(e)));

  // TODO: get start/end time more accurately
  DateTime get startTime => _trksegs.startTime ?? _createDateTime;
  DateTime get endTime => _trksegs.endTime ?? _createDateTime;

  TravelTrack({
    TravelConfig? config,
    List<Wpt>? wpts,
    List<Trkseg>? trksegs,
    Map<String, Asset>? assetMap,
    List<String>? gpxFileFullPaths,
    DateTime? createDateTime,
  })  : config = config?.clone() ?? TravelConfig(),
        _createDateTime = createDateTime?.toUtc() ?? DateTime.now() {
    if (wpts != null) {
      _wpts
        ..addAll(wpts.clone())
        ..sort((a, b) => a.compareTo(b));
    }
    if (trksegs != null) {
      _trksegs
        ..addAll(trksegs.clone())
        ..sort((a, b) => a.compareTo(b));
    }
    if (assetMap != null) {
      _assetMap.addAll(assetMap);
    }
    if (gpxFileFullPaths != null) {
      _gpxFileFullPaths.addAll(gpxFileFullPaths);
    }
    debugPrint('TravelTrack construct: $this');
  }

  int compareTo(TravelTrack other) {
    return nullableDateTimeCompare(
      startTime,
      other.startTime,
    );
  }

  // TODO: extract setter/getter to another file
  void addTrkseg({
    Trkseg? trkseg,
  }) {
    trkseg ??= Trkseg(
      config: TravelConfig(
        namePlaceholder: "New Track Segment",
      ),
    );
    _trksegs.add(trkseg);
    notifyListeners();
  }

  void addWpt({
    required Wpt wpt,
  }) {
    _wpts.add(wpt);
    notifyListeners();
  }

  void addTrkpt({
    required Wpt trkpt,
  }) {
    if (_trksegs.isEmpty) {
      addTrkseg();
    }
    _trksegs.last.addTrkpt(trkpt);
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

  @override
  String toString() {
    return 'TravelTrack{config: $config, ${_wpts.length} wpts, ${_trksegs.length} trksegs, ${_assetMap.length} assets, ${_gpxFileFullPaths.length} gpxFileFullPaths, createDateTime: $_createDateTime}';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'wpts': _wpts.map((wpt) => wpt.toJson()).toList(),
      'trksegs': _trksegs.map((trkseg) => trkseg.toJson()).toList(),
      'assetMap': _assetMap,
      // 'assetIdGroups': _assetIdGroups,
      'gpxFileFullPaths': _gpxFileFullPaths,
      'createDateTime': _createDateTime.toIso8601String(),
    };
    return json;
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
}
