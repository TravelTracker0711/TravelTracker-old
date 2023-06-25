import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/utils/datetime.dart';
import 'package:travel_tracker/utils/latlng.dart';

part 'factory.dart';
part 'conversion.dart';
part 'utils.dart';

enum AssetType {
  image,
  video,
  audio,
  text,
  unknown,
  unset;

  @override
  String toString() {
    switch (this) {
      case AssetType.audio:
        return 'AssetType.audio';
      case AssetType.video:
        return 'AssetType.video';
      case AssetType.image:
        return 'AssetType.image';
      case AssetType.text:
        return 'AssetType.text';
      case AssetType.unknown:
        return 'AssetType.unknown';
      case AssetType.unset:
        return 'AssetType.unset';
      default:
        return 'AssetType.unknown';
    }
  }
}

class Asset {
  final TravelConfig config;
  final String? assetEntityId;
  String? attachedTrksegId;

  pm.AssetEntity? _entity;
  Wpt? _coordinates;
  AssetType _type;
  DateTime? _createdDateTime;

  /// run [fetchEntityDataAsync] before using [entity]
  pm.AssetEntity? get entity => _entity;

  /// run [fetchEntityDataAsync] before using [coordinates]
  Wpt? get coordinates => _coordinates;

  /// run [fetchEntityDataAsync] before using [type]
  AssetType get type => _type;

  /// run [fetchEntityDataAsync] before using [createdDateTime]
  DateTime? get createdDateTime => _createdDateTime;

  /// run [fetchEntityDataAsync] before using [fileAsync]
  Future<File?> get fileAsync async {
    return await entity?.file;
  }

  /// run [fetchEntityDataAsync] before using [fileFullPathAsync]
  Future<String?> get fileFullPathAsync async {
    File? file = await fileAsync;
    return file?.path;
  }

  /// fetches entity data(entity, type, createdDateTime) from assetEntityId
  /// with [force] set to true, it will fetch data even if it has already been fetched
  /// with [entity] set, it will use that instead of fetching from assetEntityId
  Future<void> fetchEntityDataAsync({
    bool force = false,
    pm.AssetEntity? entity,
  }) async {
    if (assetEntityId == null) {
      return;
    }
    if (entity != null) {
      _entity = entity;
    } else if (_entity == null || force) {
      _entity = await ExternalAssetManager.FI.then((eam) async {
        return eam.getAssetEntity(id: assetEntityId!);
      });
    }
    if (_entity != null) {
      if (_coordinates == null || force) {
        latlong.LatLng? latLng;
        latLng = (await _entity!.latlngAsync()).toLatLong2();
        if (latLng == latlong.LatLng(0, 0)) {
          latLng = null;
        }
        if (latLng != null) {
          _coordinates = Wpt(
            latLng: latLng,
          );
        }
      }
      if (_type == AssetType.unset || force) {
        _type = _entity!.type.toAssetType();
      }
      if (_createdDateTime == null || force) {
        _createdDateTime = _entity!.createDateTime;
      }
    }
  }

  Asset({
    TravelConfig? config,
    AssetType? type,
    this.assetEntityId,
    this.attachedTrksegId,
    Wpt? coordinates,
    DateTime? createdDateTime,
  })  : config = config?.clone() ?? TravelConfig(),
        _type = type ?? AssetType.unset,
        _coordinates = coordinates?.clone(),
        _createdDateTime = createdDateTime;

  int compareTo(Asset other) {
    return nullableDateTimeCompare(
      _createdDateTime,
      other._createdDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'type': _type.toString(),
    };
    if (assetEntityId != null) {
      json['assetEntityId'] = assetEntityId;
    }
    if (attachedTrksegId != null) {
      json['attachedTrksegId'] = attachedTrksegId;
    }
    if (coordinates != null) {
      json['coordinates'] = coordinates!.toJson();
    }
    if (_createdDateTime != null) {
      json['createdDateTime'] = _createdDateTime.toString();
    }
    return json;
  }
}
