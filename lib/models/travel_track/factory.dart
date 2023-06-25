part of 'travel_track.dart';

class TravelTrackFactory {
  static Future<TravelTrack> fromJson(Map<String, dynamic> json) async {
    Map<String, Asset> assetMap = {
      for (String key in (json['assetMap'] as Map).keys)
        key: await AssetFactory.fromJson(json['assetMap'][key])
    };
    TravelTrack travelTrack = TravelTrack(
      config: TravelConfigFactory.fromJson(json['config']),
      wpts: (json['wpts'] as List).map((e) => WptFactory.fromJson(e)).toList(),
      trksegs: (json['trksegs'] as List)
          .map((e) => TrksegFactory.fromJson(e))
          .toList(),
      assetMap: assetMap,
      gpxFileFullPaths:
          (json['gpxFileFullPaths'] as List).map((e) => e.toString()).toList(),
      createDateTime: DateTime.parse(json['createDateTime']),
    );
    return travelTrack;
  }

  static Future<TravelTrack> fromGpxFileFullPathsAsync({
    required List<String> gpxFileFullPaths,
    bool autoAttachAssets = false,
    TravelConfig? config,
  }) async {
    debugPrint("TravelTrackFactory.fromGpxFileFullPathsAsync()");
    List<Wpt> wpts = <Wpt>[];
    List<Trkseg> trksegs = <Trkseg>[];
    Map<String, Asset> assetMap = <String, Asset>{};

    for (String gpxFilePath in gpxFileFullPaths) {
      await _fetchDataFromGpxFileFullPath(
        gpxFilePath: gpxFilePath,
        wpts: wpts,
        trksegs: trksegs,
      );
    }

    if (autoAttachAssets) {
      await _fetchAssetsWithTrksegs(
        trksegs: trksegs,
        assetMap: assetMap,
      );
    }
    return TravelTrack(
      wpts: wpts,
      trksegs: trksegs,
      assetMap: assetMap,
      gpxFileFullPaths: gpxFileFullPaths,
      config: config,
    );
  }

  static Future<void> _fetchDataFromGpxFileFullPath({
    required String gpxFilePath,
    required List<Wpt> wpts,
    required List<Trkseg> trksegs,
  }) async {
    gpx_pkg.Gpx? gpx = await _readGpxFromFileFullPath(gpxFilePath);
    if (gpx == null) {
      return;
    }
    wpts.addAll(WptFactory.fromGpxWpts(
      gpxWpts: gpx.wpts,
    ));
    trksegs.addAll(TrksegFactory.fromGpx(
      gpx: gpx,
    ));
  }

  static Future<gpx_pkg.Gpx?> _readGpxFromFileFullPath(
    String gpxFilePath,
  ) async {
    File gpxFile = File(gpxFilePath);
    if (!await gpxFile.exists()) {
      return null;
    }
    String gpxString = await gpxFile.readAsString();
    gpx_pkg.Gpx gpx = gpx_pkg.GpxReader().fromString(gpxString);
    return gpx;
  }

  static Future<void> _fetchAssetsWithTrksegs({
    required List<Trkseg> trksegs,
    required Map<String, Asset> assetMap,
  }) async {
    trksegs.sort((a, b) => a.compareTo(b));
    DateTime? startTime = trksegs.startTime;
    DateTime? endTime = trksegs.endTime;
    if (startTime == null || endTime == null) {
      return;
    }
    List<AssetEntity>? assetEntities = await _getAssetEntities(
      startTime: startTime,
      endTime: endTime,
    );
    if (assetEntities == null) {
      return;
    }
    int startIndex = 0;
    int endIndex = 0;
    for (Trkseg trkseg in trksegs) {
      DateTime? trksegStartTime = trkseg.startTime;
      DateTime? trksegEndTime = trkseg.endTime;
      if (trksegStartTime == null || trksegEndTime == null) {
        continue;
      }

      startIndex = _getNextAssetIndexAfterTime(
        assetEntities: assetEntities,
        currentIndex: endIndex,
        time: trksegStartTime,
      );
      // add assets outside of trkseg (include assets before first trkseg)
      await _addAssetsToMap(
        assetMap: assetMap,
        assetEntities: assetEntities.sublist(
          endIndex,
          startIndex,
        ),
      );

      endIndex = _getNextAssetIndexAfterTime(
        assetEntities: assetEntities,
        currentIndex: startIndex,
        time: trksegEndTime,
      );
      // add assets inside of trkseg
      await _addAssetsToMap(
        assetMap: assetMap,
        assetEntities: assetEntities.sublist(
          startIndex,
          endIndex,
        ),
        trkseg: trkseg,
      );
    }
    // add assets after last trkseg
    await _addAssetsToMap(
      assetMap: assetMap,
      assetEntities: assetEntities.sublist(
        endIndex,
        assetEntities.length,
      ),
    );
  }

  static Future<List<AssetEntity>?> _getAssetEntities({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    ExternalAssetManager externalAssetManager = await ExternalAssetManager.FI;
    List<AssetEntity>? assetEntities =
        await externalAssetManager.getAssetEntitiesBetweenTimeAsync(
      minDate: startTime,
      maxDate: endTime,
    );
    return assetEntities;
  }

  static int _getNextAssetIndexAfterTime({
    required List<AssetEntity> assetEntities,
    required int currentIndex,
    required DateTime time,
  }) {
    while (currentIndex < assetEntities.length) {
      DateTime assetTime = assetEntities[currentIndex].createDateTime;
      if (assetTime.isBefore(time)) {
        currentIndex++;
      } else {
        break;
      }
    }
    return currentIndex;
  }

  static Future<void> _addAssetsToMap({
    required Map<String, Asset> assetMap,
    required List<AssetEntity> assetEntities,
    Trkseg? trkseg,
  }) async {
    List<Asset> assets = trkseg == null
        ? await AssetFactory.fromAssetEntitiesAsync(
            assetEntities: assetEntities,
          )
        : await AssetFactory.fromAssetEntitiesWithTrksegAsync(
            assetEntities: assetEntities,
            trkseg: trkseg,
          );
    assetMap.addAll({
      for (Asset asset in assets) asset.config.id: asset,
    });
  }
}
