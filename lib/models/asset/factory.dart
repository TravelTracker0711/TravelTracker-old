part of 'asset.dart';

class _AssetTypeFactory {
  static AssetType fromString(String typeString) {
    if (typeString == AssetType.audio.toString()) {
      return AssetType.audio;
    } else if (typeString == AssetType.video.toString()) {
      return AssetType.video;
    } else if (typeString == AssetType.image.toString()) {
      return AssetType.image;
    } else if (typeString == AssetType.text.toString()) {
      return AssetType.text;
    } else if (typeString == AssetType.unknown.toString()) {
      return AssetType.unknown;
    } else if (typeString == AssetType.unset.toString()) {
      return AssetType.unset;
    } else {
      return AssetType.unknown;
    }
  }

  static AssetType fromPhotoManagerType(pm.AssetType type) {
    if (type == pm.AssetType.audio) {
      return AssetType.audio;
    } else if (type == pm.AssetType.video) {
      return AssetType.video;
    } else if (type == pm.AssetType.image) {
      return AssetType.image;
    } else if (type == pm.AssetType.other) {
      return AssetType.unknown;
    } else {
      return AssetType.unknown;
    }
  }
}

class AssetFactory {
  static Future<Asset> fromJson(Map<String, dynamic> json) async {
    Asset asset = Asset(
      config: TravelConfigFactory.fromJson(json['config']),
      type: (json['type'] as String).toAssetType(),
      assetEntityId: json['assetEntityId'],
      attachedTrksegId: json['attachedTrksegId'],
      coordinates: json['coordinates'] == null
          ? null
          : WptFactory.fromJson(json['coordinates']),
      createdDateTime: json['createdDateTime'] == null
          ? null
          : DateTime.parse(json['createdDateTime']),
    );
    return asset;
  }

  static Future<Asset?> fromAssetEntityAsync({
    required pm.AssetEntity assetEntity,
  }) async {
    TravelConfig config = TravelConfigFactory.fromAssetEntity(assetEntity);
    Asset asset = Asset(
      config: config,
      assetEntityId: assetEntity.id,
    );
    await asset.fetchEntityDataAsync(
      entity: assetEntity,
    );
    return asset;
  }

  /// Guaranteed to sort by [Asset.createdDateTime] in ascending order.
  static Future<List<Asset>> fromAssetEntitiesAsync({
    required List<pm.AssetEntity> assetEntities,
  }) async {
    List<Asset> assets = [];
    for (pm.AssetEntity assetEntity in assetEntities) {
      Asset? asset = await fromAssetEntityAsync(
        assetEntity: assetEntity,
      );
      if (asset != null) {
        assets.add(asset);
      }
    }
    assets.sort((a, b) => a.compareTo(b));
    return assets;
  }

  /// Guaranteed to sort by [Asset.createdDateTime] in ascending order.
  static Future<List<Asset>> fromAssetEntitiesWithTrksegAsync({
    required List<pm.AssetEntity> assetEntities,
    required Trkseg trkseg,
    bool overrideOriginCoordinates = true,
  }) async {
    List<Asset> assets = await fromAssetEntitiesAsync(
      assetEntities: assetEntities,
    );

    assets.setCoordinatesByTrkseg(
      trkseg: trkseg,
      overrideOriginCoordinates: overrideOriginCoordinates,
    );
    return assets;
  }

  // TODO: fromFilePathAsync
  static Future<Asset?> fromFilePathAsync({
    required String filePath,
  }) async {
    throw UnimplementedError();
  }
}
