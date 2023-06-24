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
    } else {
      return AssetType.unknown;
    }
  }
}

extension StringAssetTypeConversion on String {
  AssetType toAssetType() {
    return _AssetTypeFactory.fromString(this);
  }
}

extension PhotoManagerAssetTypeConversion on pm.AssetType {
  AssetType toAssetType() {
    return _AssetTypeFactory.fromPhotoManagerType(this);
  }
}

class AssetFactory {
  static Future<Asset> fromJson(Map<String, dynamic> json) async {
    Asset asset = Asset(
      config: TravelConfigFactory.fromJson(json['config']),
      file: File(json['fileFullPath']),
      type: (json['type'] as String).toAssetType(),
      createdDateTime: DateTime.parse(json['createdDateTime']),
      coordinates: json['coordinates'] != null
          ? WptFactory.fromJson(json['coordinates'])
          : null,
      attachedTrksegId: json['attachedTrksegId'],
    );
    return asset;
  }

  static Future<Asset?> fromAssetEntityAsync({
    required pm.AssetEntity assetEntity,
  }) async {
    TravelConfig config = TravelConfigFactory.fromAssetEntity(assetEntity);
    AssetType type = assetEntity.type.toAssetType();
    File? assetFile = await assetEntity.originFile;
    if (assetFile == null) {
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

    return Asset(
      config: config,
      file: assetFile,
      type: type,
      createdDateTime: assetEntity.createDateTime,
      coordinates: coordinates,
    );
  }

  static Future<List<Asset>> fromAssetEntitiesAsync({
    required List<pm.AssetEntity> assetEntities,
  }) async {
    List<Asset> assets = [];
    for (pm.AssetEntity assetEntity in assetEntities) {
      Asset? asset = await fromAssetEntityAsync(
        assetEntity: assetEntity,
      );
      if (asset == null) {
        continue;
      }
      assets.add(asset);
    }
    return assets;
  }

  // TODO: refactor fromAssetEntitiesWithTrksegAsync
  static Future<List<Asset>> fromAssetEntitiesWithTrksegAsync({
    required List<pm.AssetEntity> assetEntities,
    required Trkseg trkseg,
    bool overrideAssetOriginCoordinates = true,
  }) async {
    List<Asset> assets = await fromAssetEntitiesAsync(
      assetEntities: assetEntities,
    );
    int trkptIndex = 0;
    List<Wpt> trkpts = trkseg.trkpts.where((trkpt) {
      return trkpt.time != null;
    }).toList();
    for (Asset asset in assets) {
      if (overrideAssetOriginCoordinates == false &&
          asset.coordinates != null) {
        continue;
      }
      while (trkptIndex < trkpts.length - 1 &&
          (trkpts[trkptIndex + 1].time!.isBefore(asset.createdDateTime))) {
        trkptIndex++;
      }
      latlong.LatLng latLng = latlong.LatLng(
        trkpts[trkptIndex].lat,
        trkpts[trkptIndex].lon,
      );
      if (trkptIndex < trkpts.length - 1) {
        double coordinatesRatio = 0;
        int assetMilliseconds = asset.createdDateTime.millisecondsSinceEpoch;
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
      asset.coordinates = Wpt(
        latLng: latLng,
      );
      asset.attachedTrksegId = trkseg.config.id;
    }
    return assets;
  }

  // TODO: fromFilePathAsync
  static Future<Asset?> fromFilePathAsync({
    required String filePath,
  }) async {
    throw UnimplementedError();
  }
}
