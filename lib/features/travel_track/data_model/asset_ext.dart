import 'dart:io';

import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/features/travel_track/data_model/trkseg_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt_ext.dart';
import 'package:travel_tracker/utils/latlong2_util.dart';

enum AssetExtType {
  image,
  video,
  audio,
  text,
  unknown,
}

class AssetExt extends TravelData {
  final AssetEntity asset;
  final AssetExtType type;
  final String fileFullPath;
  WptExt? coordinates;
  String? attachedTrksegExtId;

  DateTime get createDateTime => asset.createDateTime;

  AssetExt._({
    String? id,
    TravelConfig? config,
    required this.asset,
    required this.type,
    required this.fileFullPath,
    this.coordinates,
    this.attachedTrksegExtId,
  }) : super(
          id: id,
          config: config,
        );

  static Future<AssetExt?> fromAssetEntityAsync({
    required AssetEntity asset,
  }) async {
    AssetExtType type = _getAssetType(asset);
    File? assetFile = await asset.originFile;
    String? fileFullPath = assetFile?.path;
    if (fileFullPath == null) {
      return null;
    }
    WptExt? coordinates;
    latlong.LatLng? latLng;
    latLng = photoManagerLatLngToLatLong2(await asset.latlngAsync());
    if (latLng != null) {
      coordinates = WptExt(
        latLng: latLng,
      );
    }
    return AssetExt._(
      asset: asset,
      type: type,
      fileFullPath: fileFullPath,
      coordinates: coordinates,
    );
  }

  static Future<List<AssetExt>> fromAssetEntitiesWithTrksegExtAsync({
    required List<AssetEntity> assets,
    required TrksegExt trksegExt,
    bool overrideAssetOriginCoordinates = true,
  }) async {
    List<AssetExt> assetExts = [];
    for (AssetEntity asset in assets) {
      AssetExt? assetExt = await fromAssetEntityAsync(
        asset: asset,
      );
      if (assetExt == null) {
        continue;
      }
      if (overrideAssetOriginCoordinates) {
        assetExt.coordinates = null;
      }
      assetExts.add(assetExt);
    }
    int trkptIndex = 0;
    List<WptExt> trkpts = trksegExt.trkpts.where((trkpt) {
      return trkpt.time != null;
    }).toList();
    for (AssetExt assetExt in assetExts) {
      if (assetExt.coordinates != null) {
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
      assetExt.coordinates = WptExt(
        latLng: latLng,
      );
      assetExt.attachedTrksegExtId = trksegExt.id;
    }
    return assetExts;
  }

  // TODO: fromFilePathAsync
  static Future<AssetExt?> fromFilePathAsync({
    required String filePath,
  }) async {
    throw UnimplementedError();
  }

  static _getAssetType(AssetEntity asset) {
    if (asset.type == AssetType.audio) {
      return AssetExtType.audio;
    } else if (asset.type == AssetType.video) {
      return AssetExtType.video;
    } else if (asset.type == AssetType.image) {
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
    if (attachedTrksegExtId != null) {
      json['attachedTrksegExtId'] = attachedTrksegExtId;
    }
    return json;
  }
}
