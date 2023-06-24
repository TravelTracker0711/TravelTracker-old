import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';
import 'package:travel_tracker/utils/latlng.dart';

enum AssetExtType {
  image,
  video,
  audio,
  text,
  unknown,
}

class AssetExt extends TravelData {
  final AssetEntity assetEntity;
  final AssetExtType type;
  final String fileFullPath;
  Wpt? coordinates;
  String? attachedTrksegId;

  DateTime get createDateTime => assetEntity.createDateTime;

  AssetExt._({
    String? id,
    TravelConfig? config,
    required this.assetEntity,
    required this.type,
    required this.fileFullPath,
    this.coordinates,
    this.attachedTrksegId,
  }) : super(
          id: id,
          config: config,
        );

  int compareTo(AssetExt other) {
    return createDateTime.compareTo(other.createDateTime);
  }

  static Future<AssetExt?> fromAssetEntityAsync({
    required AssetEntity assetEntity,
  }) async {
    AssetExtType type = _getAssetType(assetEntity);
    File? assetFile = await assetEntity.originFile;
    String? fileFullPath = assetFile?.path;
    if (fileFullPath == null) {
      return null;
    }
    Wpt? coordinates;
    latlong.LatLng? latLng;
    latLng = (await assetEntity.latlngAsync()).toLatLong2();
    if (latLng == latlong.LatLng(0, 0)) {
      latLng = null;
    }
    if (latLng != null) {
      coordinates = Wpt(
        latLng: latLng,
      );
    }
    return AssetExt._(
      assetEntity: assetEntity,
      type: type,
      fileFullPath: fileFullPath,
      coordinates: coordinates,
    );
  }

  static Future<List<AssetExt>> fromAssetEntitiesAsync({
    required List<AssetEntity> assetEntities,
  }) async {
    List<AssetExt> assetExts = [];
    for (AssetEntity assetEntity in assetEntities) {
      AssetExt? assetExt = await fromAssetEntityAsync(
        assetEntity: assetEntity,
      );
      if (assetExt == null) {
        continue;
      }
      assetExts.add(assetExt);
    }
    return assetExts;
  }

  static Future<List<AssetExt>> fromAssetEntitiesWithTrksegAsync({
    required List<AssetEntity> assetEntities,
    required Trkseg trkseg,
    bool overrideAssetOriginCoordinates = true,
  }) async {
    List<AssetExt> assetExts = await fromAssetEntitiesAsync(
      assetEntities: assetEntities,
    );
    int trkptIndex = 0;
    List<Wpt> trkpts = trkseg.trkpts.where((trkpt) {
      return trkpt.time != null;
    }).toList();
    for (AssetExt assetExt in assetExts) {
      if (overrideAssetOriginCoordinates == false &&
          assetExt.coordinates != null) {
        continue;
      }
      while (trkptIndex < trkpts.length - 1 &&
          (trkpts[trkptIndex + 1].time!.isBefore(assetExt.createDateTime))) {
        trkptIndex++;
      }
      latlong.LatLng latLng = latlong.LatLng(
        trkpts[trkptIndex].lat,
        trkpts[trkptIndex].lon,
      );
      if (trkptIndex < trkpts.length - 1) {
        double coordinatesRatio = 0;
        int assetMilliseconds = assetExt.createDateTime.millisecondsSinceEpoch;
        int prevTrkptMilliseconds =
            trkpts[trkptIndex].time!.millisecondsSinceEpoch;
        int nextTrkptMilliseconds =
            trkpts[trkptIndex + 1].time!.millisecondsSinceEpoch;
        coordinatesRatio = (assetMilliseconds - prevTrkptMilliseconds) /
            (nextTrkptMilliseconds - prevTrkptMilliseconds);
        // (a + (b - a) * ratio) should correct in Mercator projection
        // need to check whether it is accurate in real world
        latLng = latlong.LatLng(
          trkpts[trkptIndex].lat +
              (trkpts[trkptIndex + 1].lat - trkpts[trkptIndex].lat) *
                  coordinatesRatio,
          trkpts[trkptIndex].lon +
              (trkpts[trkptIndex + 1].lon - trkpts[trkptIndex].lon) *
                  coordinatesRatio,
        );
      }
      assetExt.coordinates = Wpt(
        latLng: latLng,
      );
      assetExt.attachedTrksegId = trkseg.id;
    }
    return assetExts;
  }

  // TODO: fromFilePathAsync
  static Future<AssetExt?> fromFilePathAsync({
    required String filePath,
  }) async {
    throw UnimplementedError();
  }

  static AssetExtType _getAssetType(AssetEntity assetEntity) {
    if (assetEntity.type == AssetType.audio) {
      return AssetExtType.audio;
    } else if (assetEntity.type == AssetType.video) {
      return AssetExtType.video;
    } else if (assetEntity.type == AssetType.image) {
      return AssetExtType.image;
    } else {
      return AssetExtType.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'type': type.toString(),
      'fileFullPath': fileFullPath,
    });
    if (coordinates != null) {
      json['coordinates'] = coordinates!.toJson();
    }
    if (attachedTrksegId != null) {
      json['attachedTrksegId'] = attachedTrksegId;
    }
    return json;
  }

  static Future<AssetExt> fromJson(Map<String, dynamic> json) async {
    AssetEntity assetEntity =
        (await ExternalAssetManager.FI).getAssetEntityByPath(
      json['fileFullPath'],
    )!;
    AssetExt assetExt = AssetExt._(
      id: json['id'],
      config:
          json['config'] != null ? TravelConfig.fromJson(json['config']) : null,
      assetEntity: assetEntity,
      type: _getAssetExtTypeFromString(json['type']),
      fileFullPath: json['fileFullPath'],
      coordinates: json['coordinates'] != null
          ? Wpt.fromJson(json['coordinates'])
          : null,
      attachedTrksegId: json['attachedTrksegId'],
    );
    return assetExt;
  }

  static AssetExtType _getAssetExtTypeFromString(String typeString) {
    if (typeString == AssetExtType.audio.toString()) {
      return AssetExtType.audio;
    } else if (typeString == AssetExtType.video.toString()) {
      return AssetExtType.video;
    } else if (typeString == AssetExtType.image.toString()) {
      return AssetExtType.image;
    } else if (typeString == AssetExtType.text.toString()) {
      return AssetExtType.text;
    } else {
      return AssetExtType.unknown;
    }
  }
}
