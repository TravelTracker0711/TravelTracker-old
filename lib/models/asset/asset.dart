import 'dart:io';

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
  unknown;

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
      default:
        return 'AssetType.unknown';
    }
  }
}

class Asset {
  final TravelConfig config;
  final String? assetEntityId;
  String? attachedTrksegId;
  AssetType _type;
  Wpt? coordinates;
  DateTime? _createdDateTime;

  AssetType get type => _type;
  DateTime? get createdDateTime => _createdDateTime;

  Future<pm.AssetEntity?> get entityAsync async {
    if (assetEntityId == null) {
      return null;
    }
    return await ExternalAssetManager.FI.then((eam) async {
      return await eam.getAssetEntityAsync(id: assetEntityId!);
    });
  }

  Future<File?> get fileAsync async {
    pm.AssetEntity? entity = await entityAsync;
    return await entity?.file;
  }

  Future<String?> get fileFullPathAsync async {
    File? file = await fileAsync;
    return file?.path;
  }

  /// Returns type if it have already been set
  /// Otherwise, sets and returns type from entity
  Future<AssetType> get typeAsync async {
    if (_type != AssetType.unknown) {
      return _type;
    }
    pm.AssetEntity? entity = await entityAsync;
    _type = entity?.type.toAssetType() ?? AssetType.unknown;
    return _type;
  }

  /// Returns createdDateTime if it have already been set
  /// Otherwise, sets and returns createDateTime from entity
  Future<DateTime?> get createdDateTimeAsync async {
    if (_createdDateTime != null) {
      return _createdDateTime;
    }
    pm.AssetEntity? entity = await entityAsync;
    _createdDateTime = entity?.createDateTime;
    return _createdDateTime;
  }

  Asset({
    TravelConfig? config,
    AssetType? type,
    this.assetEntityId,
    this.attachedTrksegId,
    Wpt? coordinates,
    DateTime? createdDateTime,
  })  : config = config?.clone() ?? TravelConfig(),
        _type = type ?? AssetType.unknown,
        coordinates = coordinates?.clone(),
        _createdDateTime = createdDateTime;

  int compareTo(Asset other) {
    return nullableDateTimeCompare(
      _createdDateTime,
      other._createdDateTime,
    );
  }
}
