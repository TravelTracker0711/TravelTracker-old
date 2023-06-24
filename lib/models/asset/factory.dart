part of 'asset.dart';

class AssetFactory {
  static Future<Asset> fromJson(Map<String, dynamic> json) async {
    pm.AssetEntity assetEntity =
        (await ExternalAssetManager.FI).getAssetEntityByPath(
      json['fileFullPath'],
    )!;
    Asset asset = Asset(
      config: json['config'] != null
          ? TravelConfigFactory.fromJson(json['config'])
          : null,
      assetEntity: assetEntity,
      type: _getAssetTypeFromString(json['type']),
      fileFullPath: json['fileFullPath'],
      coordinates: json['coordinates'] != null
          ? WptFactory.fromJson(json['coordinates'])
          : null,
      attachedTrksegId: json['attachedTrksegId'],
    );
    return asset;
  }

  static AssetType _getAssetTypeFromString(String typeString) {
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

  static Future<Asset?> fromAssetEntityAsync({
    required pm.AssetEntity assetEntity,
  }) async {
    AssetType type = _getAssetType(assetEntity);
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
    return Asset(
      assetEntity: assetEntity,
      type: type,
      fileFullPath: fileFullPath,
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
          (trkpts[trkptIndex + 1].time!.isBefore(asset.createDateTime))) {
        trkptIndex++;
      }
      latlong.LatLng latLng = latlong.LatLng(
        trkpts[trkptIndex].lat,
        trkpts[trkptIndex].lon,
      );
      if (trkptIndex < trkpts.length - 1) {
        double coordinatesRatio = 0;
        int assetMilliseconds = asset.createDateTime.millisecondsSinceEpoch;
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
